import 'package:sidekick_core/sidekick_core.dart';
import 'package:dcli/dcli.dart' as dcli;

class SyncBranchesCommand extends Command {
  @override
  final String description =
      'Synchronizes the stable and beta branches to point to the same commit';

  @override
  final String name = 'sync-branches';

  @override
  Future<void> run() async {
    try {
      await git('diff-index --name-status --exit-code HEAD');
    } catch (e) {
      throw 'Detected local changes. Please commit or stash them before running this command.';
    }

    await git('checkout stable');
    await git('pull --ff-only');

    await git('checkout beta');
    await git('pull --ff-only');
    await git('merge stable --ff');

    await git('push origin beta');

    await git('checkout stable');
  }

  Future<void> git(String args) async {
    dcli.run('git $args', workingDirectory: SidekickContext.projectRoot.path);
  }
}
