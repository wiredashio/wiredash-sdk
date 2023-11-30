import 'package:sidekick_core/sidekick_core.dart';
import 'package:wiresdk_sidekick/wiresdk_sidekick.dart';

class GenL10nCommand extends Command {
  @override
  final String description = 'Generates the localization files';

  @override
  final String name = 'gen-l10n';

  @override
  Future<void> run() async {
    final l10nPath = SidekickContext.projectRoot.directory('lib/assets/l10n');
    final arbDir =
        relative(l10nPath.path, from: SidekickContext.projectRoot.path);

    flutter(
      [
        'gen-l10n',
        '--arb-dir=$arbDir',
        '--no-synthetic-package',
        '--output-dir=$arbDir',
        '--template-arb-file=wiredash_en.arb',
        '--no-nullable-getter',
        '--output-class=WiredashLocalizations',
        '--output-localization-file=wiredash_localizations.g.dart',
      ],
      workingDirectory: SidekickContext.projectRoot,
    );

    await runWiresdk(['format']);

    print(green('$name finished successfully 🎉'));
  }
}
