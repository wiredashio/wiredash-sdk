import 'package:dcli/dcli.dart' as dcli;
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:sidekick_core/sidekick_core.dart';

class RecreateExamplesCommand extends Command {
  @override
  final String description = 'Recreates the platform folder for all examples';

  @override
  final String name = 'recreate-examples';

  @override
  Future<void> run() async {
    await _printFlutterVersion();

    final examplesDir = SidekickContext.projectRoot.directory('examples');
    final examples = examplesDir
        .listSync()
        .whereType<Directory>()
        .mapNotNull((it) => DartPackage.fromDirectory(it))
        .where((it) => it.name != 'old_flutter_3_0')
        .toList();

    print('\nrecreating platform folders...');
    for (final package in examples) {
      await _recreatePlatformFolders(package);
    }

    print('\nupgrading dependencies...');
    for (final package in examples) {
      await _upgradeDependencies(package);
    }

    print('\nbuilding examples...');
    for (final package in examples) {
      await _buildPackage(package);
    }

    print(green('successfully recreated platform folders 🎉'));
  }

  Future<void> _upgradeDependencies(DartPackage package) async {
    final packageName = PubSpec.loadFromPath(package.pubspec.path).name;
    final dir = package.root;

    await flutter(
      ['pub', 'upgrade'],
      workingDirectory: dir,
      progress: Progress.printStdErr(),
    );

    print('- $packageName ✅ ');
  }

  Future<void> _buildPackage(DartPackage package) async {
    final packageName = PubSpec.loadFromPath(package.pubspec.path).name;
    final dir = package.root;

    stdout.write('Building $packageName');

    Future<void> build({
      required String platformName,
      required List<String> buildArgs,
      bool Function()? skip,
    }) async {
      if (skip?.call() == true) {
        stdout.write(', $platformName ⏩ ');
        return;
      }
      final completion = await flutter(
        ['build', ...buildArgs],
        workingDirectory: dir,
        progress: Progress.devNull(),
        // silently fail when one platform is not supported
        nothrow: true,
      );
      if (completion.exitCode != 0) {
        stdout.write(', ${buildArgs.first} ❌ ');
      } else {
        stdout.write(', ${buildArgs.first} ✅ ');
      }
    }

    await build(platformName: 'web', buildArgs: ['web']);
    await build(platformName: 'android', buildArgs: ['apk']);
    await build(platformName: 'ios', buildArgs: ['ios', '--no-codesign']);
    await build(
      platformName: 'macos',
      buildArgs: ['macos'],
      skip: () => !Platform.isMacOS,
    );
    await build(
      platformName: 'win',
      buildArgs: ['windows'],
      skip: () => !Platform.isWindows,
    );
    await build(
      platformName: 'linux',
      buildArgs: ['linux'],
      skip: () => !Platform.isLinux,
    );

    stdout.write('\n');
  }
}

Future<void> _printFlutterVersion() async {
  final capture = dcli.Progress.capture(captureStderr: false);
  await flutter(['--version'], progress: capture);
  print(
    'Rebuilding examples with ${capture.lines.firstOrNull ?? "unknown Flutter version"}',
  );
}

Future<void> _recreatePlatformFolders(DartPackage package) async {
  final packageName = PubSpec.loadFromPath(package.pubspec.path).name;
  final dir = package.root;

  dir.directory('.dart_tool').saveDeleteSync();
  dir.directory('build').saveDeleteSync();

  dir.directory('android').saveDeleteSync();
  dir.directory('ios').saveDeleteSync();
  dir.directory('linux').saveDeleteSync();
  dir.directory('macos').saveDeleteSync();
  dir.directory('web').saveDeleteSync();
  dir.directory('windows').saveDeleteSync();

  await flutter(
    [
      'create',
      '--org=io.wiredash.example',
      '--project-name=$packageName',
      '--offline',
      '.',
    ],
    workingDirectory: dir,
    progress: Progress.printStdErr(),
  );

  dir.directory('test').saveDeleteSync();

  print('- example $packageName ✅ ');
}

extension on FileSystemEntity {
  void saveDeleteSync() {
    if (existsSync()) {
      deleteSync(recursive: true);
    }
  }
}
