# Localize Wiredash

## Generate new translations

Once the `.arb` files are update, run this command to generate the corresponding dart code

```bash
./tool/localize.sh
```

## Add new localizations to existing languages

Update the `.arb` files to your liking.
**Do not edit any .g.dart file manually**

Checkout the `wiredash_en.arb` file (template) for all possible keys.

then generate the new translations with the generate command

## Add a new language to wiredash

Add a new language file into `lib/src/core/translation/l10n/` and then run the generate command
