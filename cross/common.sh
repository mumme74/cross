#!/bin/bash
CROSS_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
SRC_DIR=$CROSS_DIR/src
TARGET_DIR="$(dirname "$CROSS_DIR")/target"
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

# these can be set by build rule before calling start
HOST_BUILD_DIR=
HOST_CONFIG_CMD=
HOST_CONFIG_FN=
HOST_BUILD_FN=
HOST_BUILD_CMD=
HOST_INSTALL_FN=
HOST_INSTALL_CMD=
TARGET_BUILD=true
TARGET_BUILD_DIR=
TARGET_CONFIG_CMD=
TARGET_CONFIG_FN=
TARGET_BUILD_CMD=
TARGET_BUILD_FN=
TARGET_INSTALL_CMD=
TARGET_INSTALL_FN=

cd "$CROSS_DIR"

# read command lines
source $(dirname "$0")/getopt.sh

# the architecture
source $(dirname "$0")/config.sh

searchDirs() {
  # arg1 = resulting variable
  # arg2 = root dir to scan
  # arg3 = pad with
  local __resultvar=$1
  local paths="${3}$2 "
  for dir in $(ls -d $2/*/ 2>/dev/null); do
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
  echo "Extracting $TARNAME to src/$DIRNAME"
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

downloadAndValidate() {
  if [ ! -f "$CROSS_DIR/pkg/$TARNAME" ]; then
    wget -P $CROSS_DIR/pkg/ $DOWNLOADURL
  fi

  if [ ! -z "$SHA256" ]; then
    validate_sha256 "$CROSS_DIR/pkg/$TARNAME" "$SHA256"
  elif [ ! -z "$MD5SUM" ]; then
    validate_md5sum "$CROSS_DIR/pkg/$TARNAME" "$MD5SUM"
  else
    echo "Unable to validate $TARNAME"
    exit 1
  fi
}

extractAndPatch() {
  if [ ! -d "$SRC_DIR/$DIRNAME" ]; then
    extract

    if [ ! -z "$PATCH_FILE" ]; then
      echo "Patching $DIRNAME with $PATCH_FILE"

      cd "$SRC_DIR/$DIRNAME"
      patch -s -p1 < "$CROSS_DIR/$PATCH_FILE"
    fi
  fi
}

defaultConfigFn() {
  local srcDir=$1
  local buildDir=$2
  local configCmd=$3

  cd $buildDir
  if [ -z "$configCmd" ]; then
    echo "**No *_CONFIG_CMD given, aborting"
    exit 1
  fi

  if [ "${configCmd:0:9}" == "configure" ]; then
    [ "$srcDir" != "$buildDir" ] && \
      configCmd="$srcDir/$configCmd" || \
       configCmd="./$configCmd"
  elif [ "${configCmd:0:5}" == "cmake" ]; then
    [ "$srcDir" != "$buildDir" ] && \
      configCmd="$configCmd $srcDir" || \
        configCmd="$configCmd ./"
  fi

  if [ ! -f "$buildDir/config.log" ]; then
    echo "configuring $PKG, build dir: $buildDir"
    echo "configuring $PKG $buildDir"
    echo "$configCmd"
    eval "$configCmd" | tee "$buildDir/.config.log"
    failOnConfigure $?

    if [ ! -f "$buildDir/config.log" ]; then
      mv $buildDir/.config.log $buildDir/config.log
    else
      rm $buildDir/.config.log
    fi
  fi
}

defaultBuildFn() {
  local buildCmd=$1
  echo "$buildCmd"
  eval "$buildCmd"
  failOnBuild $?
}

defaultInstallFn() {
  local installCmd=$1
  echo "$installCmd"
  eval "$installCmd"
  failOnInstall $?
}

configureAndBuild() {
  local srcDir=$1
  local buildDir=$2
  local configCmd=$3
  local configFn=$4
  local buildFn=$5
  local installFn=$6
  local buildCmd=$7
  local installCmd=$8

  # force rebuild clean
  if [ "$FORCE" == true ]; then
    if [ "$buildDir" == "$HOST_BUILD_DIR" ] || \
       [ "$OUT_OF_SRC_BUILD" == true ]; then
      rm -rf $buildDir
    else
      rm -f $buildDir/config.log
    fi
  fi

  mkdir -p $buildDir
  cd $buildDir

  $configFn "$srcDir" "$buildDir" "$configCmd"

  # build
  [ -z "$buildFn" ] && defaultBuildFn "$buildCmd"|| $buildFn
  [ -z "$installFn" ] && defaultInstallFn "$installCmd" || $installFn
}

configureAndBuildHost() {
  if [ "$HOST_BUILD" == true ]; then
    echo "---------------------"
    echo "building host $PKG"
    local configFn=$HOST_CONFIG_FN
    local buildCmd=$HOST_BUILD_CMD
    local installCmd=$HOST_INSTALL_CMD

    # select configFn
    [ -z "$configFn" ] &&
      configFn=defaultConfigFn
    [ -z "$buildCmd" ] &&
      buildCmd="make --jobs=$(nproc) JOBS=$(nproc)"
    [ -z "$installCmd" ] &&
      installCmd="make install"

    configureAndBuild \
      "$SRC_DIR/$DIRNAME" \
      "$HOST_BUILD_DIR" \
      "$HOST_CONFIG_CMD" \
      "$configFn" \
      "$HOST_BUILD_FN" \
      "$HOST_INSTALL_FN" \
      "$buildCmd" \
      "$installCmd"
  fi
}

configureAndBuildTarget() {
  if [ "$TARGET_BUILD" == true ]; then
    echo "---------------------"
    echo "building target $PKG"
    local configFn="$TARGET_CONFIG_FN"
    local buildCmd=$TARGET_BUILD_CMD
    local installCmd=$TARGET_INSTALL_CMD

    # select configFn
    [ -z "$configFn" ] && \
      configFn=defaultConfigFn
    [ -z "$buildCmd" ] &&
      buildCmd="make --jobs=$(nproc) JOBS=$(nproc)"
    [ -z "$installCmd" ] &&
      installCmd="make install"

    configureAndBuild \
      "$SRC_DIR/$DIRNAME" \
      "$TARGET_BUILD_DIR" \
      "$TARGET_CONFIG_CMD" \
      "$configFn" \
      "$TARGET_BUILD_FN" \
      "$TARGET_INSTALL_FN" \
      "$buildCmd" \
      "$installCmd"
  fi
}

[ -z "$DIRNAME" ] && DIRNAME=$FILENAME

# extract and patch before setting rules
for st in ${STEP[@]}; do
  case $st in
    d) downloadAndValidate;;
    e) extractAndPatch;;
  esac
done

# if only download, we stop here
if [[ ! ${STEP[@]} =~ "h" ]] && [[ ! ${STEP[@]} =~ "t" ]]; then
  exit 0
fi

echo "Building $PKG"
scanDirs
cd $SRC_DIR/$DIRNAME


# initialize these before any rules are set
[ "$HOST_BUILD" == true ] && \
  HOST_BUILD_DIR=$SRC_DIR/$DIRNAME-build-host
TARGET_BUILD_DIR=$SRC_DIR/$DIRNAME
[ "$OUT_OF_SRC_BUILD" == true ] && \
  TARGET_BUILD_DIR+=-build-target

# start the compilation
start() {
  if [ ! -z ${FORCE+x} ] && [ "$FORCE" == true ]; then
    echo "Forcing rebuild"
  fi

  for st in ${STEP[@]}; do
    case $st in
      h) configureAndBuildHost;;
      t) configureAndBuildTarget;;
    esac
  done
}
