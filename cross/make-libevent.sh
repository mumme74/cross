#!/bin/bash
# https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz


VERSION=2.1.12
PKG=libevent
FILENAME=$PKG-$VERSION-stable
TARNAME=$FILENAME.tar.gz
SHA256=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb
DOWNLOADURL=https://github.com/libevent/libevent/releases/download/release-$VERSION-stable/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME-build/config.log" || "$FORCE" == true ]]; then
  if [ -d "$SRC_DIR/$FILENAME-build" ]; then
    rm -Rf "$SRC_DIR/$FILENAME-build"
  fi
  mkdir -p "$SRC_DIR/$FILENAME-build"

  cd "$SRC_DIR/$FILENAME-build"

  cmake \
    -DCMAKE_INSTALL_PREFIX=$USR_DIR \
    -DWITHOUT_SERVER=ON \
    -DWITH_UNIT_TESTS=OFF \
    -DDOWNLOAD_BOOST=0 \
    -DWITH_BOOST=$SRC_DIR/boost_1_77_0 \
    -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake \
    "$SRC_DIR/$FILENAME"

  failOnConfigure $?
else
  cd "$SRC_DIR/$FILENAME-build"
fi

cmake --build . --parallel
failOnBuild $?

cmake --install . --prefix=$USR_DIR
failOnInstall $?
