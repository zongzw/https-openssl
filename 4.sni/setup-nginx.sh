#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/../settings
source $cdir/settings

server_crt=$cdir/gens/server.crt
server_key=$cdir/gens/server.key
srcdir=$cdir/gens/keychain

if [ ! -d $srcdir ]; then 
    echo no ca intermediate certs found. 
    exit 1
fi

cat $srcdir/server.key > $server_key
cat $srcdir/server.crt > $server_crt

count=`ls $srcdir/ca-l*.crt | wc -l | tr -d ' '`
while [ $count -gt 0 ]; do 
    cat $srcdir/ca-l$count.crt >> $server_crt
    count=$(($count - 1))
done

cat $srcdir/root.crt >> $server_crt

cp $server_key $server_crt $keypair_target

# ====== additional_servers ====== 

while [ $additional_server_number -gt 0 ]; do 

    n=$additional_server_number
    additional_server_number=$(($additional_server_number - 1))

    server_x_crt=$cdir/gens/server.s$n.crt
    server_x_key=$cdir/gens/server.s$n.key
    
    cat $srcdir/server.s$n.key > $server_x_key
    cat $srcdir/server.s$n.crt > $server_x_crt
    
    count=`ls $srcdir/ca-l*.crt | wc -l | tr -d ' '`
    while [ $count -gt 0 ]; do 
        cat $srcdir/ca-l$count.crt >> $server_x_crt
        count=$(($count - 1))
    done
    
    cat $srcdir/root.crt >> $server_x_crt
    
    cp $server_x_key $server_x_crt $keypair_target
    
    sed "s/\.x/.s$n/g" $cdir/443.x.conf > $keypair_target/443.s$n.conf
done 


$nginx_script

