#!/bin/bash
#https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz

MAJOR=1
MINOR=77
MICRO=0
VERSION=$MAJOR.$MINOR.$MICRO
PKG=boost
FILENAME=${PKG}_$(echo $VERSION |sed 's/\./_/g' )
TARNAME=$FILENAME.tar.bz2
SHA256=5347464af5b14ac54bb945dc68f1dd7c56f0dad7262816b956138fc53bcc0131
DOWNLOADURL=https://boostorg.jfrog.io/artifactory/main/release/$VERSION/source/$TARNAME

cd /opt/osxcross/cross
source common.sh

HOST_BUILD_DIR="$SRC_DIR/$FILENAME-build-host"
TARGET_BUILD_DIR="$SRC_DIR/$FILENAME-build-target"

echo "Building $PKG"
cd src/$FILENAME

if [ -z "$STEP" ] || [ "$STEP" == 1 ]; then
  echo "---------------------------"
  echo " Building host $PKG"

  if [ ! -f "$HOST_BUILD_DIR/project-config.jam" ] || [ "$FORCE" == true ]; then
    if [ "$FORCE" == true ] && [ -d "$HOST_BUILD_DIR" ]; then
      rm -rf "$HOST_BUILD_DIR"
    fi

    mkdir -p "$HOST_BUILD_DIR"
    cd "$HOST_BUILD_DIR"

    ../$FILENAME/bootstrap.sh \
      --with-toolset=clang \
      --without-libraries=python \
      --prefix=$SRC_DIR/host/

    failOnConfigure $?
  fi

  cd ../$FILENAME
  $HOST_BUILD_DIR/b2 install \
    toolset=clang \
    --build-dir=$HOST_BUILD_DIR \
    --without-python \
    --prefix=$SRC_DIR/host \
    -j$(nproc)

  failOnInstall $?

  echo "Done build and install host $PKG\ninto:$SRC_DIR/host"
fi


if [ -z "$STEP" ] || [ "$STEP" == 2 ]; then
  echo "-----------------------------------------"
  echo " Building target $PKG"
  if [ ! -f "$TARGET_BUILD_DIR/project-config.jam" ] || [ "$FORCE" == true ]; then
    if [ -d "$TARGET_BUILD_DIR" ] && [ "$FORCE" == true ]; then
      rm -rf "$TARGET_BUILD_DIR"
    fi
    mkdir -p "$TARGET_BUILD_DIR"
    cd "$TARGET_BUILD_DIR"

    incl=$USR_DIR/include

    ../$FILENAME/bootstrap.sh --prefix=$USR_DIR \
      --with-toolset=clang \
      --with-icu=$USR_DIR/lib \
      CC=${COMPILER_PREFIX}cc \
      CXX=${COMPILER_PREFIX}c++ \
      AR=${COMPILER_PREFIX}ar \
      STRIP=${COMPILER_PREFIX}strip \
      RANLIB=${COMPILER_PREFIX}ranlib \
      CFLAGS="--sysroot=$TARGET_DIR  -I$incl -I$incl/harfbuzz -I$incl/fontconfig -I$incl/freetype2 \
             -I$incl/openssl -I$incl/textstyle \
             -I$incl/postgresql/internal -I$incl/postgresql/server \
             -I$incl/unixODBC \
             -I$incl/unicode -I$incl/lzma -I$incl/readline" \
      CXXFLAGS="--std=c++11" \
      LDFLAGS="--sysroot=$TARGET_DIR -L$USR_DIR/lib"

    failOnConfigure $?

  else
    cd "$TARGET_BUILD_DIR"
  fi

  cd ../$FILENAME

  usrConfigJam= "using clang-darwin : osxcross : \n"
  usrConfigJam+="  $TARGET_DIR/bin/${COMPILER_PREFIX}c++ :\n"
  usrConfigJam+="    <compilerflags>--sysroot=$TARGET_DIR $USR_INCLUDES \n"
  usrConfigJam+="    <linkflags>$USR_LIB_PATHS\n"
  usrConfigJam+="    <archiver>$TARGET_DIR/bin/${COMPILER_PREFIX}ar \n"
  usrConfigJam+="    <ranlib>$TARGET_DIR/bin/${COMPILER_PREFIX}ranlib \n"
  usrConfigJam+=";"
  echo -e "$usrConfigJam" > $SRC_DIR/$FILENAME/tools/build/src/user-config.jam


  $TARGET_BUILD_DIR/b2 install \
    toolset=clang-darwin-osxcross \
    target-os=darwin \
    -q -d+2\
    architecture=${COMPILER_ARCH:0:3} \
    address-model=64 \
    abi=aapcs \
    asmflags="--target=$COMPILER_HOST" \
    cflags="--target=$COMPILER_HOST" \
    cxxflags="--target=$COMPILER_HOST" \
    linkflags="--target=$COMPILER_HOST" \
    link=static,shared \
    threading=multi \
    binary-format=mach-o \
    --cxx=${COMPILER_PREFIX}c++ \
    --as=${COMPILER_PREFIX}as \
    --cc=${COMPILER_PREFIX}cc \
    --ar=${COMPILER_PREFIX}ar \
    --strip=${COMPILER_PREFIX}strip \
    --ranlib=${COMPILER_PREFIX}ranlib \
    --build-dir=$TARGET_BUILD_DIR \
    --without-python \
    --prefix=$USR_DIR \
    -j$(nproc)

  failOnInstall $?
fi