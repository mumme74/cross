#!/bin/bash

# https://github.com/apple/cups/releases/download/v2.3.3/cups-2.3.3-source.tar.gz


VERSION=2.3.3
PKG=cups
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME-source.tar.gz
SHA256=261fd948bce8647b6d5cb2a1784f0c24cc52b5c4e827b71d726020bcc502f3ee
DOWNLOADURL=https://github.com/apple/cups/releases/download/v$VERSION/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=$COMPILER_HOST \
  ./configure --prefix=$USR_DIR \
     --host=$COMPILER_HOST \
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