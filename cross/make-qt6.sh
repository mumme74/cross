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

cd /opt/osxcross/cross
source common.sh

if [ -z "$STEP" ] || [ $STEP == 1 ]; then
  if [ ! -d "$SRC_DIR/$FILENAME-build-host" ] || [ "$FORCE" -eq true ]; then
    rm -Rf "$SRC_DIR/$FILENAME-build-host" || true # when forcing a reconfigure
    echo "---- configuring Qt host bin tools"
    mkdir -p "$SRC_DIR/$FILENAME-build-host"
    cd "$SRC_DIR/$FILENAME-build-host"
    $SRC_DIR/$FILENAME/configure \
      -prefix $CROSS_DIR/host \
      -make libs \
      -make tools \
      -- \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF

    failOnConfigure $?
  else
    cd "$SRC_DIR/$FILENAME-build-host"
  fi
  echo "--- Building qt host bin tools"
  cmake --build . --parallel
  cmake --install .
  failOnBuild $?
fi

# build step 2
if [ -z "$STEP" ] || [ $STEP == 2 ]; then
  if [ ! -d "$SRC_DIR/$FILENAME-build-target" ] || \
     [ "$FORCE" == true ]; then
    echo "------------------------------"
    echo "Configuring qt for target macosx"

    incl=$USR_DIR/include

    echo $COMPILER_PREFIX

    rm -Rf "$SRC_DIR/$FILENAME-build-target" || true # when forcing a reconfigure
    mkdir -p "$SRC_DIR/$FILENAME-build-target"
    cd "$SRC_DIR/$FILENAME-build-target"
    $SRC_DIR/$FILENAME/qtbase/configure \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      NM=${COMPILER_PREFIX}nm \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS=" -I$incl -I$incl/harfbuzz -I$incl/fontconfig -I$incl/freetype2 \
             -I$incl/openssl -I$incl/textstyle \
             -I$incl/postgresql/internal -I$incl/postgresql/server \
             -I$incl/unixODBC -I$incl/mysql -I$incl/fontconfig \
             -I$incl/freetype2 -I$incl/harfbuzz -I$incl/textstyle \
             -I$incl/unicode -I$incl/lzma -I$incl/readline" \
      LDFLAGS="-L$USR_DIR/lib" \
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
      -enable-webengine-spellchecker \
      -enable-webengine-native-spellchecker \
      -enable-webengine-proprietary-codecs \
      -enable-webengine-webrtc \
      -- \
        -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake

      # -enable-cups \

      failOnConfigure $?
  else
    cd "$SRC_DIR/$FILENAME-build-target"
  fi

  cmake --build . --parallel
  failOnBuild $?

  cmake --install .
  failOnInstall $?
fi
