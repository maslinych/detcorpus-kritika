#!/bin/bash
archive_dir="$1"
shift
root_dir="$1"
shift
environment="testing"
chroot_dir=$root_dir/$environment
shopt -s nullglob
corpora=($archive_dir/*.tar.xz)

for corptar in "${corpora[@]}"
do
    ln -v "$corptar" "$chroot_dir"/chroot/.in/
    corpnames="$(cat "${corptar%%.tar.xz}".setup.txt | cut -d' ' -f2-)"
    for corpus in $corpnames
    do
        hsh-run --rooter "$chroot_dir" -- rm -rf /var/lib/manatee/{data,registry,vert}/$corpus
    done
    hsh-run --rooter "$chroot_dir" -- tar --no-same-permissions --no-same-owner -xJvf ${corptar##$archive_dir/} --directory /var/lib/manatee
    for corpus in $corpnames
    do
        hsh-run --rooter "$chroot_dir" -- /bin/sh -c "export MANATEE_REGISTRY=/var/lib/manatee/registry && mksizes $corpus"
    done
done

