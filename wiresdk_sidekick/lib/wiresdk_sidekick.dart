import 'dart:async';

import 'package:sidekick_core/sidekick_core.dart';
import 'package:wiresdk_sidekick/src/commands/clean_command.dart';
import 'package:wiresdk_sidekick/src/commands/test_command.dart';
import 'package:wiresdk_sidekick/src/commands/gen_l10n_command.dart';
import 'package:wiresdk_sidekick/src/commands/sync_branches_command.dart';

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
    ..addCommand(SyncBranchesCommand())
    ..addCommand(GenL10nCommand())
    ..addCommand(TestCommand());

  try {
    return await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64); // usage error
  }
}
