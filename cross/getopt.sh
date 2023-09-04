#!/bin/bash

SDK=$( # default to build on the latest SDK
  ls /opt/osxcross/target/SDK |
  sort -nr -t X -k 2 |
  sed -e 's/\s.*//'
)
FORCE=

# parse arguments to script
while getopts fhs: flag
do
    case "${flag}" in
        f) FORCE=true;;
        s) SDK=${OPTARG};;
        h)
          echo "$0 [options]"
          echo "  -h    this help"
          echo "  -f    force re-configure"
          echo "  -s SDK the sdk to build aginst, default select latest version"
          exit 0
    esac
done
