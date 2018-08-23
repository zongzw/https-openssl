#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../settings

(
    mkdir -p $cdir/gens
    rm -rf $cdir/gens/*
    cd $cdir/gens
    openssl genrsa -out ca.key 2048
    openssl req -new -x509 -days 365 -key ca.key -out ca.crt
    
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -out server.csr
    openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial $(randint) -out server.crt
    
    cp server.crt server.key $keypair_target 
    
)
