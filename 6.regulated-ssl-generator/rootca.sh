#!/bin/bash 

cdir=$(cd `dirname $0`; pwd)
source $cdir/rootca.setting

(
    cd $cdir
    mkdir -p $target
    cd $target
    rm rootca.crt rootca.key

    echo "basicConstraints=CA:TRUE" > ext.file

    openssl genrsa -out rootca.key $numbits
    openssl req -new -key rootca.key -out ca.csr \
        -subj "/C=$C/ST=$ST/O=$O/CN=$CN/emailAddress=$emailAddress"
    openssl x509 -req -in ca.csr -signkey rootca.key -out rootca.crt \
        -extfile ext.file

    rm ext.file ca.csr
)