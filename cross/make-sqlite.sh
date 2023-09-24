#!/bin/bash

VERSION=3430000
YEAR=2023
PKG=sqlite-autoconf
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=49008dbf3afc04d4edc8ecfc34e4ead196973034293c997adad2f63f01762ae1
DOWNLOADURL=https://www.sqlite.org/$YEAR/$TARNAME

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
    CFLAGS=\" -I$USR_DIR/include/zlib\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --enable-shared \
    --enable-pcre2-16 \
    --enable-utf \
    --enable-unicode-properties \
    --enable-cpp \
    --disable-pcre2grep-libz \
    --disable-pcre2grep-libbz2 \
    --disable-pcre2test-libreadline \
  "

start
