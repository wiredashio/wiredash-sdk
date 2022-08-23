import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
import 'package:wiredash/src/utils/delay.dart';

class NpsModel extends ChangeNotifier2 {
  NpsModel(WiredashServices services) : _services = services;

  final WiredashServices _services;
  Delay? _closeDelay;

  NpsScore? get score => _score;
  NpsScore? _score;

  set score(NpsScore? value) {
    _score = value;
    notifyListeners();
    unawaited(updateNpsRecord());
  }

  // The question that was shown to the use to be send to the backend
  String? _questionInUI;
  bool _submittedQuestionSeen = false;

  // ignore: unnecessary_getters_setters
  String? get questionInUI => _questionInUI;

  set questionInUI(String? questionInUI) {
    _questionInUI = questionInUI;
    if (!_submittedQuestionSeen) {
      _submittedQuestionSeen = true;
      _services.wiredashTelemetry.onOpenedNpsSurvey();
      unawaited(updateNpsRecord());
    }
  }

  /// Page of the NPS survey
  int _index = 0;

  int get index => _index;

  set index(int index) {
    _index = index;
    notifyListeners();
  }

  // The message the user want to attach
  String? _message;

  String? get message => _message;

  set message(String? message) {
    _message = message;
    notifyListeners();
    // Do not call updateNpsRecord, as it would be called to often.
    // Rely on the submit button
  }

  bool get submitting => _submitting;
  bool _submitting = false;

  /// The error when submitting the nps rating
  Object? get submissionError => _submissionError;
  Object? _submissionError;

  Future<void> updateNpsRecord({bool silentFail = true}) async {
    final deviceId = await _services.deviceIdGenerator.deviceId();
    final deviceInfo = _services.deviceInfoGenerator.generate();
    final metaData = _services.wiredashModel.metaData;
    // Allow devs to collect additional information
    final collector = _services.wiredashModel.npsOptions.collectMetaData;
    await collector?.call(metaData);

    final body = NpsRequestBody(
      score: score,
      question: _questionInUI!,
      message: message,
      sdkVersion: wiredashSdkVersion,
      deviceId: deviceId,
      userId: metaData.userId,
      userEmail: metaData.userEmail,
      appLocale: _services.wiredashModel.appLocaleFromContext?.toLanguageTag(),
      platformLocale: deviceInfo.platformLocale,
      platformOS: deviceInfo.platformOS,
      platformUserAgent: deviceInfo.userAgent,
      buildInfo: buildInfo,
    );
    try {
      await _services.api.sendNps(body);
    } catch (e, stack) {
      if (kDevMode) {
        reportWiredashError(e, stack, 'NPS start request failed');
      } else {
        if (silentFail) {
          // fail silently
        } else {
          rethrow;
        }
      }
    }
  }

  Future<void> submit() async {
    _submitting = true;
    notifyListeners();
    if (kDebugMode) print('Submitting nps ($score)');
    try {
      await updateNpsRecord(silentFail: false);
      // ignore: avoid_print
      print("NPS Submitted ($score)");
      unawaited(_services.syncEngine.onSubmitNPS());
    } catch (e, stack) {
      _submissionError = e;
      reportWiredashError(e, stack, 'NPS submission failed');
    } finally {
      _closeDelay?.dispose();
      _closeDelay = Delay(const Duration(seconds: 2));
      await _closeDelay!.future;
      await returnToAppPostSubmit();
    }
  }

  Future<void> returnToAppPostSubmit() async {
    await _services.wiredashModel.hide();
  }
}

enum NpsScore {
  rating0,
  rating1,
  rating2,
  rating3,
  rating4,
  rating5,
  rating6,
  rating7,
  rating8,
  rating9,
  rating10,
}

extension NpsRatingExt on NpsScore {
  int get intValue {
    switch (this) {
      case NpsScore.rating0:
        return 0;
      case NpsScore.rating1:
        return 1;
      case NpsScore.rating2:
        return 2;
      case NpsScore.rating3:
        return 3;
      case NpsScore.rating4:
        return 4;
      case NpsScore.rating5:
        return 5;
      case NpsScore.rating6:
        return 6;
      case NpsScore.rating7:
        return 7;
      case NpsScore.rating8:
        return 8;
      case NpsScore.rating9:
        return 9;
      case NpsScore.rating10:
        return 10;
    }
  }
}

NpsScore createNpsRating(int value) {
  switch (value) {
    case 0:
      return NpsScore.rating0;
    case 1:
      return NpsScore.rating1;
    case 2:
      return NpsScore.rating2;
    case 3:
      return NpsScore.rating3;
    case 4:
      return NpsScore.rating4;
    case 5:
      return NpsScore.rating5;
    case 6:
      return NpsScore.rating6;
    case 7:
      return NpsScore.rating7;
    case 8:
      return NpsScore.rating8;
    case 9:
      return NpsScore.rating9;
    case 10:
      return NpsScore.rating10;
  }

  throw "'$value' is not a valid NPS rating";
}
