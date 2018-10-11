#!/bin/bash

cdir=$(cd `dirname $0`; pwd)
source $cdir/keypair.setting

(
    cd $cdir
    mkdir -p $target
    rm -f $target/$file_pref.crt $target/$file_pref.key

    cp $cacrt $target/ca_tmp.crt
    cp $cakey $target/ca_tmp.key

    cd $target
    
    openssl genrsa -out $file_pref.key $numbits
    openssl req -new -key $file_pref.key -out $file_pref.csr \
        -subj "/C=$C/ST=$ST/CN=$CN/emailAddress=$emailAddress"
    openssl x509 -req -in $file_pref.csr -out $file_pref.crt \
        -CA ca_tmp.crt -CAkey ca_tmp.key -CAcreateserial

    rm -f ca_tmp.crt ca_tmp.key $file_pref.csr *.srl
)
