#!/bin/bash 

cdir=`cd $(dirname $0); pwd`
source $cdir/barbican.rc

if [ $# -ne 4 ]; then 
    echo "Usage: $0 <name> certificate=<certificate name> private_key=<private key> intermediates=<intermediate name>"
    exit 0
fi

#name="container-$(date +%H%M)"
name=$1
shift 

contentlist=
for n in $@; do 
    k=`echo $n | cut -d '=' -f 1`
    v=`echo $n | cut -d '=' -f 2`
    href=`$command secret list --name "$v" -f csv -c "Secret href" | grep http | tr -d '"'`
    contentlist="$contentlist --secret $k=$href"
done

$command secret container create --name $name --type "certificate" $contentlist
