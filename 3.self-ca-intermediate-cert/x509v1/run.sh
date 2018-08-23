#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../../settings

passout="-passout pass:default"
passin="-passin pass:default"

(
    mkdir -p $cdir/gens
    rm -rf $cdir/gens/*
    cd $cdir/gens

    openssl genrsa -des3 -out ca.key $passout 1024 
    openssl req -new -x509 -days 3650 -key ca.key $passin -out ca.crt \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=f5networks/OU=pd/CN=f5rootca.com/emailAddress=a.zong@f5.com" 
    openssl x509  -in  ca.crt -out ca.pem 

    openssl genrsa -des3 -out ca-int_encrypted.key $passout 1024
    openssl rsa -in ca-int_encrypted.key $passin -out ca-int.key 
    openssl req -new -key ca-int.key $passin -out ca-int.csr \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=f5china/OU=pd-21/CN=ca-int@f5.test.com/emailAddress=zongzhaowei-2002@163.com" 
    openssl x509 -req -days 3650 -in ca-int.csr -CA ca.crt -CAkey ca.key $passin \
        -set_serial $(randint) -out ca-int.crt 
    
    openssl genrsa -des3 -out server_encrypted.key $passout 1024 
    openssl rsa -in server_encrypted.key $passin -out server.key 
    openssl req -new -key server.key -out server.csr \
        -subj "/C=CN/ST=Beijing/L=Beijing/O=floor21/OU=pd-21/CN=localhost/emailAddress=test@test.com" 
    openssl x509 -req -days 3650 -in server.csr  -CA ca-int.crt -CAkey ca-int.key \
        -set_serial $(randint) -out server.crt
)
