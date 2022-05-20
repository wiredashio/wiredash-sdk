#!/usr/bin/env bash

l10nPath="lib/assets/l10n"

rm "$l10nPath"/*.g.dart | true

flutter gen-l10n \
  --arb-dir="$l10nPath/" \
  --no-synthetic-package \
  --output-dir="$l10nPath" \
  --template-arb-file="wiredash_en.arb" \
  --no-nullable-getter \
  --output-class="WiredashLocalizations" \
  --output-localization-file="wiredash_localizations.g.dart"

dart format "$l10nPath"