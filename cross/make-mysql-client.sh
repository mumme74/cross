mysql-8.1.0.tar.gz

#!/bin/bash
MAJOR=8
MINOR=1
MICRO=0
VERSION=${MAJOR}.${MINOR}.$MICRO
PKG=mysql
FILENAME=$PKG-$VERSION
TARNAME=$FILENAME.tar.gz
MD5SUM=13fe8f9f463b2f462763cd21459590a0
DOWNLOADURL=https://dev.mysql.com/get/Downloads/MySQL-$MAJOR.$MINOR/$TARNAME

cd /opt/osxcross/cross
source common.sh

echo "Building $PKG"
cd src/$FILENAME

if [ ! -f "$SRC_DIR/$FILENAME/config.log" ] || [ "$FORCE" == true ]; then
  if [ -d "$SRC_DIR/$FILENAME-build" ]; then
    rm -Rf "$SRC_DIR/$FILENAME-build"
  fi
  mkdir -p "$SRC_DIR/$FILENAME-build"

  source "$CROSS_DIR/configCmakeForArch.sh"

  cd "$SRC_DIR/$FILENAME-build"

  cmake \
    -DWITHOUT_SERVER=ON \
    -DWITH_UNIT_TESTS=OFF \
    -DDOWNLOAD_BOOST=1 \
    -DWITH_BOOST=../$FILENAME/downloads/ \
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

