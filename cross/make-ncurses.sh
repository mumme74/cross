#!/bin/bash

VERSION=6.4
PKG=ncurses
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159
DOWNLOADURL=https://ftp.gnu.org/gnu/ncurses/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
    --host=$COMPILER_HOST \
    --with-sysroot=$TARGET_DIR \
    --with-pic \
    --with-shared \
    --with-cxx-shared \
    --without-ada \
    --disable-stripping \
    --enable-widec \
    CC=${COMPILER_PREFIX}cc \
    CXX=${COMPILER_PREFIX}c++ \
    AR=${COMPILER_PREFIX}ar \
    STRIP=${COMPILER_PREFIX}strip \
    RANLIB=${COMPILER_PREFIX}ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install PREFIX=$USR_DIR
failOnInstall $?
