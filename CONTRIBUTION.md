# Contribution guide

## Contribute your translations 🎉

### Add a new language to wiredash

Add a new language file into `lib/assets/l10n/` and then run the generate command.

Don't forget to export the new language file in `lib/wiredash.dart` allowing devs to extend them.

### Add new localizations to existing languages

Update the `.arb` files to your liking in `lib/assets/l10n/`.
**Do not edit any .g.dart file manually.**

Checkout the `wiredash_en.arb` file (template) for all possible keys.

Then generate the new translations with the generate command.

### Generate new translations

To convert `.arb` files to dart code, run:

```bash
./tool/localize.sh
```

## Contributors

Thank you so much to following people who helped translate Wiredash! 🙌

- [orkwizard](https://github.com/orkwizard) 🇪🇸
- [stefandevo](https://github.com/stefandevo) 🇳🇱
- [huextrat](https://github.com/huextrat) 🇫🇷
- [mohanadshaban](https://github.com/mohanadshaban) [ar]
- [AtaTrkgl](https://github.com/AtaTrkgl), [salihgueler](https://github.com/salihgueler) 🇹🇷
- [Caio Pedroso](https://github.com/KyleKun) 🇵🇹
