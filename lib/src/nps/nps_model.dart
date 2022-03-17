import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/feedback/data/delay.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
import 'package:wiredash/src/utils/object_util.dart';

class NpsModel extends ChangeNotifier2 {
  NpsModel(WiredashServices services) : _services = services;

  final WiredashServices _services;
  Delay? _closeDelay;
  NpsScore? get score => _rating;
  NpsScore? _rating;

  set score(NpsScore? rating) {
    _rating = rating;
    notifyListeners();
  }

  String? get message => _message;
  String? _message;

  set message(String? message) {
    _message = message;
    notifyListeners();
  }

  bool get submitting => _submitting;
  bool _submitting = false;

  Future<void> submit() async {
    _submitting = true;
    notifyListeners();
    if (kDebugMode) print('Submitting nps ($score)');
    try {
      final deviceId = await _services.deviceIdGenerator.deviceId();
      final deviceInfo = _services.deviceInfoGenerator.generate();
      final metaData = _services.wiredashModel.metaData;
      // Allow devs to collect additional information
      await _services.wiredashWidget.feedbackOptions?.collectMetaData
          ?.call(metaData);

      final body = NpsRequestBody(
        score: score!,
        message: message,
        sdkVersion: wiredashSdkVersion,
        deviceId: deviceId,
        userId: metaData.userId,
        userEmail: metaData.userEmail,
        appLocale: _services.wiredashOptions.currentLocale.toLanguageTag(),
        platformLocale: deviceInfo.platformLocale,
        platformOS: deviceInfo.platformOS,
        platformUserAgent: deviceInfo.userAgent,
      );
      await _services.api.sendNps(body);
      _closeDelay?.dispose();
      _closeDelay = Delay(const Duration(seconds: 1));
      await _closeDelay!.future;
      _submitting = false;
      notifyListeners();
      await returnToAppPostSubmit();
    } catch (e, stack) {
      reportWiredashError(e, stack, 'NPS submission failed');
      _submitting = false;
      notifyListeners();
      await returnToAppPostSubmit();
      rethrow;
    }
  }

  Future<void> returnToAppPostSubmit() async {
    await _services.wiredashModel.hide(discardNps: true);
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
