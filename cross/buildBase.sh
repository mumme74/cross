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
  make-libevent.sh \
  make-hunspell.sh \
  make-freetype.sh \
  make-fontconfig.sh \
  make-gettext.sh \
  make-libxml2.sh \
  make-boost.sh \
  make-ncurses.sh \
  make-sqlite.sh \
  make-unixodbc.sh \
  make-mysql-client.sh \
"
# not yet working
#  make-boost.sh \
#  make-postgree.sh \

for SCRIPT in $SCRIPTS ; do
  cd /opt/osxcross/cross
  echo "--------------------------------"
  echo "-- running $SCRIPT"
  stdbuf -oL "./$SCRIPT" "$@" 2>&2 && 1>&1
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "*** Failed when running $SCRIPT, exiting"
    exit $exitCode
  fi
done
