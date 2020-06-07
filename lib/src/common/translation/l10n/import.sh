#!/bin/bash

apiToken=$POEDITOR_API_TOKEN
projectId=347065

for lang in "en" "pl" "de" "es" "nl" "fr"; do
    echo $lang
    command=$(curl -X POST https://api.poeditor.com/v2/projects/export \
        -d api_token="$apiToken" \
        -d id="$projectId" \
        -d language="$lang" \
        -d type="key_value_json" | jq -r ".result.url")
    file="intl_$lang.json"
    curl "$command" -o "$file"

    langFile="messages_$lang.dart"

    printf "import 'package:wiredash/wiredash.dart';\n\n" >"$langFile"
    printf "class WiredashLocalizedTranslations extends WiredashTranslations {\n" >>"$langFile"
    printf "  const WiredashLocalizedTranslations() : super();\n" >>"$langFile"

    keys=($(jq -r 'keys_unsorted[]' "$file"))
    values=$(jq -r 'values[]' "$file")

    SAVEIFS=$IFS # Save current IFS
    IFS=$'\n'    # Change IFS to new line

    # Populate array of values
    declare -a array
    n=0
    for line in "${values[@]}"; do
        array+=($line)
        n=$(($n + 1))
    done

    # Print keys and values to Dart class
    n=0
    for i in "${keys[@]}"; do
        printf "   @override\n" >>$langFile
        printf "   String get %s => \"%s\";\n" $i "${array[$n]}" >>$langFile
        n=$(($n + 1))
    done

    IFS=$SAVEIFS # Restore IFS

    printf "}" >>"$langFile"
    unset array
    unset keys
    unset values
    unset n
done

dartfmt -w .
