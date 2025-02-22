#!/bin/bash
# This script is a "Works on my computer" script.
# You may have to study and adapt it to run on your computer.
#
#  Commands needed in your path
#
#    sed
#    arduino
#    zip

builddir="$PWD/build.arduino~"
srcdir="$(dirname "$0")"
VERSION=`cat "$srcdir/VERSION"`

echo "Patch the arduino source to set VERSION to $VERSION"

sed -i 's/^\(#define ACSI2STM_VERSION\).*/\1 "'$VERSION'"/' "$srcdir/acsi2stm/acsi2stm.h"

echo "Create a clean build directory"

rm -rf "$builddir"
mkdir "$builddir"

cp "$srcdir/acsi2stm/acsi2stm.h" "$builddir/acsi2stm.h"

(

compile_arduino() {

local name="$1"; shift
local device=STM32F103C8
local optim=s
if [ "$1" = 128 ]; then
  device=STM32F103CB
  shift
fi
if [ "$1" = fast ]; then
  optim=2
fi

arduino --pref build.path="$builddir/Arduino-$name" --pref build.warn_data_percentage=80 --pref compiler.warning_level=all --board "Arduino_STM32-master:STM32F1:genericSTM32F103C:device_variant=$device,upload_method=serialMethod,cpu_speed=speed_72mhz,opt=o${optim}std" --preserve-temp-files --verify "$srcdir/acsi2stm/acsi2stm.ino"

[ -e "$builddir/Arduino-$name/acsi2stm.ino.bin" ] || exit $?

}

if [ "$1" = all ]; then
  echo
  echo "Compile verbose binary"
  sed -i 's/^#define ACSI_VERBOSE .$/#define ACSI_VERBOSE 1/' "$srcdir/acsi2stm/acsi2stm.h"
  sed -i 's/^#define ACSI_DEBUG .$/#define ACSI_DEBUG 1/' "$srcdir/acsi2stm/acsi2stm.h"
  sed -i 's/^#define ACSI_STACK_CANARY .*$/#define ACSI_STACK_CANARY 4096/' "$srcdir/acsi2stm/acsi2stm.h"
  compile_arduino verbose
  mv "$builddir/Arduino-verbose/acsi2stm.ino.bin" ./acsi2stm-$VERSION-verbose.ino.bin

  echo
  echo "Compile debug binary"
  sed -i 's/^#define ACSI_VERBOSE .$/#define ACSI_VERBOSE 0/' "$srcdir/acsi2stm/acsi2stm.h"
  compile_arduino debug
  mv "$builddir/Arduino-debug/acsi2stm.ino.bin" ./acsi2stm-$VERSION-debug.ino.bin

  echo
  echo "Compile release binary"
  sed -i 's/^#define ACSI_DEBUG .$/#define ACSI_DEBUG 0/' "$srcdir/acsi2stm/acsi2stm.h"
  sed -i 's/^#define ACSI_STACK_CANARY .*$/#define ACSI_STACK_CANARY 0/' "$srcdir/acsi2stm/acsi2stm.h"
  compile_arduino release
  cp "$builddir/Arduino-release/acsi2stm.ino.bin" ./acsi2stm-$VERSION.ino.bin

  echo
  echo "Compile strict mode binary"
  sed -i 's/^#define ACSI_STRICT .$/#define ACSI_STRICT 1/' "$srcdir/acsi2stm/acsi2stm.h"
  compile_arduino strict
  cp "$builddir/Arduino-strict/acsi2stm.ino.bin" ./acsi2stm-$VERSION-strict.ino.bin

  echo
  echo "Compile binary for legacy hardware"
  sed -i 's/^#define ACSI_STRICT .$/#define ACSI_STRICT 0/' "$srcdir/acsi2stm/acsi2stm.h"
  sed -i 's/^#define ACSI_HAS_RESET .$/#define ACSI_HAS_RESET 0/' "$srcdir/acsi2stm/acsi2stm.h"
  sed -i 's/^#define ACSI_SD_WRITE_LOCK .$/#define ACSI_SD_WRITE_LOCK 0/' "$srcdir/acsi2stm/acsi2stm.h"
  compile_arduino legacy
  cp "$builddir/Arduino-legacy/acsi2stm.ino.bin" ./acsi2stm-$VERSION-legacy.ino.bin
else
  echo "Compile binary with current settings"
  compile_arduino current "$@"
  cp "$builddir/Arduino-current/acsi2stm.ino.bin" ./acsi2stm-$VERSION.ino.bin
fi

)

mv "$builddir/acsi2stm.h" "$srcdir/acsi2stm/acsi2stm.h"

# Clean up build

if ! [ "$KEEP_BUILD" ]; then
  echo
  echo "Cleaning up build directory"
  rm -r "$builddir"
fi
