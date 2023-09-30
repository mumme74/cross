#!/bin/bash
MAJOR=8
MINOR=1
MICRO=0
VERSION=${MAJOR}.${MINOR}.$MICRO
PKG=mysql
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
MD5SUM=13fe8f9f463b2f462763cd21459590a0
DOWNLOADURL=https://dev.mysql.com/get/Downloads/MySQL-$MAJOR.$MINOR/$TARNAME
PATCH_FILE=mysql-client.patch

HOST_BUILD=true # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

HOST_CONFIG_CMD="cmake \
      -DCMAKE_INSTALL_PREFIX=$CROSS_DIR/host \
      -DWITHOUT_SERVER=ON \
      -DWITH_UNIT_TESTS=OFF \
      -DWITH_LIBEVENT=bundled \
      -DBOOST_INCLUDE_DIR=$USR_DIR/include \
      \"$SRC_DIR/$FILENAME\" | tee $HOST_BUILD_DIR/config.log \
    "

HOST_BUILD_CMD="cmake --build . --parallel"

HOST_INSTALL_CMD="cmake --install . --prefix=$CROSS_DIR/host"

TARGET_CONFIG_CMD="cmake \
      -DCMAKE_INSTALL_PREFIX=$USR_DIR \
      -DWITHOUT_SERVER=ON \
      -DWITH_UNIT_TESTS=OFF \
      -DWITH_LIBEVENT=system \
      -DENABLE_DTRACE=OFF \
      -DWITH_ZLIB=bundled \
      -DWITH_LIBTOOL=OFF \
      -DHAVE_GCC_ATOMIC_BUILTINS=1 \
      -DHOST_BUILD_DIR=$HOST_BUILD_DIR \
      -DLIBEVENT_INCLUDE_PATH=event2 \
      -DLIBEVENT_LIB_PATHS=/usr/lib \
      -DLIBEVENT_CORE=$USR_DIR/lib/libevent_core.dylib \
      -DLIBEVENT_EXTRA=$USR_DIR/lib/libevent_extra.dylib \
      -DLIBEVENT_PTHREADS=$USR_DIR/lib/libevent_pthreads.dylib \
      -DLIBEVENT_OPENSSL=$USR_LIB/lib/libevent_openssl.dylib \
      -DLIBEVENT_VERSION="2.1.12-stable" \
      -DBOOST_INCLUDE_DIR=$USR_DIR/include \
      -DOPENSSL_ROOT_DIR=$USR_DIR \
      -DOPENSSL_INCLUDE_DIR=$USR_DIR/include \
      -DOPENSSL_LIBRARY=$USR_DIR/lib/libssl.3.dylib \
      -DOPENSSL_CRYPTO_LIBRARY=$USR_DIR/lib/libcrypto.3.dylib \
      -DCRYPTO_LIBRARY=$USR_DIR/lib/libcrypto.3.dylib \
      -DCURSES_INCLUDE_PATH=$USR_DIR/include \
      -DCURSES_LIBRARY=$USR_DIR/lib/libncursesw.6.dylib \
      -DHAVE_CLOCK_GETTIME_EXITCODE=0 \
      -DHAVE_CLOCK_GETTIME_EXITCODE__TRYRUN_OUTPUT=0 \
      -DHAVE_CLOCK_REALTIME_EXITCODE=0 \
      -DHAVE_CLOCK_REALTIME_EXITCODE__TRYRUN_OUTPUT=0 \
      -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake \
    "
    # "$SRC_DIR/$FILENAME" | tee $TARGET_BUILD_DIR/config.log

TARGET_BUILD_CMD="cmake --build . --parallel"

TARGET_INSTALL_CMD="cmake --install . --prefix=$USR_DIR"

start
