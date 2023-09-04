#!/bin/bash

VERSION=0.22
PKG=gettext
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=49f089be11b490170bbf09ed2f51e5f5177f55be4cc66504a5861820e0fb06ab
DOWNLOADURL=https://ftp.gnu.org/pub/gnu/gettext/$TARNAME
PATCHFILE=gettext.patch


cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/config.log" || "$FORCE" == true ]]; then
  ./configure \
  --host=x86_64-apple-darwin20.2 \
  --with-sysroot=$TARGET_DIR \
  --with-pic \
  --enable-curses \
  CC=x86_64-apple-darwin20.2-cc \
  NM=x86_64-apple-darwin20.2-nm \
  AR=x86_64-apple-darwin20.2-ar \
  STRIP=x86_64-apple-darwin20.2-strip \
  RANLIB=x86_64-apple-darwin20.2-ranlib \
  CFLAGS=" -I$USR_DIR/include" \
  LDFLAGS="-L$USR_DIR/lib" \
  --prefix=$USR_DIR

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc)
failOnBuild $?
make install PREFIX=$USR_DIR
failOnInstall $?