#!/bin/bash

VERSION=8.2
PKG=readline
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35
DOWNLOADURL=https://ftp.gnu.org/gnu/readline/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure --prefix=$USR_DIR \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\" -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --enable-shared \
  "

start
