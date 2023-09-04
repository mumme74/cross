#!/bin/bash

MAJOR=73
MINOR=2
VERSION=$MAJOR.$MINOR
PKG=icu4c
FILENAME=$PKG-${MAJOR}_${MINOR}-src
TARNAME=$FILENAME.tgz
MD5SUM=b8a4b8cf77f2e2f6e1341eac0aab2fc4
DOWNLOADURL=https://github.com/unicode-org/icu/releases/download/release-$MAJOR-$MINOR/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"

echo "-------------------------"
if [ ! -d $SRC_DIR/icu-build-host ] || \
   [ ! -f $SRC_DIR/icu-build-host/config.log ] || \
   [ "$FORCE" == true ]; then
  if [ "$FORCE" == true ]; then
    echo "cleaning host build on $PKG"
    rm -rf $SRC_DIR/icu-build-host
  fi

  echo "building $PKG host"
  mkdir -p $SRC_DIR/icu-build-host
  cd $SRC_DIR/icu-build-host
  rm -Rf *

  $SRC_DIR/icu/source/runConfigureICU Linux
  failOnError $? "Failed to configure $PKG host"

  make
  failOnError $? "Failed to make $PKG host"

  cd ../../
fi

echo "-------------------------"
if [ ! -d $SRC_DIR/icu-build-target ] || \
   [ ! -f $SRC_DIR/icu-build-target/config.log ] || \
   [ "$FORCE" == true ]; then
  if [ "$FORCE" == true ]; then
    echo "cleaning target build on $PKG"
    rm -rf $SRC_DIR/icu-build-target
  fi
  echo "building $PKG target"
  mkdir -p $SRC_DIR/icu-build-target
  cd $SRC_DIR/icu-build-target
  rm -Rf *
  $SRC_DIR/icu/source/configure \
    --host=x86_64-apple-darwin20.2 \
    --with-sysroot=$TARGET_DIR \
    --with-cross-build=$SRC_DIR/icu-build-host \
    --with-pic \
    CC=x86_64-apple-darwin20.2-cc \
    AR=x86_64-apple-darwin20.2-ar \
    STRIP=x86_64-apple-darwin20.2-strip \
    RANLIB=x86_64-apple-darwin20.2-ranlib \
    CFLAGS=" -I$USR_DIR/include/zlib" \
    LDFLAGS="-L$USR_DIR/lib" \
    --prefix=$USR_DIR \
    RELEASE_CFLAGS='-O2' \
    RELEASE_CXXFLAGS='-O2' \
    DEBUG_CFLAGS='-g -O0' \
    DEBUG_CXXFLAGS='-g -O0'

  failOnError $? "Failed to configure $PKG target"
else
  cd "$SRC_DIR/icu-build-target"
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnError $? "Failed to make $PKG target"

make install DESTDIR=$USR_DIR
failOnError $? "Failed to install $PKG target"
