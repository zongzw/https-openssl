#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/barbican.rc

for n in $@; do 
    $command secret delete $n
done
