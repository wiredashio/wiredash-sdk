import 'package:sidekick_core/sidekick_core.dart';

class TestCommand extends Command {
  @override
  final String description =
      'Runs all test in all packages with tests or a single package';

  @override
  final String name = 'test';

  TestCommand() {
    argParser
      ..addFlag('all', hide: true, help: 'deprecated')
      ..addOption('package', abbr: 'p');
  }

  @override
  Future<void> run() async {
    final collector = _TestResultCollector();

    final String? packageArg = argResults?['package'] as String?;

    if (packageArg != null) {
      // only run tests in selected package
      final result = await _testPackageWithName(packageArg);
      collector.add(result);
      return;
    }

    // outside of package, fallback to all packages
    for (final package in findAllPackages(SidekickContext.projectRoot)) {
      final result = await _test(package, false);
      collector.add(result);
      print('\n');
    }

    exit(collector.exitCode);
  }

  Future<_TestResult> _testPackageWithName(String name) async {
    // only run tests in selected package
    final allPackages = findAllPackages(SidekickContext.projectRoot);
    final package = allPackages.firstOrNullWhere((it) => it.name == name);
    if (package == null) {
      final packageOptions = allPackages
          .map((it) => it.name)
          .toList(growable: false);
      error(
        'Could not find package $name. '
        'Please use one of ${packageOptions.joinToString()}',
      );
    }
    return await _test(package, true);
  }

  Future<_TestResult> _test(DartPackage package, bool requireTests) async {
    print(yellow('=== package ${package.name} ==='));
    if (!package.testDir.existsSync()) {
      if (requireTests) {
        error(
          'Could not find a test folder in package ${package.name}. '
          'Please create some tests first.',
        );
      } else {
        print("No tests");
        return _TestResult.noTests;
      }
    }

    final Future<ProcessCompletion> completion = () {
      if (package.isFlutterPackage) {
        return flutter(['test'], workingDirectory: package.root);
      } else {
        return dart(['test'], workingDirectory: package.root);
      }
    }();
    final exitCode = (await completion).exitCode;
    if (exitCode == 0) {
      return _TestResult.success;
    }
    return _TestResult.failed;
  }
}

class _TestResultCollector {
  final List<_TestResult> _results = [];
  void add(_TestResult result) {
    _results.add(result);
  }

  int get exitCode {
    if (_results.contains(_TestResult.failed)) {
      return -1;
    }
    if (_results.contains(_TestResult.success)) {
      return 0;
    }
    // no tests or all skipped
    return -2;
  }
}

enum _TestResult { success, failed, noTests }
