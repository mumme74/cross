#!/bin/bash

MAJOR=6
MINOR=5
MICRO=2
VERSION=$MAJOR.$MINOR.$MICRO
PKG=qt-everywhere-src
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
MD5SUM=87f56fd8aedd2e429047c40397e9be48
DOWNLOADURL=https://download.qt.io/archive/qt/$MAJOR.$MINOR/$VERSION/single/$FILENAME

cd /opt/osxcross/cross
source common.sh

if [[ ! -d "$SRC_DIR/$FILENAME-build-host" || "$FORCE" == true ]]; then
  rm -Rf "$SRC_DIR/$FILENAME-build-host" || true # when forcing a reconfigure
  echo "---- configuring Qt host bin tools"
  mkdir -p "$SRC_DIR/$FILENAME-build-host"
  cd "$SRC_DIR/$FILENAME-build-host"
  $SRC_DIR/$FILENAME/configure \
    -prefix $CROSS_DIR/host/qt6 \
    -make libs \
    -make tools \
    -- \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++


  failOnConfigure $?
else
  cd "$SRC_DIR/$FILENAME-build-host"
fi
echo "--- Building qt host bin tools"
cmake --build . --parrallel
cmake --install .
failOnBuild $?


if [[ ! -d "$SRC_DIR/$FILENAME-build-target" || "$FORCE" == true ]]; then
  rm -Rf "$SRC_DIR/$FILENAME-build-target" || true # when forcing a reconfigure
  mkdir -p "$SRC_DIR/$FILENAME-build-target"
  cd "$SRC_DIR/$FILENAME-build-target"
  $SRC_DIR/$FILENAME/qtbase/configure \
    AS=x86_64-apple-darwin10.2-as \
    CC=x86_64-apple-darwin20.2-cc \
    NM=x86_64-apple-darwin20.2-nm \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include" \
    LDFLAGS="-L$USR_DIR/lib" \
    -prefix=$USR_DIR \
    -sysroot=$TARGET_DIR \
    -qt-host-path $CROSS_DIR/host/qt6 \
    -extprefix $USR_DIR/qt6 \
    -device macx-clang \
    -device-option x86_64-apple-darwin20.2- \
    -sysroot=/opt/osxcross/target
    -debug-and-release \
    -framework=yes \
    -pcre=system \
    -icu=system \
    -sdk $SDK
    -ssl \
    -openssl-linked=yes \
    -cups \
    -freetype=system \
    -harfbuzz=system \
    -libpng=system \
    -libjpeg=system \
    -sql=all \
    -tiff=qt \
    -webp=qt \
    -device=macx-clang \
    -webengine-icu=system \
    -- \
      -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake

    failOnConfigure $?
else
  cd "$SRC_DIR/$FILENAME-build"
fi

cmake --build . --parallel
failOnBuild $?

cmake --install .
failOnInstall $?
