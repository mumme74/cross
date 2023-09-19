#!/bin/bash

VERSION=2.14.2
PKG=fontconfig
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=3ba2dd92158718acec5caaf1a716043b5aa055c27b081d914af3ccb40dce8a55
DOWNLOADURL=https://www.freedesktop.org/software/fontconfig/release/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  autoreconf && automake --add-missing --copy --force-missing

  CHOST=${COMPILER_HOST} \
  ./configure --prefix=$USR_DIR \
    --host=${COMPILER_HOST} \
    --with-sysroot=$TARGET_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=" -I$USR_DIR/include -I$USR_DIR/include/freetype2" \
    LDFLAGS="-L$USR_DIR/lib" \
    FREETYPE_CFLAGS="-I$USR_DIR/include/freetype2" \
    FREETYPE_LIBS="-lfreetype" \
    --enable-shared

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?
