#!/bin/bash

cdir=$(cd `dirname $0`; pwd)
source $cdir/intermediate.setting

(
    cd $cdir
    mkdir -p $target
    rm -f $target/$file_pref*.crt $target/$file_pref*.key

    cp $rootca $target/$file_pref"0".crt
    cp $rootkey $target/$file_pref"0".key

    cd $target

    echo "basicConstraints=CA:TRUE" > ext.file

    cacert=$file_pref"0".crt
    cakey=$file_pref"0".key
    n=1;
    while [ $n -le $level_num ]; do
        openssl genrsa -out $file_pref$n.key $numbits
        openssl req -new -key $file_pref$n.key -out $file_pref$n.csr \
            -subj "/C=$C/ST=$ST/L=$L/O=$O_pref$n/CN=$CN_pref$n/emailAddress=$emailAddress"
        openssl x509 -req -in $file_pref$n.csr -out $file_pref$n.crt \
            -CA $cacert -CAkey $cakey \
            -extfile ext.file -CAcreateserial

        cacert="$file_pref$n.crt"
        cakey="$file_pref$n.key"
        n=$(($n + 1))
    done

    rm -f $file_pref*.csr ext.file $file_pref"0".crt $file_pref"0".key \
        $file_pref*.srl
)
