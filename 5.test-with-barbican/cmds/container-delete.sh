#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/barbican.rc

$command secret container delete $@
