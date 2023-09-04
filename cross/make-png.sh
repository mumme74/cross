#!/bin/bash

VERSION=1.6.40
PKG=libpng
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=535b479b2467ff231a3ec6d92a525906fb8ef27978be4f66dbe05d3f3a01b3a1
DOWNLOADURL=https://download.sourceforge.net/libpng/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building png"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    --prefix=$USR_DIR

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
make install
