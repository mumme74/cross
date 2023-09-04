#!/bin/bash

VERSION=8.1.1
PKG=harfbuzz
FILENAME=harfbuzz-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=0305ad702e11906a5fc0c1ba11c270b7f64a8f5390d676aacfd71db129d6565f
DOWNLOADURL=https://github.com/harfbuzz//harfbuzz/releases/download/$VERSION/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=x86_64-apple-darwin20.2 \
  ./configure --prefix=$USR_DIR \
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
