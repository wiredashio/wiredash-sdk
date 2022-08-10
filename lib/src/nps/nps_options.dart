import 'dart:async';

import 'package:wiredash/src/metadata/meta_data.dart';

/// Options for the Net promoter score
class NpsOptions {
  /// Options for the Net promoter score
  NpsOptions({
    this.frequency,
    this.newUserDelay,
    this.collectMetaData,
    this.minimumAppStarts,
  });

  /// The duration between recurring NPS surveys
  ///
  /// Defaults to 90 days
  ///
  /// Trigger showing the NPS survey with `Wiredash.of(context).eventuallyShowNps()`
  final Duration? frequency;

  /// The number of time the user has to open the app before seeing a NPS survey
  /// for the first time
  ///
  /// Defaults to 3
  final int? minimumAppStarts;

  /// Duration a user has to use your product before they become be eligible to be surveyed
  ///
  /// Defaults to 7 days
  // TODO implement
  // TODO decide if this should be shipped
  final Duration? newUserDelay;

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

/// When `Wiredash(npsOptions: )` are not set, these default options are used
final NpsOptions defaultNpsOptions = NpsOptions(
  frequency: const Duration(days: 90),
  newUserDelay: const Duration(days: 7),
  minimumAppStarts: 3,
);
