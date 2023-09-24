#!/bin/bash

VERSION=1.7.2
PKG=hunspell
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=11ddfa39afe28c28539fe65fc4f1592d410c1e9b6dd7d8a91ca25d85e9ec65b8
DOWNLOADURL=https://github.com/hunspell/hunspell/releases/download/v$VERSION/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  if [ ! -f "./config.log" ]; then
    autoreconf && automake --add-missing --copy --force-missing

    ./configure \
      --host=$COMPILER_HOST \
      --with-sysroot=$TARGET_DIR \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=" -I$USR_DIR/include -I$USR_DIR/include" \
      LDFLAGS="-L$USR_DIR/lib" \
      --prefix=$USR_DIR

  failOnConfigure $?
 fi
}
TARGET_CONFIG_FN=configFn

start
