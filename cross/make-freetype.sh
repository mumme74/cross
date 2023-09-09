#!/bin/bash

VERSION=2.13.2
PKG=freetype
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d
DOWNLOADURL=https://downloads.sourceforge.net/project/freetype/freetype2/$VERSION/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=" -I$USR_DIR/include -I$USR_DIR/include/harfbuzz -I$USR_DIR/include/libpng16 -I$USR_DIR/include/lzma" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR \
    --enable-shared \
    HARFBUZZ_CFLAGS="-I$USR_DIR/include/harfbuzz" \
    LIBPNG_CFLAGS="-I$USR_DIR/include/libpng16" 2>&1 \
    | tee config.log

  failOnError $? "Failed to configure $FILENAME"
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnError $? "Failed to build $PKG"
make install
failOnError $? "Failed to install $PKG"
