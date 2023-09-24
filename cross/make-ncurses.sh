#!/bin/bash

VERSION=6.4
PKG=ncurses
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159
DOWNLOADURL=https://ftp.gnu.org/gnu/ncurses/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    --with-shared \
    --with-cxx-shared \
    --without-ada \
    --disable-stripping \
    --enable-widec \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\" -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --prefix=$USR_DIR \
  "

start
