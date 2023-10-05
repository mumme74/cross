#!/bin/bash
#https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz

MAJOR=1
MINOR=77
MICRO=0
VERSION=$MAJOR.$MINOR.$MICRO
PKG=boost
FILENAME=${PKG}_$(echo $VERSION |sed 's/\./_/g' )
TARNAME=$FILENAME.tar.bz2
SHA256=fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854
DOWNLOADURL=https://boostorg.jfrog.io/artifactory/main/release/$VERSION/source/$TARNAME
HOST_BUILD=true # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

hostConfigFn() {
  cd $HOST_BUILD_DIR
  if [ ! -f "./b2" ] || [ "$FORCE" == true ]; then
    echo "---------------------------"
    echo " configure host $PKG"

    ../$FILENAME/bootstrap.sh \
      --with-toolset=clang \
      --without-libraries=python \
      --prefix=$CROSS_DIR/host/

    failOnConfigure $?
  fi
}
HOST_CONFIG_FN=hostConfigFn

hostBuildFn() {
  if [ -f "$HOST_BUILD_DIR/build.log" ]; then return 0; fi

  cd ../$FILENAME
  # remove possible previous target config
  if [ -f "$SRC_DIR/$FILENAME/tools/build/src/user-config.jam" ]; then
    rm "$SRC_DIR/$FILENAME/tools/build/src/user-config.jam"
  fi

  $HOST_BUILD_DIR/b2 install \
    toolset=clang \
    -q -d2 \
    --build-dir=$HOST_BUILD_DIR \
    --without-python \
    --prefix=$CROSS_DIR/host \
    -j$(nproc) \
    | tee $HOST_BUILD_DIR/.build.log

  failOnInstall $?

  mv $HOST_BUILD_DIR/.build.log $HOST_BUILD_DIR/build.log

  echo "Done build and install host $PKG\ninto:$SRC_DIR/host"
}
HOST_BUILD_FN=hostBuildFn

stubFn() {
  echo "null">/dev/null
}
HOST_INSTALL_FN=stubFn # intentional stub
HOST_CLEAN_CMD="rm -rf *"


targetConfigFn() {
  if [ ! -f "./b2" ] ||  [ "$FORCE" == true ]; then
    echo "-----------------------------------------"
    echo " Configure target $PKG"

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
      CXXFLAGS="--std=c++20" \
      LDFLAGS="--sysroot=$TARGET_DIR -L$USR_DIR/lib"

    failOnConfigure $?
  fi
}
TARGET_CONFIG_FN=targetConfigFn

targetBuildFn() {
  if [ -f "$TARGET_BUILD_DIR/build.log" ]; then return 0; fi
  cd $TARGET_BUILD_DIR

  cd ../$FILENAME

   usrConfigJam="using clang-darwin : osxcross : \n\
    $TARGET_DIR/bin/${COMPILER_PREFIX}c++ :\n\
      <compilerflags>--sysroot=$TARGET_DIR $USR_INCLUDES \n\
      <linkflags>$USR_LIB_PATHS\n\
      <archiver>$TARGET_DIR/bin/${COMPILER_PREFIX}ar \n\
      <ranlib>$TARGET_DIR/bin/${COMPILER_PREFIX}ranlib \n\
  ;"
  echo -e "$usrConfigJam" > $SRC_DIR/$FILENAME/tools/build/src/user-config.jam

  ARCH=${COMPILER_ARCH:0:3}
  ARCH=${ARCH/aar/arm}

  $TARGET_BUILD_DIR/b2 install \
    toolset=clang-darwin-osxcross \
    target-os=darwin \
    -q -d+2\
    architecture=${ARCH} \
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
    -j$(nproc) \
    | tee $TARGET_BUILD_DIR/.build.log

  failOnInstall $?

  mv $TARGET_BUILD_DIR/.build.log $TARGET_BUILD_DIR/build.log
}
TARGET_BUILD_FN=targetBuildFn

TARGET_INSTALL_FN=stubFn #intentional stub

TARGET_CLEAN_CMD="rm -rf *"

start
