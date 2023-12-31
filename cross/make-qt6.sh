#!/bin/bash

MAJOR=6
MINOR=5
MICRO=2
VERSION=$MAJOR.$MINOR.$MICRO
PKG=qt-everywhere-src
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
MD5SUM=87f56fd8aedd2e429047c40397e9be48
DOWNLOADURL=https://download.qt.io/archive/qt/$MAJOR.$MINOR/$VERSION/single/$TARNAME

HOST_BUILD=true # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

HOST_CONFIG_CMD="configure \
      -prefix $CROSS_DIR/host \
      -make libs \
      -make tools \
      -- \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
    "

HOST_BUILD_CMD="cmake --build . --parallel"
HOST_INSTALL_CMD="cmake --install ."
HOST_CLEAN_CMD="rm -rf *"

incl=$USR_DIR/include

TARGET_CONFIG_CMD="configure \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      NM=${COMPILER_PREFIX}nm \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=\" -I$incl \
             -I$incl/boost \
             -I$incl/event2 \
             -I$incl/fontconfig \
             -I$incl/freetype2 \
             -I$incl/harfbuzz \
             -I$incl/hunspell \
             -I$incl/libpng16 \
             -I$incl/libxml2 \
             -I$incl/lzma \
             -I$incl/mysql \
             -I$incl/ncursesw \
             -I$incl/openssl
             -I$incl/postgres \
             -I$incl/readline \
             -I$incl/textstyle \
             -I$incl/unicode \
             -I$incl/unixODBC \
             -I$incl/llvm \
             -I$incl/llvm-c \" \
      LDFLAGS=\"-L$USR_DIR/lib\" \
      -prefix $USR_DIR \
      -sysroot $TARGET_DIR \
      -qt-host-path $CROSS_DIR/host \
      -extprefix $USR_DIR/qt6 \
      -debug-and-release \
      -system-pcre \
      -enable-icu \
      -qt-zlib \
      -enable-ssl \
      -openssl-runtime \
      -system-freetype \
      -system-harfbuzz \
      -system-libpng \
      -system-libjpeg \
      -qt-sqlite \
      -enable-gif \
      -enable-cups \
      -enable-webengine-spellchecker \
      -enable-webengine-native-spellchecker \
      -enable-webengine-proprietary-codecs \
      -enable-webengine-webrtc \
      -- \
        -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DLLVM_INSTALL_DIR=$USR_DIR/ \
    "


TARGET_BUILD_CMD="cmake --build . --parallel"

TARGET_INSTALL_CMD="cmake --install ."

TARGET_CLEAN_CMD="rm -rf *"

start
