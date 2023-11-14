import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
import 'package:wiredash/src/utils/delay.dart';

/// Holding the state of the promoter score survey
class PsModel extends ChangeNotifier2 {
  PsModel(WiredashServices services) : _services = services;

  final WiredashServices _services;
  Delay? _closeDelay;

  PromoterScoreRating? get score => _score;
  PromoterScoreRating? _score;

  set score(PromoterScoreRating? value) {
    _score = value;
    notifyListeners();
    unawaited(updatePromoterScoreRecord());
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
      _services.wiredashTelemetry.onOpenedPromoterScoreSurvey();
      unawaited(updatePromoterScoreRecord());
    }
  }

  /// Page of the promoter score survey
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
    // Do not call updatePromoterScoreRecord, as it would be called to often.
    // Rely on the submit button
  }

  bool get submitting => _submitting;
  bool _submitting = false;

  /// The error when submitting the promoter score rating
  Object? get submissionError => _submissionError;
  Object? _submissionError;

  Future<void> updatePromoterScoreRecord({bool silentFail = true}) async {
    final submitId = await _services.wuidGenerator.submitId();
    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final sessionMetadata =
        await _services.metaDataCollector.collectSessionMetaData(
      _services.wiredashWidget.psOptions?.collectMetaData
          ?.map((it) => it.asFuture()),
    );
    final flutterInfo = _services.flutterInfoCollector.capture();

    final body = PromoterScoreRequestBody(
      score: score,
      question: _questionInUI!,
      message: message,
      metadata: AllMetaData.from(
        installId: submitId,
        fixedMetadata: fixedMetadata,
        sessionMetadata: sessionMetadata,
        flutterInfo: flutterInfo,
      ),
    );
    try {
      await _services.api.sendPromoterScore(body);
    } catch (e, stack) {
      if (kDevMode) {
        reportWiredashError(e, stack, 'Promoter score start request failed');
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
    if (kDebugMode) print('Submitting Promoter Score ($score)');
    try {
      await updatePromoterScoreRecord(silentFail: false);
      // ignore: avoid_print
      print("Promoter Score Submitted ($score)");
      unawaited(_services.syncEngine.onSubmitPromoterScore());
    } catch (e, stack) {
      _submissionError = e;
      reportWiredashError(e, stack, 'Promoter Score submission failed');
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

enum PromoterScoreRating {
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

extension PsRatingExt on PromoterScoreRating {
  int get intValue {
    switch (this) {
      case PromoterScoreRating.rating0:
        return 0;
      case PromoterScoreRating.rating1:
        return 1;
      case PromoterScoreRating.rating2:
        return 2;
      case PromoterScoreRating.rating3:
        return 3;
      case PromoterScoreRating.rating4:
        return 4;
      case PromoterScoreRating.rating5:
        return 5;
      case PromoterScoreRating.rating6:
        return 6;
      case PromoterScoreRating.rating7:
        return 7;
      case PromoterScoreRating.rating8:
        return 8;
      case PromoterScoreRating.rating9:
        return 9;
      case PromoterScoreRating.rating10:
        return 10;
    }
  }
}

PromoterScoreRating createPsRating(int value) {
  switch (value) {
    case 0:
      return PromoterScoreRating.rating0;
    case 1:
      return PromoterScoreRating.rating1;
    case 2:
      return PromoterScoreRating.rating2;
    case 3:
      return PromoterScoreRating.rating3;
    case 4:
      return PromoterScoreRating.rating4;
    case 5:
      return PromoterScoreRating.rating5;
    case 6:
      return PromoterScoreRating.rating6;
    case 7:
      return PromoterScoreRating.rating7;
    case 8:
      return PromoterScoreRating.rating8;
    case 9:
      return PromoterScoreRating.rating9;
    case 10:
      return PromoterScoreRating.rating10;
  }

  throw "'$value' is not a valid Promoter Score rating";
}
