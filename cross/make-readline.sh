#!/bin/bash

VERSION=8.2
PKG=readline
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35
DOWNLOADURL=https://ftp.gnu.org/gnu/readline/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=x86_64-apple-darwin20.2 \
  ./configure --prefix=/$USR_DIR\
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --enable-shared

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?
