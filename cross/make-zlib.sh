#!/bin/bash

VERSION=1.3
PKG=zlib
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=8a9ba2898e1d0d774eca6ba5b4627a11e5588ba85c8851336eb38de4683050a7
DOWNLOADURL=https://zlib.net/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=x86_64-apple-darwin20.2 \
  CFLAGS="-fPIC" \
  ./configure \
    --prefix=$USR_DIR \
    --enable-shared

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?
