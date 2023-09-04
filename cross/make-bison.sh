#!/bin/bash

VERSION=3.8
PKG=bison
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.xz
SHA256=1e0a14a8bf52d878e500c33d291026b9ebe969c27b3998d4b4285ab6dbce4527
DOWNLOADURL=http://ftp.acc.umu.se/mirror/gnu.org/gnu/bison/$TARNAME


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
 ./configure \
  --host=x86_64-apple-darwin20.2 \
  --with-sysroot=$TARGET_DIR \
  CC=x86_64-apple-darwin20.2-cc \
  AR=x86_64-apple-darwin20.2-ar \
  STRIP=x86_64-apple-darwin20.2-strip \
  RANLIB=x86_64-apple-darwin20.2-ranlib \
  CFLAGS=" -I$USR_DIR/include" \
  LDFLAGS="-L$USR_DIR/lib" \
  --prefix=$USR_DIR

  failOnError $? "Failed to configure $FILENAME"
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnError $? "Failed to build $PKG"
make install
failOnError $? "Failed to install $PKG"
