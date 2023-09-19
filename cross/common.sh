#!/bin/bash
CROSS_DIR=/opt/osxcross/cross
SRC_DIR=$CROSS_DIR/src
TARGET_DIR=/opt/osxcross/target
USR_DIR=$TARGET_DIR/usr

# search for include headers in these paths
# gets set later automatically by this script
USR_INCLUDES=
SDK_INCLUDES=
INCLUDES=
# search for libs in these paths
# gets set later automatically by this script
USR_LIB_PATHS=
SDK_LIB_PATHS=
LIB_PATHS=

# read command lines
source getopt.sh

# the architecture
source config.sh

searchDirs() {
  # arg1 = resulting variable
  # arg2 = root dir to scan
  # arg3 = pad with
  local __resultvar = $1
  local paths=""
  for dir in $(ls -d $2/*/); do
    paths+="${3}$dir "
  done

  eval $__resultvar="'$paths'"
}

# set include and lib paths
scanDirs() {
  searchDirs USR_INCLUDES "$USR_DIR/include" "-I"
  searchDirs SDK_INCLUDES "$SDK_DIR/usr/include" "-I"
  INCLUDES="$USR_INCLUDES $SDK_INCLUDES"

  searchDirs USR_LIB_PATHS "$USR_DIR/lib" "-L"
  searchDirs SDK_LIB_PATHS "$SDK_DIR/usr/lib"
  LIB_PATHS="$USR_LIB_PATHS $SDK_LIB_PATHS"
}
scanDirs

validate_md5sum() {
  # arg1 = path, arg2 = chksum
  chksum=$(md5sum $1| sed 's/ .*//')
  if [ "$chksum" != "$2" ]; then
    echo "Source for $1, checksums md5 does not match"
    echo "$chksum!=$2"
    exit 1
  fi
}

validate_sha256() {
  #arg1 = path, arg2 = chksum
  chksum=$(openssl sha256 $1|sed 's/.* \(.*$\)/\1/')
  if [ "$chksum" != "$2" ]; then
    echo "Source for $1, checksums sha256 does not match"
    echo "$chksum!=$2"
    exit 1
  fi
}

extract() {
  curdir=$(pwd)
  cd "$CROSS_DIR"
  echo "Extracting $TARNAME to src/$FILENAME"
  tar -xf "pkg/$TARNAME" -C src/
  cd "$curdir"
}

failOnError() {
  # arg1 = previous command success ie $?
  # arg2 = message to print
  # arg3 (optional) = errorcode to exit
  if [ "$1" -ne 0 ]; then
    echo "$2"
    if [ ! -z ${3+x} ] && [ -n $3 ]; then
      exit "$3"
    else
      exit 1
    fi
  fi
}

failOnConfigure() {
  # arg1 previous configure success id $?
  failOnError "$1" "Failed to configure $PKG"
}

failOnBuild() {
  #arg1 previous build command ie result of make
  failOnError "$1" "Failed to build $PKG"
}

failOnInstall() {
  #arg1 previous install command is result of make install
  failOnError "$1" "Failed to install $PKG"
}

if [ ! -z ${FORCE+x} ] && [ "$FORCE" == true ]; then
  echo "Forcing rebuild"
fi

if [ ! -f "pkg/$TARNAME" ]; then
  wget -P pkg/ $DOWNLOADURL
fi

if [ ! -z "$SHA256" ]; then
  validate_sha256 "pkg/$TARNAME" "$SHA256"
elif [ ! -z "$MD5SUM" ]; then
  validate_md5sum "pkg/$TARNAME" "$MD5SUM"
else
  echo "Unable to validate $TARNAME"
  exit 1
fi

if [ ! -d "$SRC_DIR/$FILENAME" ]; then
  extract

  if [ ! -z "$PATCH_FILE" ]; then
    echo "Patching $FILENAME with $PATCH_FILE"

    curdir=$(pwd)
    cd "$SRC_DIR/$FILENAME"
    patch -s -p1 < "$CROSS_DIR/$PATCH_FILE"
    cd "$curdir"
  fi
fi