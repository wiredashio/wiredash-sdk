import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_controller.dart';

class CaptureProvider extends InheritedWidget {
  const CaptureProvider({
    Key? key,
    required this.captureUiState,
    required this.sketcherController,
    required Widget child,
  }) : super(key: key, child: child);

  final ValueNotifier<CaptureUiState> captureUiState;
  final SketcherController sketcherController;

  static CaptureProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CaptureProvider>();
  }

  @override
  bool updateShouldNotify(CaptureProvider old) {
    return captureUiState != old.captureUiState ||
        sketcherController != old.sketcherController;
  }
}

extension CaptureProviderExtension on BuildContext {
  ValueNotifier<CaptureUiState>? get captureUiState =>
      CaptureProvider.of(this)?.captureUiState;

  SketcherController? get sketcherController =>
      CaptureProvider.of(this)?.sketcherController;
}
