#!/bin/sh
archive_dir="$1"
shift
root_dir="$1"
shift
environment="testing"
chroot_dir="$root_dir/$environment"
cp -v bin/setup-bonito.sh "$chroot_dir"/chroot/.in/
cat $archive_dir/*.setup.txt | \
    awk '{for (i=2;i<=NF;i++) {corp[$1]=corp[$1]" "$i}}END{for (c in corp) {print c, corp[c]}}' | \
    xargs -t -L 1 hsh-run --root "$chroot_dir" -- sh setup-bonito.sh 
