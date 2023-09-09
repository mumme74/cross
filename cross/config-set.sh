#!/bin/bash

cd /opt/osxcross/cross
source config.sh

scriptpath=$0
ccompiler=$1
if [ -z "$ccompiler" ]; then
  echo "**No c-compiler given. Use either $0 [x86_64|arm64|arm64e]" 1>&2
  exit 1
elif [ "$ccompiler" == "--help" ]; then
  echo "$0 change the architecture to build target against, usage:"
  echo " $0 x86_64, $0 arm64 or $0 arm64e\n"
  exit 0
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

# replacing with new COMPILER_PREFIX
mysrc=$(cat config.sh | \
        sed -e "s/^\(COMPILER_ARCH=\).*$/\1$COMPILER_ARCH/" \
            -e "s/^\(COMPILER_TO_SYSTEM=\).*$/\1$COMPILER_TO_SYSTEM/" \
            -e "s/^\(DARWIN_VERSION=\).*$/\1$DARWIN_VERSION/" \
      )
echo "$mysrc" > config.sh

