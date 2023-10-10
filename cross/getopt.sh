#!/bin/bash

FORCE=
STEP=
CLEAN=

getoptParams="fS:h:c"
[ "$ALL_OPTION" == true ] && getoptParams+="a"

# parse arguments to script
while getopts "$getoptParams" flag
do
    case "${flag}" in
        f) FORCE=true;;
        S) STEP=${OPTARG};;
        c) CLEAN=true;;
        h)
          echo "$0 [options]"
          echo "  -h    This help"
          echo "  -f    Force re-configure of all"
          echo "  -c    Clean the build dir"
          echo "  -S    Build this step(s) only, default=d,e,h,t,R"
          echo "        d=download"
          echo "        e=extract and patch"
          echo "        t=build target"
          echo "        h=build host (only valid on some rules)"
          echo "        r=remove host build dir"
          echo "        R=remove target build dir"
          exit 0;;
        a) USE_ALL=true;; # to build all, not just base
    esac
done

unset getoptParams

if [ -z "$STEP" ]; then
  STEP="d,e,h,t,R"
fi

IFS_old=$IFS
IFS=',' read -r -a STEP <<< "$STEP"
IFS=$IFS_old

for st in $STEP; do
    case $st in
    d|e|t|h|r|R);; #valid
    *) echo "Invalid step: $STEP"
        exit 0;;
    esac
done
