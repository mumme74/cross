#!/bin/bash
#https://ftp.postgresql.org/pub/source/v15.4/postgresql-15.4.tar.bz2
VERSION=15.4
PKG=postgresql
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.bz2
SHA256=baec5a4bdc4437336653b6cb5d9ed89be5bd5c0c58b94e0becee0a999e63c8f9
DOWNLOADURL=https://ftp.postgresql.org/pub/source/v$VERSION/$TARNAME

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
    --enable-utf \
    --enable-unicode-properties \
    --enable-cpp \

  failOnConfigure $?
fi

cd src/interfaces/

make PG_SYSROOT=$SDK_PATH --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install
failOnInstall $?

#cd $CROSS_DIR/src/$FILENAME/src/include
#make install
#failOnInstall $?