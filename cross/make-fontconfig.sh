#!/bin/bash

VERSION=2.14.2
PKG=fontconfig
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=3ba2dd92158718acec5caaf1a716043b5aa055c27b081d914af3ccb40dce8a55
DOWNLOADURL=https://www.freedesktop.org/software/fontconfig/release/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  if [ ! -f "./config.log" ]; then
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
}
TARGET_CONFIG_FN=configFn

start
