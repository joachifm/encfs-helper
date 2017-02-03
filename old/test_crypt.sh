#! /usr/bin/env bash

set -ex

prog=$PWD/crypt.pl

topdir=$(mktemp -d)
cd $topdir

perl $prog
test -d crypt
test -e crypt_key.gpg
test -e crypt/.encfs6.xml

mkdir mnt
encfs --extpass='gpg -d $PWD/crypt_key.gpg' $PWD/crypt $PWD/mnt
(
cd mnt
for s in $(seq 1 10) ; do
    dd if=/dev/urandom of=file$s.raw bs=512 count=4096
done
sha256sum --tag file*.raw >SHA256
)
fusermount -u $PWD/mnt

encfs --extpass='gpg -d $PWD/crypt_key.gpg' $PWD/crypt $PWD/mnt
(
cd mnt
sha256sum -c SHA256
)
fusermount -u $PWD/mnt

echo "ok" >&2
exit 0
