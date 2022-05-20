# Localize Wiredash

## Generate new translations

To convert `.arb` files to dart code, run

```bash
./tool/localize.sh
```

## Add new localizations to existing languages

Update the `.arb` files to your liking in `lib/assets/l10n/`.
**Do not edit any .g.dart file manually**

Checkout the `wiredash_en.arb` file (template) for all possible keys.

Then generate the new translations with the generate command

## Add a new language to wiredash

Add a new language file into `lib/assets/l10n/` and then run the generate command

Don't forget to export the new language file in `lib/wiredash.dart` allowing devs to extend them.
