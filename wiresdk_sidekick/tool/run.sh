#!/usr/bin/env bash
set -e

# Attempt to set TOOL_HOME
# Resolve links: $0 may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "$PRG" ]; do
  ls=$(ls -ld "$PRG")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' >/dev/null; then
    PRG="$link"
  else
    PRG=$(dirname "$PRG")"/$link"
  fi
done
SAVED="$(pwd)"
cd "$(dirname "$PRG")/" >/dev/null
TOOL_HOME="$(pwd -P)"
cd "$SAVED" >/dev/null

SIDEKICK_PACKAGE_HOME=$(dirname "$TOOL_HOME")
export SIDEKICK_PACKAGE_HOME

# Extract DART_VERSION
eval "$("$TOOL_HOME/sidekick_config.sh")"

if [ -z "$DART_VERSION" ]; then
  echo "DART_VERSION is not set"
  exit 1
fi

DART_SDK="${SIDEKICK_PACKAGE_HOME}/build/cache/dart-sdk"
CACHED_DART_SDK_VERSION=$(cat "$DART_SDK/version" 2> /dev/null) || true

# When the Dart SDK version changes or the Dart SDK is missing, install it.
if [ "$CACHED_DART_SDK_VERSION" != "$DART_VERSION" ] || [ ! -d "$DART_SDK" ]; then
  rm -rf "$DART_SDK" || true
  # Download new Dart runtime with DART_VERSION
  sh "${SIDEKICK_PACKAGE_HOME}/tool/download_dart.sh"
fi

HASH_PROGRAM='sha1sum'
OS="$(uname -s)"
if [[ $OS =~ Darwin.* ]]; then
  HASH_PROGRAM="shasum"
fi

# Creates a hash of files that should cause the cli to recompile
#
# Usually, this works just fine, but this technique is unable to detect changes
# of path dependencies. Use the `<cli> sidekick recompile` command in those
# cases, forcing a recompile.
function computeHash() {
  SAVED="$(pwd)"
  cd "${SIDEKICK_PACKAGE_HOME}"
  find \
    "bin" \
    "lib" \
    "tool" \
    "pubspec.yaml" \
    "pubspec.lock" \
    -type f -print0 2>/dev/null | xargs -0 "$HASH_PROGRAM"
  cd "$SAVED" >/dev/null
}

STAMP_FILE="${SIDEKICK_PACKAGE_HOME}/build/cli.stamp"
HASH=$(computeHash)
EXISTING_HASH=$(cat "$STAMP_FILE" 2> /dev/null) || true

EXE="${SIDEKICK_PACKAGE_HOME}/build/cli.exe"

# if exe is missing or hash has changed, rebuild
if [ ! -f "$EXE" ] || [ "$HASH" != "$EXISTING_HASH" ]; then
  # different hash, recompile
  sh "${SIDEKICK_PACKAGE_HOME}/tool/install.sh"
  # pubspec.lock may have changed, recompute hash
  NEW_HASH=$(computeHash)
  echo "$NEW_HASH" > "$STAMP_FILE"
fi

"${EXE}" "$@"

