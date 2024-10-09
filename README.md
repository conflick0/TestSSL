# TestSSL
ssl 掃描小工具，支援 ssl2、ssl3、tsl1、tls1.1、tls1.2、tls1.3
## 用法
```
./testssl.sh <host>:<port>
```
```
Obtaining cipher list from OpenSSL 3.3.2 3 Sep 2024 (Library: OpenSSL 3.3.2 3 Sep 2024).
Testing [tls1] ...NO (no protocols available)
Testing [tls1_1] ...NO (no protocols available)
Testing [tls1_2] ...YES
Testing [tls1_3] ...YES
Testing [tls1_2] ECDHE-RSA-AES256-GCM-SHA384...YES
Testing [tls1_2] DHE-RSA-AES256-GCM-SHA384...YES
Testing [tls1_2] ECDHE-RSA-AES128-GCM-SHA256...YES
Testing [tls1_2] DHE-RSA-AES128-GCM-SHA256...YES
...
```
## 安裝 openssl-3.3.2
```
wget https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz
tar -xvf openssl-3.3.2.tar.gz
cd openssl-3.3.2/

sudo ./config --prefix=`pwd`/local --openssldir=/usr/lib/ssl enable-ssl2 enable-ssl3 no-shared
sudo make depend
sudo make
sudo make -i install

# test tls1_3
~/openssl-3.3.2/local/bin/openssl s_client -connect <server>:443 -tls1_3
```

## 安裝 openssl-1.0.2 (for ssl2、ssl3)
```
wget https://openssl.org/source/openssl-1.0.2k.tar.gz
tar -xvf openssl-1.0.2k.tar.gz
cd openssl-1.0.2k/

# --prefix will make sure that make install copies the files locally instead of system-wide
# --openssldir will make sure that the binary will look in the regular system location for openssl.cnf
# no-shared builds a mostly static binary
sudo ./config --prefix=`pwd`/local --openssldir=/usr/lib/ssl enable-ssl2 enable-ssl3 no-shared
sudo make depend
sudo make
sudo make -i install

# test ssl2
~/openssl-1.0.2k/local/bin/openssl s_client -connect <server>:443 -ssl2
# test ssl3
~/openssl-1.0.2k/local/bin/openssl s_client -connect <server>:443 -ssl3
```

## 測試連線
```
# 建立憑證
~/openssl-1.0.2k/local/bin/openssl req -new -x509 -nodes -out cert.pem -keyout key.pem -days 365

# 建立 ssl2 server 
~/openssl-1.0.2k/local/bin/openssl s_server -cert cert.pem -key key.pem -accept 8787 -ssl2

# 連線 ssl2 server
~/openssl-1.0.2k/local/bin/openssl s_client -connect localhost:8787 -ssl2

# 建立 ssl3 server 
~/openssl-1.0.2k/local/bin/openssl s_server -cert cert.pem -key key.pem -accept 8787 -ssl3

# 連線 ssl3 server
~/openssl-1.0.2k/local/bin/openssl s_client -connect localhost:8787 -ssl3
```

