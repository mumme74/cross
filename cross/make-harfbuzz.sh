#!/bin/bash

VERSION=8.1.1
PKG=harfbuzz
FILENAME=harfbuzz-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=0305ad702e11906a5fc0c1ba11c270b7f64a8f5390d676aacfd71db129d6565f
DOWNLOADURL=https://github.com/harfbuzz//harfbuzz/releases/download/$VERSION/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  if [ ! -f "./config.log" ]; then
    autoreconf && automake --add-missing --copy --force-missing

    CHOST=$COMPILER_HOST \
    ./configure --prefix=$USR_DIR \
      --host=$COMPILER_HOST \
      --with-sysroot=$TARGET_DIR \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=" -I$USR_DIR/include" \
      LDFLAGS="-L$USR_DIR/lib" \
      --enable-shared

    failOnConfigure $?
  fi
}
TARGET_CONFIG_FN=configFn

start
