#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../../settings
source $cdir/settings

req_conf=$cdir/conf.d/req.conf
ca_conf=$cdir/conf.d/ca.conf
cert_conf=$cdir/conf.d/cert.conf

gens=$cdir/gens
mkdir -p $gens
rm -rf $gens/*

for n in $req_conf $ca_conf $cert_conf; do 
    echo -n > $n.back
    while read line; do 
        echo $line | grep "^dir = " > /dev/null
        if [ $? -eq 0 ]; then 
            echo dir = $cdir/gens >> $n.back
        else 
            echo $line >> $n.back
        fi
    done < $n
    
    rm -f $n
    mv $n.back $n

done 

(
    cd $gens

    mkdir -p keychain
    rm -f kechain/*
    
    rint=$(randint)
    touch index.txt
    echo $rint > serial
    mkdir private certs
    
    passin="-passin pass:default"
    passout="-passout pass:default"
    
    set -x 
    openssl req -x509 -newkey rsa -out cacert.pem $passout -outform PEM -days 356 -config $req_conf
    cp cacert.pem keychain/root.crt
    cp private/cakey.pem keychain/root.key
    
    index=0
    while [ $index -lt $intermediate_number ]; do
        echo generate level $index ca 
        index=$(($index + 1))
        openssl req -newkey rsa:2048 -keyout testkey.pem $passout -keyform PEM \
            -out testreq.pem -outform PEM \
            -subj "/C=CN/ST=beijing/L=beijing/O=f5-L$index/OU=pd-L$index/CN=f5-L$index/emailAddress=zongzhaowei-2002@163.com"

        openssl ca -create_serial -in testreq.pem $passin -config $ca_conf
        openssl rsa -in testkey.pem $passin -out testkey.pem.insecure
        
        cp testkey.pem.insecure keychain/ca-l$index.key
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > keychain/ca-l$index.crt

        cp testkey.pem private/cakey.pem
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > cacert.pem
    done
    
    set +x 
    
    openssl req -newkey rsa:2048 -keyout testkey.pem $passout -keyform PEM \
        -out testreq.pem -outform PEM \
        -subj "/C=CN/ST=beijing/L=beijing/O=f5-local/OU=pd-local/CN=localhost/emailAddress=zongzhaowei-2002@163.com"

    openssl ca -create_serial -in testreq.pem $passin -config $cert_conf
    openssl rsa -in testkey.pem $passin -out testkey.pem.insecure

    cp testkey.pem.insecure keychain/server.key
    sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > keychain/server.crt

)

