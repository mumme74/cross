#!/bin/bash

VERSION=1.17
PKG=libiconv
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313
DOWNLOADURL=https://ftp.gnu.org/gnu/$PKG/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $XZ"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install PREFIX=$USR_DIR
failOnInstall $?
