#!/bin/bash

VERSION=3.0.10
PKG=openssl
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=1761d4f5b13a1028b9b6f3d4b8e17feb0cedc9370f6afe61d7193d2cdce83323
DOWNLOADURL=https://www.openssl.org/source/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  if [ ! -f "./config.log" ]; then
    arch=$COMPILER_ARCH
    [ "${arch::-1}" == "e" ] && arch=${arch:-1}
    [ "$arch" == "aarch64" ] && arch="arm64"

    ./Configure \
      darwin64-$arch-cc \
      shared \
      enable-ec_nistp_64_gcc_128 \
      no-comp \
      no-tests \
      --openssldir=$USR_DIR \
      --prefix=$USR_DIR \
      --sysroot=$TARGET_DIR \
      --cross-compile-prefix=$COMPILER_PREFIX \
    | tee config.log

    failOnConfigure $?
  fi
}
TARGET_CONFIG_FN=configFn

buildFn() {
  make --jobs=$(nproc) JOBS=$(nproc) \
      CFLAGS="-I$TARGET_DIR/SDK/$SDK/usr/include" \
      LDFLAGS="-L$TARGET_DIR/SDK/$SDK/usr/lib"
  failOnBuild $?
}
TARGET_BUILD_FN=buildFn

installFn() {
  make install_sw PREFIX=$USR_DIR
  failOnInstall $?

  make install_ssldirs PREFIX=$USR_DIR
  failOnInstall $?
}
TARGET_INSTALL_FN=installFn

start
