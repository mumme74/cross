#!/bin/bash

MAJOR=73
MINOR=2
VERSION=$MAJOR.$MINOR
PKG=icu4c
FILENAME=$PKG-${MAJOR}_${MINOR}-src
TARNAME=$FILENAME.tgz
MD5SUM=b8a4b8cf77f2e2f6e1341eac0aab2fc4
DOWNLOADURL=https://github.com/unicode-org/icu/releases/download/release-$MAJOR-$MINOR/$TARNAME
DIRNAME=icu
HOST_BUILD=true # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

hostConfigFn() {
  if [ ! -f "./config.log" ]; then
    cd $SRC_DIR/icu/source
    autoreconf && automake --add-missing --copy --force-missing
    cd $HOST_BUILD_DIR

    chmod +x $SRC_DIR/icu/source/configure
    $SRC_DIR/icu/source/configure \
      --prefix=$CROSS_DIR/host/ \
      RELEASE_CFLAGS='-O2' \
      RELEASE_CXXFLAGS='-O2'

    failOnError $? "Failed to configure $PKG host"
  fi
}
HOST_CONFIG_FN=hostConfigFn


# build step 2
targetConfigFn() {
  if [ ! -f "./config.log" ]; then
    cd $SRC_DIR/icu/source
    autoreconf && automake --add-missing --copy --force-missing
    cd $TARGET_BUILD_DIR

    $SRC_DIR/icu/source/configure \
      --host=$COMPILER_HOST \
      --with-sysroot=$TARGET_DIR \
      --with-cross-build=$HOST_BUILD_DIR \
      --with-pic \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=" -I$USR_DIR/include/zlib" \
      LDFLAGS="-L$USR_DIR/lib" \
      --prefix=$USR_DIR \
      RELEASE_CFLAGS='-O2' \
      RELEASE_CXXFLAGS='-O2' \
      DEBUG_CFLAGS='-g -O0' \
      DEBUG_CXXFLAGS='-g -O0'

    failOnError $? "Failed to configure $PKG target"
  fi
}
TARGET_CONFIG_FN=targetConfigFn

start
