#!/bin/bash

VERSION=9e
PKG=jpeg
FILENAME=${PKG}src.v$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=4077d6a6a75aeb01884f708919d25934c93305e49f7e3f36db9129320e6f4f3d
DOWNLOADURL=https://www.ijg.org/files/$TARNAME
DIRNAME=jpeg-$VERSION

cd /opt/osxcross/cross
source common.sh

echo "Building libj$PKG"
cd src/$DIRNAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
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
make install
failOnInstall $?
