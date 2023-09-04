#!/bin/bash

VERSION=3.0.10
PKG=openssl
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
SHA256=1761d4f5b13a1028b9b6f3d4b8e17feb0cedc9370f6afe61d7193d2cdce83323
DOWNLOADURL=https://www.openssl.org/source/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [[ ! -f "$SRC_DIR/$FILENAME/Makefile" || "$FORCE" == true ]]; then
  ./Configure \
    darwin64-x86_64-cc \
    shared \
    enable-ec_nistp_64_gcc_128 \
    no-comp \
    no-tests \
    --openssldir=$USR_DIR \
    --prefix=$USR_DIR \
    --sysroot=$TARGET_DIR \
    --cross-compile-prefix=x86_64-apple-darwin20.2-

  failOnConfigure $?
fi

make --jobs=$(nproc) JOBS=$(nproc) \
    CFLAGS="-I$TARGET_DIR/SDK/$SDK/usr/include" \
    LDFLAGS="-L$TARGET_DIR/SDK/$SDK/usr/lib"
failOnBuild $?

make install_sw PREFIX=$USR_DIR
failOnInstall $?

make install_ssldirs PREFIX=$USR_DIR
failOnInstall $?