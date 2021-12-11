#!/bin/bash
environment="testing"
archive_dir="$1"
shift
root_dir="$1"
shift
corpus="$1"
shift
chroot_dir="$root_dir/$environment"
corptar="$archive_dir/$corpus.tar.xz"
rm -f "$chroot_dir/chroot/.in/${corptar##$archive_dir/}"
ln "$corptar" "$chroot_dir"/chroot/.in/
corpnames="$(cat ${corptar%%.tar.xz}.setup.txt | cut -d' ' -f2-)"
for corpus in $corpnames
do
    hsh-run --rooter "$chroot_dir" -- rm -rf "/var/lib/manatee/{data,registry,vert}/$corpus"
done
hsh-run --rooter "$chroot_dir" -- tar --no-same-permissions --no-same-owner -xJvf "${corptar##$archive_dir/}" --directory /var/lib/manatee
for corpus in $corpnames
do
    hsh-run --rooter "$chroot_dir" -- /bin/sh -c "export MANATEE_REGISTRY=/var/lib/manatee/registry && mksizes $corpus"
done
