#!/bin/bash
VERSION=2.3.12
PKG=unixODBC
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
MD5SUM=d62167d85bcb459c200c0e4b5a63ee48
DOWNLOADURL=https://www.unixodbc.org/$TARNAME

HOST_BUILD=true # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

if [ ! -d "$HOST_BUILD_DIR" ] && [ ! -d "$TARGET_BUILD_DIR" ]; then
  cd $CROSS_DIR/src/$DIRNAME
  autoreconf && automake --add-missing --copy --force-missing
fi

HOST_CONFIG_CMD="configure --prefix=$CROSS_DIR/host"

TARGET_CONFIG_CMD="configure \
      --prefix=$CROSS_DIR/host \
      --exec-prefix=$USR_DIR \
      --host=$COMPILER_HOST \
      --with-sysroot=$TARGET_DIR \
      --includedir=$USR_DIR/include/unixodbc \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=\" -I$USR_DIR/include/zlib\" \
      LDFLAGS=\"-L$USR_DIR/lib\" \
      --enable-shared \
      --enable-utf8ini \
    "

start
