#!/bin/bash

FORCE=
STEP=

# parse arguments to script
while getopts fS:hs: flag
do
    case "${flag}" in
        f) FORCE=true;;
        S) STEP=${OPTARG};;
        h)
          echo "$0 [options]"
          echo "  -h    This help"
          echo "  -f    Force re-configure of all"
          echo "  -S    Only do step if many steps build."
          echo "        Only applies to some packages, Qt, icu "
          exit 0
    esac
done
