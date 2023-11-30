#!/usr/bin/env bash

# Downloads the dart sdk into the sidekick build folder.
# Handles caching to minimize network traffic

# Highly inspired by https://github.com/flutter/flutter/blob/b7b8b759bc3ab7a80d2576d52f7b05bc1e6e23bd/bin/internal/update_dart_sdk.sh

set -e

SIDEKICK_PACKAGE_HOME=$(dirname "$(dirname "$0")")

# Extract DART_VERSION
eval "$("$SIDEKICK_PACKAGE_HOME/tool/sidekick_config.sh")"

if [ -z "$DART_VERSION" ]; then
  echo "DART_VERSION is not set"
  exit 1
fi

DART_SDK_ZIP_FOLDER="$HOME/.dart/sdk/cache/${DART_VERSION}"
SIDEKICK_DART_SDK_UNZIP_PATH="$SIDEKICK_PACKAGE_HOME/build/cache"
SIDEKICK_DART_SDK_PATH="$SIDEKICK_DART_SDK_UNZIP_PATH/dart-sdk"
DART_VERSION_FILE="$SIDEKICK_DART_SDK_PATH/version"
OS="$(uname -s)"

if [ ! -f "$DART_VERSION_FILE" ] || [ "$DART_VERSION" != "$(cat "${DART_VERSION_FILE}")" ]; then
  command -v curl > /dev/null 2>&1 || {
    >&2 echo
    >&2 echo 'Missing "curl" tool. Unable to download Dart SDK.'
    case "$OS" in
      Darwin)
        >&2 echo 'Consider running "brew install curl".'
        ;;
      Linux)
        >&2 echo 'Consider running "sudo apt-get install curl".'
        ;;
      *)
        >&2 echo "Please install curl."
        ;;
    esac
    echo
    exit 1
  }
  command -v unzip > /dev/null 2>&1 || {
    >&2 echo
    >&2 echo 'Missing "unzip" tool. Unable to extract Dart SDK.'
    case "$OS" in
      Darwin)
        echo 'Consider running "brew install unzip".'
        ;;
      Linux)
        echo 'Consider running "sudo apt-get install unzip".'
        ;;
      *)
        echo "Please install unzip."
        ;;
    esac
    echo
    exit 1
  }

  # `uname -m` may be running in Rosetta mode, instead query sysctl
  if [ "$OS" = 'Darwin' ]; then
    # Allow non-zero exit so we can do control flow
    set +e
    # -n means only print value, not key
    QUERY="sysctl -n hw.optional.arm64"
    # Do not wrap $QUERY in double quotes, otherwise the args will be treated as
    # part of the command
    QUERY_RESULT=$($QUERY 2>/dev/null)
    if [ $? -eq 1 ]; then
      # If this command fails, we're certainly not on ARM
      ARCH='x64'
    elif [ "$QUERY_RESULT" = '0' ]; then
      # If this returns 0, we are also not on ARM
      ARCH='x64'
    elif [ "$QUERY_RESULT" = '1' ]; then
      ARCH='arm64'
    else
      >&2 echo "'$QUERY' returned unexpected output: '$QUERY_RESULT'"
      exit 1
    fi
    set -e
  else
    # On x64 stdout is "uname -m: x86_64"
    # On arm64 stdout is "uname -m: aarch64, arm64_v8a"
    case "$(uname -m)" in
      x86_64)
        ARCH="x64"
        ;;
      *)
        ARCH="arm64"
        ;;
    esac
  fi

  case "$OS" in
    Darwin)
      DART_ZIP_NAME="dartsdk-macos-${ARCH}-release.zip"
      IS_USER_EXECUTABLE="-perm +100"
      ;;
    Linux)
      DART_ZIP_NAME="dartsdk-linux-${ARCH}-release.zip"
      IS_USER_EXECUTABLE="-perm /u+x"
      ;;
    MINGW*)
      DART_ZIP_NAME="dartsdk-windows-${ARCH}-release.zip"
      IS_USER_EXECUTABLE="-perm /u+x"
      ;;
    *)
      echo "Unknown operating system. Cannot install Dart SDK."
      exit 1
      ;;
  esac

  # Use the default find if possible.
  if [ -e /usr/bin/find ]; then
    FIND="/usr/bin/find"
  else
    FIND="find"
  fi

  DART_SDK_BASE_URL="${GOOGLE_STORAGE_BASE_URL:-https://storage.googleapis.com}"
  DART_SDK_URL="$DART_SDK_BASE_URL/dart-archive/channels/stable/release/$DART_VERSION/sdk/$DART_ZIP_NAME"

  # install the new sdk
  rm -rf -- "$SIDEKICK_DART_SDK_PATH"
  mkdir -p -- "$SIDEKICK_DART_SDK_PATH"
  chmod 755 "$SIDEKICK_DART_SDK_PATH"
  DART_SDK_ZIP="$DART_SDK_ZIP_FOLDER/$DART_ZIP_NAME"

  # Create cache folder when it doesn't exits
  mkdir -p "$DART_SDK_ZIP_FOLDER"

  if [ ! -f "$DART_SDK_ZIP" ]; then

    >&2 echo "Downloading $OS $ARCH Dart SDK $DART_VERSION..."

    # Download zip when it's not in cache
    curl --retry 3 --continue-at - --location --output "$DART_SDK_ZIP" "$DART_SDK_URL" 2>&1 || {
      curlExitCode=$?
      # Handle range errors specially: retry again with disabled ranges (`--continue-at -` argument)
      # When this could happen:
      # - missing support of ranges in proxy servers
      # - curl with broken handling of completed downloads
      #   This is not a proper fix, but doesn't require any user input
      # - mirror of flutter storage without support of ranges
      #
      # 33  HTTP range error. The range "command" didn't work.
      # https://man7.org/linux/man-pages/man1/curl.1.html#EXIT_CODES
      if [ $curlExitCode != 33 ]; then
        return $curlExitCode
      fi
      curl --retry 3 --location --output "$DART_SDK_ZIP" "$DART_SDK_URL" 2>&1
    } || {
      >&2 echo
      >&2 echo "Failed to retrieve the Dart SDK from: $DART_SDK_URL"
      >&2 echo
      rm -f -- "$DART_SDK_ZIP"
      exit 1
    }
  else
    >&2 echo "Using cached Dart SDK $DART_VERSION from $DART_SDK_ZIP..."
  fi

  # Extract sdk to build folder
  unzip -o -q "$DART_SDK_ZIP" -d "$SIDEKICK_DART_SDK_UNZIP_PATH" || {
    >&2 echo
    >&2 echo "It appears that the downloaded file is corrupt; please try again."
    >&2 echo
    rm -f -- "$DART_SDK_ZIP"
    exit 1
  }

  $FIND "$SIDEKICK_DART_SDK_PATH" -type d -exec chmod 755 {} \;
  $FIND "$SIDEKICK_DART_SDK_PATH" -type f $IS_USER_EXECUTABLE -exec chmod a+x,a+r {} \;
fi

