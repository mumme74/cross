#!/bin/bash

VERSION=1.3
PKG=zlib
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=8a9ba2898e1d0d774eca6ba5b4627a11e5588ba85c8851336eb38de4683050a7
DOWNLOADURL=https://zlib.net/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD= # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  if [ ! -f "./config.log" ]; then
    CHOST=$COMPILER_HOST \
    CFLAGS="-fPIC" \
    ./configure \
      --prefix=$USR_DIR \
      --enable-shared | \
    tee ./config.log

    failOnConfigure $?
  fi
}
TARGET_CONFIG_FN=configFn

start
