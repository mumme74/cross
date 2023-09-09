#!/bin/bash

TARGET_DIR_ESC=$(echo $TARGET_DIR | sed 's/\//\\\//g')
cat $CROSS_DIR/make-qt6-toolchain.cmake \
    | sed -e "s/^set(SDK_PATH .*)/set(SDK_PATH $TARGET_DIR_ESC\/SDK\/$SDK\/)/" \
          -e "s/^\(set(CROSS_COMPILER /opt/osxcross/target/bin/ \).\+)/\1$COMPILER_HOST)/" \
          -e "s/^\(set(CMAKE_SYSTEM_PROCESSOR \).\+)/\1/)"     \
    > $CROSS_DIR/make-qt6-toolchain.cmake
