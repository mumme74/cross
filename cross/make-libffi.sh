#!/bin/bash

VERSION=3.4.4
PKG=libffi
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676
DOWNLOADURL=https://github.com/libffi/libffi/releases/download/v$VERSION/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
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
