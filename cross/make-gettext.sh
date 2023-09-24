#!/bin/bash

VERSION=0.22
PKG=gettext
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=49f089be11b490170bbf09ed2f51e5f5177f55be4cc66504a5861820e0fb06ab
DOWNLOADURL=https://ftp.gnu.org/pub/gnu/gettext/$TARNAME
PATCH_FILE=gettext.patch
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
  --host=${COMPILER_HOST} \
  --with-sysroot=$TARGET_DIR \
  --with-pic \
  --enable-curses \
  CC=${COMPILER_PREFIX}cc \
  CXX=${COMPILER_PREFIX}c++ \
  NM=${COMPILER_PREFIX}nm \
  AR=${COMPILER_PREFIX}ar \
  STRIP=${COMPILER_PREFIX}strip \
  RANLIB=${COMPILER_PREFIX}ranlib \
  CFLAGS=\" -I$USR_DIR/include\" \
  LDFLAGS=\"-L$USR_DIR/lib\" \
  --prefix=$USR_DIR"

start
