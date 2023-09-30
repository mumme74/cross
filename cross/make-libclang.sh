#!/bin/bash

#https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.1/llvm-project-17.0.1.src.tar.xz
VERSION=17.0.1
PKG=llvm-project
FILENAME=$PKG-$VERSION.src
TARNAME=$FILENAME.tar.xz
SHA256=b0e42aafc01ece2ca2b42e3526f54bebc4b1f1dc8de6e34f46a0446a13e882b9
DOWNLOADURL=https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/$TARNAME
HOST_BUILD= # set true if host build required
OUT_OF_SRC_BUILD=true # set true if build target out of source

source $(dirname "$0")/common.sh

configFn() {
  pwd
  if [ ! -f "./config.log" ]; then
    cmake \
      -G"Unix Makefiles" \
      -DHAVE_STEADY_CLOCK=0 \
      -DLLVM_ENABLE_PROJECTS=clang \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$USR_DIR \
      -DWITH_UNIT_TESTS=OFF \
      -DCMAKE_TOOLCHAIN_FILE=$CROSS_DIR/make-qt6-toolchain.cmake \
      $SRC_DIR/$DIRNAME/llvm \
    | tee ./.config.log

    failOnConfigure $?

    mv .config.log config.log

    # clear extra min osx version
    for file in $(find "$TARGET_BUILD_DIR" -name "flags.make"); do
      STR=$(cat "$file" | sed -e "s/-mmacosx-version-min=10.9//")
      #echo "$STR" | grep "\-mmacosx-version-min="
      echo "$STR" > "$file"
    done
  fi
}
TARGET_CONFIG_FN=configFn

buildFn() {
  # must limit nr processes else it hangs. Bug in linux clang?
  cmake --build . --parallel $(($(nproc) / 2))
  failOnBuild $?
}
TARGET_BUILD_FN=buildFn

installFn() {
  cmake --install . --prefix=$USR_DIR
  failOnInstall $?
}
TARGET_INSTALL_FN=installFn

start
