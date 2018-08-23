#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../../settings

openssl_conf=$cdir/openssl.conf
echo -n > $openssl_conf.back
while read line; do 
    echo $line | grep "^dir = " > /dev/null
    if [ $? -eq 0 ]; then 
        echo dir = $cdir/gens >> $openssl_conf.back
    else 
        echo $line >> $openssl_conf.back
    fi
done < $openssl_conf

rm -f $openssl_conf
mv $openssl_conf.back $openssl_conf
(
    rm -rf $cdir/gens
    mkdir -p $cdir/gens
    cd $cdir/gens
    
    rint=$(randint)
    touch index.txt
    echo $rint > serial
    mkdir private certs
    
    passin="-passin pass:default"
    passout="-passout pass:default"
    
    set -x 
    openssl req -x509 -newkey rsa -out cacert.pem $passout -outform PEM -days 356 -config $openssl_conf
    
    openssl req -newkey rsa:2048 -keyout testkey.pem $passout -keyform PEM -out testreq.pem -outform PEM -subj "/C=CN/ST=beijing/L=beijing/O=f5/OU=pd-21/CN=localhost/emailAddress=zongzhaowei-2002@163.com"
    
    openssl ca -in testreq.pem $passin -config $openssl_conf 
    
    openssl rsa -in testkey.pem $passin -out testkey.pem.insecure
    
    set +x 
    
    cp testkey.pem.insecure $keypair_target/server.key
    sed '/^\ /d' certs/$rint.pem | grep -v Certificate > $keypair_target/server.crt

)

