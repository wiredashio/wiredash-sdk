import 'dart:async';

import 'package:wiredash/src/metadata/meta_data.dart';

/// Options for the Net promoter score
class NpsOptions {
  /// Options for the Net promoter score
  NpsOptions({
    this.frequency,
    this.newUserDelay,
    this.appStartInitialDelay,
    this.collectMetaData,
  });

  /// The duration between recurring NPS surveys
  ///
  /// Defaults to 90 days
  // TODO implement
  final Duration? frequency;

  /// Duration a user has to use your product before they become be eligible to be surveyed
  ///
  /// Defaults to 7 days
  // TODO implement
  final Duration? newUserDelay;

  /// The duration after appStart before the NPS survey is shown
  ///
  /// When not set, Wiredash will not show a survey automatically
  // TODO implement
  final Duration? appStartInitialDelay;

  /// Enrich the user feedback with custom metadata
  ///
  /// This function is called by Wiredash when the user (optional) takes a
  /// screenshot or right before submitting feedback.
  ///
  /// Mutate the incoming `metaData` object and add or override values
  ///
  /// ```dart
  /// feedbackOptions: WiredashFeedbackOptions(
  ///   collectMetaData: (metaData) => metaData
  ///     ..userEmail = 'dash@wiredash.io'
  ///     ..custom['isPremium'] = false
  ///     ..custom['nested'] = {'wire': 'dash'},
  /// ```
  final FutureOr<CustomizableWiredashMetaData> Function(
    CustomizableWiredashMetaData metaData,
  )? collectMetaData;
}

final NpsOptions defaultNpsOptions = NpsOptions(
  frequency: const Duration(days: 90),
  newUserDelay: const Duration(days: 7),
);
