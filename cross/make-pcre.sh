#!/bin/bash

VERSION=8.45
PKG=pcre
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.bz2
SHA256=4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8
DOWNLOADURL=https://downloads.sourceforge.net/project/pcre/pcre/$VERSION/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="configure --prefix=$USR_DIR \
    --host=$COMPILER_HOST \
    --with-sysroot=$USR_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=\" -I$USR_DIR/include\" \
    LDFLAGS=\"-L$USR_DIR/lib\" \
    --enable-shared \
    --enable-pcre16 \
    --enable-utf \
    --enable-unicode-properties \
    --enable-cpp \
    --disable-pcregrep-libz \
    --disable-pcregrep-libbz2 \
    --disable-pcretest-libreadline \
  "
start
