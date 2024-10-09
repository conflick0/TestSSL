# OpenSSL requires the port number.
SERVER=$1
DELAY=0.5
openssl3=~/openssl-3.3.2/local/bin/openssl
openssl1=~/openssl-1.0.2k/local/bin/openssl

function scan () {
  local openssl=$1
  shift
  local protocols=("$@")
  local ciphers=$($openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g')
  local enable_protocols=()

  echo Obtaining cipher list from $($openssl version).

  for protocol in "${protocols[@]}"; do
    result=$(echo -n | $openssl s_client -connect $SERVER "$protocol" 2>&1)

    proto=$(echo -n $protocol | sed 's/-//g')
    echo -n Testing [$proto] ...

    if [[ "$result" =~ ":error:" ]] ; then
      error=$(echo -n $result | cut -d':' -f6)
      echo NO \($error\)
    else

      enable_protocols+=("$protocol")
      if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
        echo YES
      else
        echo UNKNOWN RESPONSE
      fi
    fi
    sleep $DELAY
  done

  for enable_protocol in "${enable_protocols[@]}"; do
      for cipher in ${ciphers[@]}; do
        if [ "$enable_protocol" == "-tls1_3" ]; then
            # enable_protocol == TLS 1.3，use -ciphersuites
            result=$(echo -n | $openssl s_client -connect $SERVER -ciphersuites "$cipher" "-tls1_3" 2>&1)
        else
            # enable_protocol < TLS 1.3 ，use -cipher
            result=$(echo -n | $openssl s_client -connect $SERVER -cipher "$cipher" "$enable_protocol" 2>&1)
        fi

        if [[ "$result" =~ ":error:" ]] ; then
          error=$(echo -n $result | cut -d':' -f6)
          # echo NO \($error\)
        else
          proto=$(echo -n $enable_protocol | sed 's/-//g')
          echo -n Testing [$proto] $cipher...

          if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
            echo YES
          else
            echo UNKNOWN RESPONSE
          fi
        fi
        sleep $DELAY
      done
  done
}

protocols3=("-tls1" "-tls1_1" "-tls1_2" "-tls1_3")
scan "$openssl3" "${protocols3[@]}"

protocols1=("-ssl2" "-ssl3")
scan "$openssl1" "${protocols1[@]}"