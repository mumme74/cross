#!/bin/bash
COMPILER_ARCH=x86_64
COMPILER_TO_SYSTEM=apple-darwin
DARWIN_VERSION=20.2
COMPILER_HOST=${COMPILER_ARCH}-${COMPILER_TO_SYSTEM}${DARWIN_VERSION}
COMPILER_PREFIX=$COMPILER_HOST-
SDK_DIR=/opt/osxcross/target/SDK/*
SDK_lower=*

