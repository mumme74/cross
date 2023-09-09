#!/bin/bash
VERSION=2.3.12
PKG=unixODBC
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
MD5SUM=d62167d85bcb459c200c0e4b5a63ee48
DOWNLOADURL=https://www.unixodbc.org/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  CHOST=$COMPILER_host \
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
    --enable-utf \
    --enable-unicode-properties \
    --enable-cpp \

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?