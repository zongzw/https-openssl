#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../settings

(
    cd $cdir
    openssl genrsa -out ca.key 2048
    openssl req -new -x509 -days 365 -key ca.key -out ca.crt
    
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -out server.csr
    openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
    
    cp server.crt server.key $keypair_target 
    
    $nginx_script
    
    mkdir -p gens
    rm -rf gens/*
    mv server.key server.crt server.csr ca.crt ca.key gens
)
