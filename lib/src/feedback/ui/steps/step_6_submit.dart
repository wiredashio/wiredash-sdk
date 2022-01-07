import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({Key? key}) : super(key: key);

  @override
  State<Step6Submit> createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  @override
  Widget build(BuildContext context) {
    final model = context.feedbackModel;
    return StepPageScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'Submit your feedback',
              style: context.theme.titleTextStyle,
              textAlign: TextAlign.left,
            ),
            Flexible(
              child: ScrollBox(
                child: ListTileTheme(
                  data: ListTileThemeData(
                    textColor: context.theme.secondaryTextColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Please review your data before submission. '
                        'You can navigate back to adjust your feedback',
                        style: context.theme.body2TextStyle,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Details',
                        style: context.theme.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      FutureBuilder<PersistedFeedbackItem>(
                        future: model.createFeedback(),
                        builder: (context, snapshot) {
                          final data = snapshot.data;
                          if (data == null) {
                            return const SizedBox();
                          }
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Message'),
                                subtitle: Text(data.message),
                              ),
                              if (model.selectedLabels.isNotEmpty)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Labels'),
                                  subtitle: Text(
                                    model.selectedLabels
                                        .map((it) => it.title)
                                        .join(', '),
                                  ),
                                ),
                              if (model.hasScreenshots)
                                const ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('Screenshots'),
                                  // TODO add exact number
                                  subtitle: Text('1 Screenshot'),
                                ),
                              if (data.email != null)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Contact email'),
                                  subtitle: Text(data.email ?? ''),
                                ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Locale'),
                                subtitle: Text(
                                  data.appInfo.appLocale,
                                ),
                              ),
                              if (data.deviceInfo.userAgent != null)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('User agent'),
                                  subtitle:
                                      Text('${data.deviceInfo.userAgent}'),
                                ),
                              if (!kIsWeb)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Platform'),
                                  subtitle: Text(
                                    '${data.deviceInfo.platformOS} '
                                    '${data.deviceInfo.platformOSVersion} '
                                    '(${data.deviceInfo.platformLocale})',
                                  ),
                                ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Build Info'),
                                subtitle: Text(
                                  [
                                    data.buildInfo.compilationMode,
                                    data.buildInfo.buildNumber,
                                    data.buildInfo.buildVersion,
                                    data.buildInfo.buildCommit
                                  ].where((it) => it != null).join(', '),
                                ),
                              ),
                              if (!kIsWeb)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Dart version'),
                                  subtitle: Text(
                                      '${data.deviceInfo.platformVersion}'),
                                ),
                              if (data.customMetaData != null)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Custom metaData'),
                                  subtitle: Text(
                                    data.customMetaData!.entries
                                        .map((it) => '${it.key}=${it.value}, ')
                                        .join(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
