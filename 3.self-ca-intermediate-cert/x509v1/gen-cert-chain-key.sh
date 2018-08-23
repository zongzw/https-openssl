#!/bin/bash 

function randint() {
    rlt=`openssl rand -hex 4`
    printf "%d" 0x$rlt
}

cdir=`cd $(dirname $0); pwd`

(
    mkdir -p $cdir/gens
    rm -rf $cdir/gens/*
    cd $cdir/gens

    openssl genrsa -des3 -out ca.key 1024 
    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt  
    openssl x509  -in  ca.crt -out ca.pem 
    openssl genrsa -des3 -out ca-int_encrypted.key 1024 
    openssl rsa -in ca-int_encrypted.key -out ca-int.key 
    openssl req -new -key ca-int.key -out ca-int.csr -subj "/CN=ca-int@f5.test.com" 
    openssl x509 -req -days 3650 -in ca-int.csr -CA ca.crt -CAkey ca.key -set_serial $(randint) -out ca-int.crt 
    
    openssl genrsa -des3 -out server_encrypted.key 1024 
    openssl rsa -in server_encrypted.key -out server.key 
    openssl req -new -key server.key -out server.csr -subj "/CN=server@f5.test.com" 
    openssl x509 -req -days 3650 -in server.csr  -CA ca-int.crt -CAkey ca-int.key -set_serial $(randint) -out server.crt
)
