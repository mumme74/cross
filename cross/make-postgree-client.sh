#!/bin/bash
#https://ftp.postgresql.org/pub/source/v15.4/postgresql-15.4.tar.bz2
VERSION=15.4
PKG=postgresql
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.bz2
SHA256=baec5a4bdc4437336653b6cb5d9ed89be5bd5c0c58b94e0becee0a999e63c8f9
DOWNLOADURL=https://ftp.postgresql.org/pub/source/v$VERSION/$TARNAME

HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

PREFIX=$USR_DIR/postgres-$VERSION
TARGET_CONFIG_CMD="configure \
      --prefix=$CROSS_DIR/host \
      --exec-prefix=$USR_DIR \
      --host=$COMPILER_HOST \
      --with-sysroot=$TARGET_DIR \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=\"-I$USR_DIR/include/zlib -L$USR_DIR/include -I$SDK_DIR/usr/include\" \
      LDFLAGS=\"-L$USR_DIR/lib -L$SDK_DIR/usr/lib\" \
      --includedir=$USR_DIR/include/pgsql \
      --oldincludedir=$USR_DIR/include/pgsql \
    "

dirs=("src/bin" "src/interfaces")

buildFn() {
  for dir in ${dirs[@]}; do
    echo "cd $TARGET_BUILD_DIR/$dir"
    cd "$TARGET_BUILD_DIR/$dir"

    # PG_SYSROOT=$TARGET_DIR
    # fails when compiling parallell, not sure why?
    make #--jobs=$(nproc) JOBS=$(nproc)
    failOnError "$?" "Failed to build $PKG $dir"
  done
}
TARGET_BUILD_FN=buildFn

installFn() {
  dirs=(${dirs[@]} "src/include")
  for dir in ${dirs[@]}; do
    cd "$TARGET_BUILD_DIR/$dir"
    make install
    failOnError "$?" "Failed to configure $PKG $dir"
  done
}
TARGET_INSTALL_FN=installFn

start
