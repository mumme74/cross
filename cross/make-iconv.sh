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
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install PREFIX=$USR_DIR
failOnInstall $?
