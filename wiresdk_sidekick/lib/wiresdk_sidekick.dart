import 'dart:async';

import 'package:phntmxyz_bump_version_sidekick_plugin/phntmxyz_bump_version_sidekick_plugin.dart';
import 'package:sidekick_core/sidekick_core.dart';
import 'package:wiresdk_sidekick/src/commands/clean_command.dart';
import 'package:wiresdk_sidekick/src/commands/gen_l10n_command.dart';
import 'package:wiresdk_sidekick/src/commands/sync_branches_command.dart';
import 'package:wiresdk_sidekick/src/commands/test_command.dart';
import 'package:wiresdk_sidekick/src/commands/recreate_examples_command.dart';

Future<void> runWiresdk(List<String> args) async {
  final runner = initializeSidekick(
    mainProjectPath: '.',
    flutterSdkPath: systemFlutterSdkPath(),
  );

  runner
    ..addCommand(FlutterCommand())
    ..addCommand(DartCommand())
    ..addCommand(DepsCommand())
    ..addCommand(CleanCommand())
    ..addCommand(DartAnalyzeCommand())
    ..addCommand(FormatCommand())
    ..addCommand(SidekickCommand())
    ..addCommand(RecreateExamplesCommand())
    ..addCommand(SyncBranchesCommand())
    ..addCommand(GenL10nCommand())
    ..addCommand(TestCommand())
    ..addCommand(
      BumpVersionCommand()
        ..addModification(bumpVersionFile)
        ..addModification(bumpReadme),
    );

  try {
    return await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64); // usage error
  }
}

Future<void> bumpVersionFile(
  DartPackage package,
  Version oldVersion,
  Version newVersion,
) async {
  if (package.name != 'wiredash') return;

  final versionFile = package.root.file('lib/src/core/version.dart');
  final content = versionFile.readAsStringSync();

  final versionNumberRegex = RegExp(r'const wiredashSdkVersion = (\d)+;');
  final oldVersionNumber =
      int.parse(versionNumberRegex.firstMatch(content)!.group(1)!);

  int nextVersionNumber =
      newVersion.major * 100 + newVersion.minor * 10 + newVersion.patch;

  if (nextVersionNumber == oldVersionNumber) {
    nextVersionNumber++;
  }
  if (nextVersionNumber < oldVersionNumber) {
    throw 'New version number $nextVersionNumber for $newVersion is smaller '
        'than the old version number $oldVersionNumber for $oldVersion';
  }

  final newContent = content.replaceAll(
    versionNumberRegex,
    "/// $nextVersionNumber -> $newVersion\n"
    "const wiredashSdkVersion = $nextVersionNumber;",
  );
  versionFile.writeAsStringSync(newContent);
}

Future<void> bumpReadme(
  DartPackage package,
  Version oldVersion,
  Version newVersion,
) async {
  final readme = package.root.file('README.md');
  final content = readme.readAsStringSync();
  final next = '${newVersion.major}.${newVersion.minor}.0';

  final versionRegex = RegExp(r'wiredash:\s*\^(.+)');
  final update = content.replaceAllMapped(
    versionRegex,
    (match) => match[0]!.replaceFirst(match[1]!, next),
  );
  readme.writeAsStringSync(update);
}
