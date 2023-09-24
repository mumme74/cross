#!/bin/bash
# https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz


VERSION=2.1.12
PKG=libevent
FILENAME=$PKG-$VERSION-stable
TARNAME=$FILENAME.tar.gz
SHA256=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb
DOWNLOADURL=https://github.com/libevent/libevent/releases/download/release-$VERSION-stable/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

TARGET_CONFIG_CMD="cmake \
    -DCMAKE_INSTALL_PREFIX=$USR_DIR \
    -DWITHOUT_SERVER=ON \
    -DWITH_UNIT_TESTS=OFF \
    -DDOWNLOAD_BOOST=0 \
    -DWITH_BOOST=$SRC_DIR/boost_1_77_0 \
    -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake \
  "

buildFn() {
  cmake --build . --parallel
  failOnBuild $?
}
TARGET_BUILD_FN=buildFn

installFn() {
  cmake --install . --prefix=$USR_DIR
  failOnInstall $?
}
TARGET_INSTALL_FN=installFn

start
