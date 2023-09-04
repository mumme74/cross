#!/bin/bash

VERSION=1.7.2
PKG=hunspell
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=11ddfa39afe28c28539fe65fc4f1592d410c1e9b6dd7d8a91ca25d85e9ec65b8
DOWNLOADURL=https://github.com/hunspell/hunspell/releases/download/v$VERSION/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building hunspell"
cd src/$FILENAME


if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR

 failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install PREFIX=$USR_DIR
failOnInstall $?
