#!/bin/bash

CROSS_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ALL_OPTION=true

source $CROSS_DIR/getopt.sh
cd $CROSS_DIR


# make and install in this order
SCRIPTS="make-bzip2.sh \
  make-zlib.sh \
  make-xv.sh \
  make-bison.sh \
  make-pcre.sh \
  make-pcre2.sh \
  make-libffi.sh \
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
  make-postgres-client.sh \
  make-mysql-client.sh \
  make-libclang.sh \
"

if [ "$USE_ALL" == true ]; then
  SCRIPTS+=" \
    make-qt6.sh \
  "
fi

# strip -a from arguments
args=$@
PARAMS=()
for vlu in "${args[@]}"; do
  [ "$vlu" != "a" ] && PARAMS+=($vlu)
done

# run all scripts
for SCRIPT in $SCRIPTS ; do
  cd $CROSS_DIR
  echo "--------------------------------"
  echo "-- running $SCRIPT"
  if [ ! -f "./$SCRIPT" ]; then
    echo "build rule script $SCRIPT not found"
    exit 1
  elif [ ! -x "./$SCRIPT" ]; then
    chmod ug+x "./$SCRIPT"
  fi
  stdbuf -oL "./$SCRIPT" "$PARAMS" 2>&2 && 1>&1
  exitCode=$?
  if [ $exitCode -ne 0 ]; then
    echo "*** Failed when running $SCRIPT, exiting"
    exit $exitCode
  fi
done
