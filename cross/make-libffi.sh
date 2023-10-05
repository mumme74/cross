#!/bin/bash

VERSION=3.4.4
PKG=libffi
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676
DOWNLOADURL=https://github.com/libffi/libffi/releases/download/v$VERSION/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\" -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --prefix=$USR_DIR \
  "

TARGET_INSTALL_CMD="make install PREFIX=$USR_DIR"

start
