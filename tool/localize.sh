#!/usr/bin/env bash

translationPath="lib/src/core/translation"

flutter gen-l10n \
  --arb-dir="$translationPath/l10n" \
  --no-synthetic-package \
  --output-dir="$translationPath" \
  --template-arb-file="wiredash_en.arb" \
  --no-nullable-getter \
  --output-class="WiredashLocalizations" \
  --output-localization-file="wiredash_localizations.g.dart"

dart format "$translationPath"