#!/bin/bash

SDK=$( # default to build on the latest SDK
  ls /opt/osxcross/target/SDK |
  sort -nr -t X -k 2 |
  sed -e 's/^\s*\(.*\)\.sdk.*/\L\1/'
)
FORCE=
STEP=

# parse arguments to script
while getopts fS:hs: flag
do
    case "${flag}" in
        f) FORCE=true;;
        S) STEP=${OPTARG};;
        s) SDK=${OPTARG};;
        h)
          echo "$0 [options]"
          echo "  -h    This help"
          echo "  -f    Force re-configure of all"
          echo "  -S    Only do step if many steps build."
          echo "        Only applies to some packages, Qt, icu "
          echo "  -s SDK the sdk to build aginst, default select latest version"
          exit 0
    esac
done
