#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../settings
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
            -subj "/C=$C/ST=$ST/L=$L/O=f5-L$index/OU=pd-L$index/CN=f5-L$index/emailAddress=$emailAddress"

        openssl ca -create_serial -in testreq.pem $passin -config $ca_conf
        openssl rsa -in testkey.pem $passin -out testkey.pem.insecure
        
        cp testkey.pem.insecure keychain/ca-l$index.key
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > keychain/ca-l$index.crt

        cp testkey.pem private/cakey.pem
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > cacert.pem
    done
    
    while [ $server_number -gt 0 ]; do 

        n=$server_number
        server_number=$(($server_number - 1))

        openssl req -newkey rsa:2048 -keyout testkey.pem $passout -keyform PEM \
            -out testreq.pem -outform PEM \
            -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN/emailAddress=$emailAddress"

        openssl ca -create_serial -in testreq.pem $passin -config $cert_conf
        openssl rsa -in testkey.pem $passin -out testkey.pem.insecure

        cp testkey.pem.insecure keychain/server.key$n.key
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > keychain/server.crt$n.crt
    done

    while [ $additional_server_number -gt 0 ]; do 

        n=$additional_server_number
        additional_server_number=$(($additional_server_number - 1))

        openssl req -newkey rsa:2048 -keyout testkey.pem $passout -keyform PEM \
            -out testreq.pem -outform PEM \
            -subj "/C=$C/ST=$ST/L=$L/O=$O.s$n/OU=$OU.s$n/CN=$CN.s$n/emailAddress=$emailAddress"
    
        openssl ca -create_serial -in testreq.pem $passin -config $cert_conf
        openssl rsa -in testkey.pem $passin -out testkey.pem.insecure
    
        cp testkey.pem.insecure keychain/server.s$n.key
        sed '/^\ /d' certs/$(cat serial.old).pem | grep -v Certificate > keychain/server.s$n.crt

    done 

    set +x 
)

#$cdir/setup-nginx.sh

