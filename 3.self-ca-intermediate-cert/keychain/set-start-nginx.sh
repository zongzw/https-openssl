#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source ../../settings

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
#for n in {-$count..-1}; do  # 0 - {-3..-1}: syntax error: operand expected (error token is "{-3..-1}")
#    echo $((0 - $n))
#    cat $srcdir/ca-l$((0 - $n)).crt >> $server_crt
#done

while [ $count -gt 0 ]; do 
    cat $srcdir/ca-l$count.crt >> $server_crt
    count=$(($count - 1))
done

cat $srcdir/root.crt >> $server_crt

cp $server_key $server_crt $keypair_target

$nginx_script

