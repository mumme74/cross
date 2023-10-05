#!/bin/bash

TARGET_DIR=/opt/osxcross/target
CROSS_DIR=/opt/osxcross/cross
SDK=
SDK_lower=

cd $CROSS_DIR
source config.sh

setSdk() {
  if [ ! -d "$TARGET_DIR/SDK/${1}.sdk" ]; then
    echo "SDK $1 not found!"
    exit 1
  fi
  #arg1 = sdk
  SDK=$1
  SDK_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
}

scriptpath=$0
ccompiler=
setSdk $( # default to build on the latest SDK
  ls /opt/osxcross/target/SDK |
  sort -nr -t X -k 2 |
  sed -e 's/^\s*\(.*\)\.sdk.*/\1/' |
  awk 'NR==1'
)

# parse arguments to script
while getopts ha:s: flag; do
    case "${flag}" in
        a) ccompiler=${OPTARG};;
        s) setSdk "${OPTARG}";;
        h)
          echo "$0 change the architecture to build target against, usage:"
          echo " $0 x86_64, $0 -a aarch64 or $0 -a arm64\n"
          echo "  -h    This help"
          echo "  -s    select specific sdk, ie: MacOSX13.3"
          echo "  -a    prefix complier with this,  Use either $0 [x86_64-|aarch64-|arm64-]"
          exit 0
    esac
done

if [ -z "$ccompiler" ]; then
  echo "**No architecture given." 1>&2
  exit 1
elif [ "${ccompiler:0:5}" == "arm64" ]; then
  echo "${ccompiler:0:5} not recomended, switching to aarch64 instead"
  ccompiler="aarch64${ccompiler:5}"
fi

paths=$(echo $PATH | tr ":" " ")
tgtPath="/opt/osxcross/target/bin"
[[ "${paths[@]}" =~ "$tgtPath" ]] || paths=("${paths[@]} $tgtPath")
cc=
for path in $paths; do
  compg=$(compgen -G "$path/$ccompiler*-cc")
  ccpaths=("$path/$ccompiler" "${compg[@]}")
  for ccpath in "${ccpaths[@]}"; do
    IFS=$'\n' ccpath=($(sort -nr <<<"${ccpath[*]}")); unset IFS
    for ccp in "${ccpath[@]}"; do
      if [ -f "$ccp" ] && [ -x "$ccp" ]; then
        cc=${ccp##*/}
        echo "found=$cc"
        break
      fi
    done
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
COMPILER_HOST=${COMPILER_ARCH}-${COMPILER_TO_SYSTEM}${DARWIN_VERSION}
COMPILER_PREFIX=$COMPILER_HOST-
echo "Setting compiler prefix to: $COMPILER_ARCH-${COMPILER_TO_SYSTEM}$DARWIN_VERSION"

PGK_CONFIG_DIR=$TARGET_DIR/$COMPILER_ARCH/usr/lib/pkgconfig

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

PKG_CONFIG_DIR_ESC=$(echo "$PKG_CONFIG_DIR" | sed 's/\//\\\//g')
bashrc_src=$(cat $HOME/.bashrc)
if [[ "$bashrc_src" != *"OSXCROSS_PKG_CONFIG_PATH"* ]]; then
  bashrc_src+=$'\nexport OSXCROSS_PKG_CONFIG_PATH=$PKG_CONFIG_DIR'
fi
bashrc_src=$(echo "$bashrc_src" | \
      sed -e "s/^\s*\(export OSXCROSS_PKG_CONFIG_PATH=\).*$/\1$PKG_CONFIG_DIR_ESC/" \
      )
echo "$bashrc_src" > $HOME/.bashrc

