#!/bin/bash

source getopt.sh

# make and install in this order
SCRIPTS="make-bzip2.sh \
  make-zlib.sh \
  make-xv.sh \
  make-bison.sh \
  make-pcre.sh \
  make-pcre2.sh \
  make-png.sh \
  make-jpeg.sh \
  make-icu.sh \
  make-iconv.sh \
  make-readline.sh \
  make-harfbuzz.sh \
  make-openssl.sh \
  make-hunspell.sh \
  make-freetype.sh \
  make-gettext.sh \
  make-libxml2.sh \
  make-ncurses.sh \
"

params=
if [ "$FORCE" == true ]; then
  params="-f"
fi
if [ ! -z "$SDK" ]; then
  params+=" -s $SDK"
fi

for SCRIPT in $SCRIPTS ; do
  cd /opt/osxcross/cross
  echo "--------------------------------"
  echo "-- running $SCRIPT"
  stdbuf -oL "./$SCRIPT" "$params" 2>&2 && 1>&1
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "*** Failed when runing $SCRIPT, exiting"
    exit $exitCode
  fi
done
