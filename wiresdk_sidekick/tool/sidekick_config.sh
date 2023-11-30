#!/usr/bin/env bash
set -e

# Parses a yaml file and prints the variables
# Usage:
# parse_yaml sample.yml "CONF_"
#
# prints
# CONF_global_debug="yes"
# CONF_global_verbose="no"
# CONF_global_debugging_detailed="no"
# CONF_global_debugging_header="debugging started"
# CONF_output_file="yes"
#
# From https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' 
   local w='[a-zA-Z0-9_]*' 
   local fs
   fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:${s}[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
   awk -F"$fs" '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'"$prefix"'",vn, $2, $3);
      }
   }'
}


SIDEKICK_PACKAGE_HOME=$(dirname "$(dirname "$0")")

DART_SDK_CONSTRAINTS=$(parse_yaml "${SIDEKICK_PACKAGE_HOME}/pubspec.yaml" | grep "environment_sdk")
# i.e. extract 2.17.0 from ">=2.17.0 <3.0.0"
DART_VERSION=$(echo "$DART_SDK_CONSTRAINTS" | sed -E 's/.*>=([0-9.]+).*/\1/')

echo "DART_VERSION=\"$DART_VERSION\""

