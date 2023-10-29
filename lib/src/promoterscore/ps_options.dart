import 'dart:async';

import 'package:wiredash/src/metadata/user_meta_data.dart';

/// Options for the promoter score survey
class PsOptions {
  /// Options for the promoter score survey
  const PsOptions({
    this.frequency,
    this.initialDelay,
    this.collectMetaData,
    this.minimumAppStarts,
  });

  /// The duration between recurring promoter score surveys
  ///
  /// Defaults to 90 days
  ///
  /// Trigger showing the promoter score survey with
  /// `Wiredash.of(context).showPromoterSurvey()`.
  final Duration? frequency;

  /// The number of time the user has to open the app before seeing a survey
  /// for the first time
  ///
  /// Defaults to 3
  ///
  /// To ignore the minimum number of app starts, set it to `0`.
  ///
  /// This setting only works when calling `Wiredash.of(context).showPromoterSurvey()`.
  final int? minimumAppStarts;

  /// Duration the app has to be installed on the device before it becomes
  /// eligible to be surveyed
  ///
  /// Defaults to 7 days
  ///
  /// To remove the initial delay, set it to [Duration.zero].
  ///
  /// This setting only works when calling `Wiredash.of(context).showPromoterSurvey()`.
  final Duration? initialDelay;

  /// Enrich the promoter score survey answer with custom metadata
  ///
  /// This function is called by Wiredash when the user submits the promoter
  /// score survey
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
  final FutureOr<WiredashMetaData> Function(
    CustomizableWiredashMetaData metaData,
  )? collectMetaData;
}

/// When `Wiredash(PsOptions: )` are not set, these default options are used
const PsOptions defaultPsOptions = PsOptions(
  frequency: Duration(days: 90),
  initialDelay: Duration(days: 7),
  minimumAppStarts: 3,
);
