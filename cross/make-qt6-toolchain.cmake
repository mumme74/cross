cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

set(SDK_PATH /opt/osxcross/target/SDK/*)

set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR *)
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9")

set(TARGET_SYSROOT /opt/osxcross/target)
set(CROSS_COMPILER /opt/osxcross/target/bin/*)

set(CMAKE_SYSROOT ${TARGET_SYSROOT})
set(CMAKE_INCLUDE_PATH ${TARGET_SYSROOT}/usr/include ${SDK_PATH}/usr/include)
set(CMAKE_LIBRARY_PATH ${TARGET_SYSROOT}/usr/lib ${SDK_PATH}/usr/lib)
set(CMAKE_PREFIX_PATH /opt/osxcross/cross/host;${SDK_PATH}/System/Library/Frameworks)
list(APPEND CMAKE_FRAMEWORK_PATH ${SDK_PATH}/System/Library/Frameworks)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -F${SDK_PATH}/System/Library/Frameworks -L${TARGET_SYSROOT}/usr/lib -L${SDK_PATH}/usr/lib")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -F${SDK_PATH}/System/Library/Frameworks -L${TARGET_SYSROOT}/usr/lib -L${SDK_PATH}/usr/lib")

set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR} ${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig)
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set(CMAKE_C_COMPILER ${CROSS_COMPILER}-cc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILER}-c++)

set(QT_COMPILER_FLAGS "-I${SDK_PATH}/usr/include")
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe")
set(QT_LINKER_FLAGS "-Wl -L${SDK_PATH}/usr/lib -F${SDK_PATH}/System/Library/Frameworks -L${TARGET_SYSROOT}/usr/lib -L${TARGET_SYSROOT}/usr/lib")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

include(CMakeInitializeConfigs)

function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
  if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
    set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")

    foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
      if (DEFINED QT_COMPILER_FLAGS_${config})
        set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
      endif()
    endforeach()
  endif()

  if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
    foreach (config SHARED MODULE EXE)
      set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
    endforeach()
  endif()

  _cmake_initialize_per_config_variable(${ARGV})
endfunction()
