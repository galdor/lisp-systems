#!/bin/sh

set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 <version>" >/dev/stderr
    exit 1
fi

version=$1

cd asdf

git fetch
git reset --hard $version

make
cp build/asdf.lisp ../
