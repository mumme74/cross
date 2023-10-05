#!/bin/bash

VERSION=3.8
PKG=bison
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=1e0a14a8bf52d878e500c33d291026b9ebe969c27b3998d4b4285ab6dbce4527
DOWNLOADURL=http://ftp.acc.umu.se/mirror/gnu.org/gnu/bison/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure \
  --host=x86_64-apple-darwin20.2 \
  --with-sysroot=$TARGET_DIR \
  CC=${COMPILER_PREFIX}cc \
  CXX=${COMPILER_PREFIX}c++ \
  AR=${COMPILER_PREFIX}ar \
  STRIP=${COMPILER_PREFIX}strip \
  RANLIB=${COMPILER_PREFIX}ranlib \
  CFLAGS=\" -I$USR_DIR/include\" \
  LDFLAGS=\"-L$USR_DIR/lib\" \
  --prefix=$USR_DIR"

start
