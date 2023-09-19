#!/bin/bash

TARGET_DIR=/opt/osxcross/target
CROSS_DIR=/opt/osxcross/cross
SDK=
SDK_lower=

cd $CROSS_DIR
source config.sh

setSdk() {
  #arg1 = sdk
  SDK=$1
  SDK_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
}

scriptpath=$0
ccompiler=
setSdk $( # default to build on the latest SDK
  ls /opt/osxcross/target/SDK |
  sort -nr -t X -k 2 |
  sed -e 's/^\s*\(.*\)\.sdk.*/\1/'
)

# parse arguments to script
while getopts ha: flag; do
    case "${flag}" in
        a) ccompiler=${OPTARG};;
        s) setSdk "${OPTARG}";;
        h)
          echo "$0 change the architecture to build target against, usage:"
          echo " $0 x86_64, $0 -a arm64 or $0 -a arm64e\n"
          echo "  -h    This help"
          echo "  -a    prefix complier with this,  Use either $0 [x86_64-|arm64-|arm64e-]"
          exit 0
    esac
done

if [ -z "$ccompiler" ]; then
  echo "**No architecture given." 1>&2
  exit 1
fi

paths=$(echo $PATH | tr ":" " ")
cc=
for path in $paths; do
  compg=$(compgen -G "$path/$ccompiler*-cc")
  ccpaths=("$path/$ccompiler" "${compg[@]}")
  for ccpath in "${ccpaths[@]}"; do
    if [ -f "$ccpath" ] && [ -x "$ccpath" ]; then
      cc=${ccpath##*/}
      echo "found=$cc"
      break
    fi
  done
  if [ ! -z "$cc" ]; then break; fi
done

$($cc --help &> /dev/null)
if [ $? -ne 0 ]; then
  echo "**C-compiler $ccompiler not found" 1>&2
  exit 1
fi

COMPILER_ARCH=$(echo $cc|sed -e "s/^\([^-]*\)-.*/\1/")
COMPILER_TO_SYSTEM=$(echo $cc|sed -e "s/^[^-]*-\([a-z_\-]*\).*/\1/")
DARWIN_VERSION=$(echo $cc|sed -e "s/^[^-]*-[a-z_\-]*\([0-9.]\+\).*/\1/")
echo "Setting compiler prefix to: $COMPILER_ARCH-${COMPILER_TO_SYSTEM}$DARWIN_VERSION"

TARGET_DIR_ESC=$(echo $TARGET_DIR | sed 's/\//\\\//g')

echo "Updating config"
# replacing with new COMPILER_PREFIX
mysrc=$(cat $CROSS_DIR/config.sh | \
        sed -e "s/^\(COMPILER_ARCH=\).*$/\1$COMPILER_ARCH/" \
            -e "s/^\(COMPILER_TO_SYSTEM=\).*$/\1$COMPILER_TO_SYSTEM/" \
            -e "s/^\(DARWIN_VERSION=\).*$/\1$DARWIN_VERSION/" \
            -e "s/^\(SDK_DIR=\).*$/\1$TARGET_DIR_ESC\/SDK\/$SDK.sdk/" \
            -e "s/^\(SDK_lower=\).*/\1$SDK_lower/"
      )
echo "$mysrc" > $CROSS_DIR/config.sh


echo "Updating make-qt6-toolchain.cmake"
# update toolchain file for cmake
mysrc=$(cat $CROSS_DIR/make-qt6-toolchain.cmake | \
      sed -e "s/^\(set(SDK_PATH \).*)$/\1$TARGET_DIR_ESC\/SDK\/$SDK.sdk)/" \
          -e "s/^\(set(CROSS_COMPILER \).*)$/\1$TARGET_DIR_ESC\/bin\/$COMPILER_HOST)/" \
          -e "s/^\(set(CMAKE_SYSTEM_PROCESSOR \).*)$/\1$COMPILER_ARCH)/"
      )
echo "$mysrc" > $CROSS_DIR/make-qt6-toolchain.cmake



