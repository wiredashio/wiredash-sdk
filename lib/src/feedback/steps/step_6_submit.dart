import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class Step6Submit extends StatefulWidget {
  const Step6Submit({super.key});

  @override
  State<Step6Submit> createState() => _Step6SubmitState();
}

class _Step6SubmitState extends State<Step6Submit> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      indicator: const FeedbackProgressIndicator(
        flowStatus: FeedbackFlowStatus.submit,
      ),
      title: Text(context.l10n.feedbackStep6SubmitTitle),
      breadcrumbTitle: Text(context.l10n.feedbackStep6SubmitBreadcrumbTitle),
      description: Text(context.l10n.feedbackStep6SubmitDescription),
      discardLabel: Text(context.l10n.feedbackDiscardButton),
      discardConfirmLabel: Text(context.l10n.feedbackDiscardConfirmButton),
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TronButton(
                    color: context.theme.secondaryColor,
                    leadingIcon: Wirecons.arrow_left,
                    label: context.l10n.feedbackBackButton,
                    onTap: context.feedbackModel.goToPreviousStep,
                  ),
                  TronButton(
                    label: context.l10n.feedbackStep6SubmitSubmitButton,
                    leadingIcon: Wirecons.check,
                    onTap: () {
                      context.feedbackModel.submitFeedback();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TronLabeledButton(
                    child: Text(
                      showDetails
                          ? context
                              .l10n.feedbackStep6SubmitSubmitHideDetailsButton
                          : context
                              .l10n.feedbackStep6SubmitSubmitShowDetailsButton,
                    ),
                    onTap: () {
                      StepPageScaffold.of(context)?.animateNextSizeChange();
                      setState(() {
                        showDetails = !showDetails;
                      });
                    },
                  ),
                ],
              ),
              if (showDetails) feedbackDetails(),
            ],
          );
        },
      ),
    );
  }

  Widget feedbackDetails() {
    final model = context.feedbackModel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTileTheme(
        textColor: context.theme.secondaryTextOnBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              context.l10n.feedbackStep6SubmitSubmitDetailsTitle,
              style: context.text.adaptiveBody2.onBackground.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            FutureBuilder<PersistedFeedbackItem>(
              future: model.createFeedback(),
              builder: (context, snapshot) {
                StepPageScaffold.of(context)?.animateNextSizeChange();
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
                          model.selectedLabels.map((it) => it.title).join(', '),
                        ),
                      ),
                    if (model.hasAttachments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Screenshots'),
                        subtitle:
                            Text('${model.attachments.length} Screenshot'),
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
                        subtitle: Text('${data.deviceInfo.userAgent}'),
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
                          data.buildInfo.buildCommit,
                        ].where((it) => it != null).join(', '),
                      ),
                    ),
                    if (!kIsWeb)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dart version'),
                        subtitle: Text(
                          '${data.deviceInfo.platformVersion}',
                        ),
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
    );
  }
}
