#!/bin/bash

VERSION=1.0.8
PKG=bzip2
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
DOWNLOADURL=https://sourceware.org/pub/bzip2/$TARNAME


cd /opt/osxcross/cross
source common.sh
ls src
echo "Building $PKG"
cd src/$FILENAME

if [ "$FORCE" == true ]; then
  echo "Forcing rebuild"
  make clean
  failOnError $? "Failed to clean build before rebuild on $PKG"
fi

make libbz2.a bzip2 bzip2recover --jobs=$(nproc) JOBS=$(nproc) \
  PREFIX=$USR_DIR \
  CC=${COMPILER_PREFIX}cc \
  CXX=${COMPILER_PREFIX}c++ \
  AR=${COMPILER_PREFIX}ar \
  STRIP=${COMPILER_PREFIX}strip \
  RANLIB=${COMPILER_PREFIX}ranlib

failOnBuild $?

make install PREFIX=$USR_DIR
failOnInstall $?
