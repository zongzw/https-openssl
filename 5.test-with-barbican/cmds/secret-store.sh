#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/barbican.rc

if [ $# -lt 1 ]; then 
    echo "Usage: $0 <file1> <file2> .."
    exit 1
fi

for n in $@; do 
    echo $n
    $command secret store --name $n --payload-content-type "text/plain" --payload "$(cat $n)"
done 
