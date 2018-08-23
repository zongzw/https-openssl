#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../settings

(
    cd $cdir
    openssl genrsa -out server.key 2048
    
    openssl req -new -key server.key -out server.csr
    
    openssl x509 -req -in server.csr -signkey server.key -out server.crt
    
    cp server.crt server.key $keypair_target 
    
    $nginx_script
    
    mkdir -p gens
    rm -rf gens/*
    mv server.key server.crt server.csr gens
)
