#!/bin/bash

OSXCROSS_DIR=/opt/osxcross
DMGs_DIR=$OSXCROSS_DIR/DMGs
cd $DMGs_DIR

dmgs=$(ls *.dmg)

if [ ! -z "$dmgs" ]; then
  for dmg in ${dmgs[@]}; do
    echo "------------------------"
    echo "Extracting SDKs from $dmg"
    $OSXCROSS_DIR/tools/gen_sdk_package_tools_dmg.sh $dmg
    mv $OSXCROSS_DIR/*.sdk.tar.* $OSXCROSS_DIR/tarballs/
    mv $dmg $dmg.done
    echo "Done extracting SDKs from $dmg"
  done
fi
