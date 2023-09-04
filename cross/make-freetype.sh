#!/bin/bash

VERSION=2.13.2
PKG=freetype
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d
DOWNLOADURL=https://downloads.sourceforge.net/project/freetype/freetype2/$VERSION/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building freetype"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR \
    --enable-shared \
    HARFBUZZ_CFLAGS="-I$USR_DIR/include/harfbuzz" \
    LIBPNG_CFLAGS="-I$USR_DIR/include/libpng16"

  failOnError $? "Failed to configure $FILENAME"
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnError $? "Failed to build $PKG"
make install
failOnError $? "Failed to install $PKG"
