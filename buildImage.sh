#!/bin/bash

archs=("arm64e" "arm64" "x86_64")

usage() {
  echo -e "Replace a Dockerfile.common.* with correct architecture"
  echo -e " Build a docker image"
  echo -e " $0 -f Dockerfile.common -a architecture [-t tagname | -e ] "
  echo -e "  -f dockerfile     The dockerfile to convert"
  echo -e "  -a architecture   The architecture to use: ${archs[@]}"
  echo -e " Setting mode:\n  You use either -t or -e:"
  echo -e "  -t is tag name given to docker, create image directly"
  echo -e "  -e echo mode, print converted dockerfile to stdout\n"
  echo -e "  Tagmode (-t) is simplest\n"
  echo -e "  With echomode (-e) you can create your own Dockerfile with"
  echo -e "   $0 -f Dockerfile.common -a arm64 -e > Dockerfile.myown"
  echo -e "   or build directly:"
  echo -e "   $0 -f Dockerfile.common -a x86_64 -e > docker build ."

  exit 0
}

FILE=
ARCH=
TAG=
ECHOMODE=

while getopts hef:a:t: flag; do
  case "$flag" in
    f) FILE=$OPTARG;;
    a) ARCH=$OPTARG;;
    t) TAG=$OPTARG;;
    e) ECHOMODE=true;;
    h) usage;;
    *) echo "unrecognized parameter $1"
       exit 1
    ;;
  esac
done

# sanity checks
if [ -z "$FILE" ]; then
  echo "Must give a Dockerfile to convert"
  exit 1
elif [ -z "$ARCH" ]; then
  echo "Must give a architecture to build image with"
  exit 1
elif [[ -z "$TAG" && "$ECHOMODE" != true ]] || \
     [[ ! -z "$TAG" && "$ECHOMODE" == true ]]; then
  echo -e "Must select either tagmode or echomode, see:\n $0 -h"
  exit 1
elif [[ ! "${archs[*]}" =~ "$ARCH" ]]; then
  echo "$ARCH is not a valid architecture"
  exit 1
elif [ ! -f "$FILE" ]; then
  echo "File $FILE not found"
  exit 1
fi

# download packages to host before creating docker image
# should only donload once, if building for multiple architectures
bash cross/buildBase.sh -Sd -a
if [ "$?" -ne 0 ]; then
  echo "Failed to download all packages, aborting build"
  exit 1
fi

cont=$(cat "$FILE" | sed -e "s/--\*\*REPLACE\*\*--/$ARCH-apple/")
if [ "$ECHOMODE" == true ]; then
  echo "$cont"
  exit 0
else
  echo "Creating $TAG docker image"
  echo "echo \"${cont:0:8}...\" | docker build -t \"$TAG\" -f - ."
  echo -e "$cont" | DOCKER_BUILDKIT=1 docker build -t "$TAG" -f - .
  if [ "$?" != 0 ]; then
    echo "Failed to complete creation of $TAG"
  else
    echo "Done creating $TAG image"
  fi
fi

