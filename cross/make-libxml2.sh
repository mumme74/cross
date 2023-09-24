#!/bin/bash

MINOR=2.11
VERSION=$MINOR.5
PKG=libxml2
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=3727b078c360ec69fa869de14bd6f75d7ee8d36987b071e6928d4720a28df3a6
DOWNLOADURL=https://download.gnome.org/sources/libxml2/$MINOR/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    --with-iconv=$USR_DIR \
    --with-zlib=$USR_DIR \
    --with-icu=$USR_DIR \
    --with-lzma=$USR_DIR \
    --without-python \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\"-O2 -fno-semantic-interposition -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --prefix=$USR_DIR
  "
start
