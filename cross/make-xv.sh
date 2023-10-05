#!/bin/bash

VERSION=5.4.3
PKG=xz
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=1c382e0bc2e4e0af58398a903dd62fff7e510171d2de47a1ebe06d1528e9b7e9
DOWNLOADURL=https://tukaani.org/$PKG/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\" -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --prefix=$USR_DIR
  "
TARGET_CLEAN_CMD="rm -rf *"

start
