import 'package:dcli/dcli.dart' as dcli;
import 'package:sidekick_core/sidekick_core.dart';

class RecreateExamplesCommand extends Command {
  @override
  final String description = 'Recreates the platform folder for all examples';

  @override
  final String name = 'recreate-examples';

  @override
  Future<void> run() async {
    _printFlutterVersion();

    final examplesDir = SidekickContext.projectRoot.directory('examples');
    final examples = examplesDir
        .listSync()
        .whereType<Directory>()
        .mapNotNull((it) => DartPackage.fromDirectory(it))
        .toList();

    print('\nrecreating platform folders...');
    for (final package in examples) {
      _recreatePlatformFolders(package);
    }

    print('\nbuilding examples...');
    for (final package in examples) {
      _buildPackage(package);
    }

    print(green('successfully recreated platform folders 🎉'));
  }

  void _buildPackage(DartPackage package) {
    final packageName = PubSpec.fromFile(package.pubspec.path).name;
    final dir = package.root;

    stdout.write('Building $packageName');

    void build(List<String> buildArgs) {
      final exit = flutter(
        ['build', ...buildArgs],
        workingDirectory: dir,
        progress: Progress.devNull(),
        // silently fail when one platform is not supported
        nothrow: true,
      );
      if (exit != 0) {
        stdout.write(', ${buildArgs.first} ❌');
      } else {
        stdout.write(', ${buildArgs.first} ✅');
      }
    }

    build(['web']);
    build(['apk']);
    build(['ios', '--no-codesign']);
    build(['macos']);
    build(['windows']);
    build(['linux']);

    stdout.write('\n');
  }
}

void _printFlutterVersion() {
  final capture = dcli.Progress.capture(captureStderr: false);
  flutter(['--version'], progress: capture);
  print(
    'Rebuilding examples with ${capture.lines.firstOrNull ?? "unknown Flutter version"}',
  );
}

void _recreatePlatformFolders(DartPackage package) {
  final packageName = PubSpec.fromFile(package.pubspec.path).name;
  final dir = package.root;

  dir.directory('android').saveDeleteSync();
  dir.directory('ios').saveDeleteSync();
  dir.directory('linux').saveDeleteSync();
  dir.directory('macos').saveDeleteSync();
  dir.directory('web').saveDeleteSync();
  dir.directory('windows').saveDeleteSync();

  flutter(
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

  print('- example $packageName ✅');
}

extension on FileSystemEntity {
  void saveDeleteSync() {
    if (existsSync()) {
      deleteSync(recursive: true);
    }
  }
}
