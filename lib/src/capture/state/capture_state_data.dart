import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_model.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

class CaptureStateData with ChangeNotifier {
  SketcherModel sketcherModel = SketcherModel();

  Color _selectedPenColor = WiredashThemeData.penColors[0];
  CaptureStatus _captureStatus = CaptureStatus.hidden;

  CaptureStatus get status => _captureStatus;
  set status(CaptureStatus newValue) {
    if (_captureStatus == newValue) return;
    _captureStatus = newValue;
    notifyListeners();
  }

  Color get selectedPenColor => _selectedPenColor;
  set selectedPenColor(Color newValue) {
    if (_selectedPenColor == newValue) return;
    _selectedPenColor = newValue;
    notifyListeners();
  }
}

enum CaptureStatus { hidden, navigate, draw }
