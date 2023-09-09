#!/bin/bash

VERSION=10.42
PKG=pcre2
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.bz2
SHA256=8d36cd8cb6ea2a4c2bb358ff6411b0c788633a2a45dabbf1aeb4b701d1b5e840
DOWNLOADURL=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VERSION/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=$COMPILER_HOST \
  ./configure --prefix=$USR_DIR \
     --host=$COMPILER_HOST\
    --with-sysroot=$TARGET_DIR \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=" -I$USR_DIR/include/zlib" \
    LDFLAGS="-L$USR_DIR/lib" \
    --enable-shared \
    --enable-pcre2-16 \
    --enable-utf \
    --enable-unicode-properties \
    --enable-cpp \
    --disable-pcre2grep-libz \
    --disable-pcre2grep-libbz2 \
    --disable-pcre2test-libreadline

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?