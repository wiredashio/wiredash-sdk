import 'package:flutter/material.dart';
import 'package:wiredash/src/capture/capture_widget.dart';
import 'package:wiredash/src/common/state/wiredash_state.dart';
import 'package:wiredash/src/common/state/wiredash_state_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
import 'package:wiredash/src/common/translation/wiredash_translation_data.dart';
import 'package:wiredash/src/common/widgets/wiredash_app.dart';
import 'package:wiredash/src/wiredash_controller.dart';

/// Capture in-app user feedback, wishes, ratings and much more
///
/// 1. Setup
/// Wrap you Application in [Wiredash] and pass in the apps [Navigator]
///
/// ```dart
/// class MyApp extends StatefulWidget {
///   @override
///   _MyAppState createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   /// Share the app [Navigator] with Wiredash
///   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
///
///   @override
///   Widget build(BuildContext context) {
///     return Wiredash(
///       projectId: "YOUR-PROJECT-ID",
///       secret: "YOUR-SECRET",
///       theme: WiredashThemeData(),
///       navigatorKey: _navigatorKey,
///       child: MaterialApp(
///         navigatorKey: _navigatorKey,
///         title: 'Wiredash Demo',
///         home: DemoHomePage(),
///       ),
///     );
///   }
/// }
/// ```
///
/// 2. Start Wiredash
///
/// ```dart
/// Wiredash.of(context).show();
/// ```
class Wiredash extends StatefulWidget {
  /// Creates a new [Wiredash] Widget which allows users to send feedback,
  /// wishes, ratings and much more
  const Wiredash({
    Key key,
    @required this.projectId,
    @required this.secret,
    @required this.navigatorKey,
    this.theme,
    this.translation,
    @required this.child,
  })  : assert(projectId != null),
        assert(secret != null),
        assert(navigatorKey != null),
        assert(child != null),
        super(key: key);

  /// Reference to the app [Navigator] to show the Wiredash bottom sheet
  final GlobalKey<NavigatorState> navigatorKey;

  /// Your Wiredash projectId
  final String projectId;

  /// Your Wiredash project secret
  final String secret;

  /// Default visual properties, like colors and fonts for the Wiredash bottom
  /// sheet and the screenshot capture UI.
  ///
  /// Dark and light themes are supported, try it!
  ///
  /// ```dart
  /// return Wiredash(
  ///   theme: WiredashThemeData(brightness: Brightness.dark),
  ///   projectId: "...",
  ///   secret: "...",
  ///   child: MyApp(),
  /// );
  /// ```
  final WiredashThemeData theme;

  /// Replace every text in Wiredash and localize it for you audience
  final WiredashTranslationData translation;

  /// Your application
  final Widget child;

  @override
  WiredashWidgetState createState() => WiredashWidgetState();

  /// The [WiredashController] from the closest [Wiredash] instance that
  /// encloses the given context.
  ///
  /// Use it to start Wiredash
  ///
  /// ```dart
  /// Wiredash.of(context).show();
  /// ```
  static WiredashController of(BuildContext context) {
    final state = context.findAncestorStateOfType<WiredashWidgetState>();
    return WiredashController(state);
  }
}

class WiredashWidgetState extends State<Wiredash> {
  final _captureKey = GlobalKey<CaptureWidgetState>();

  WiredashStateData _data;
  WiredashThemeData _theme;
  WiredashTranslationData _translation;

  @override
  void initState() {
    super.initState();
    _data = WiredashStateData(
        _captureKey, widget.navigatorKey, widget.projectId, widget.secret);
    _updateDependencies();
    _data.addListener(_onDataStateChange);
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDependencies();
  }

  @override
  void dispose() {
    _data.removeListener(_onDataStateChange);
    super.dispose();
  }

  void _updateDependencies() {
    _theme = widget.theme ?? WiredashThemeData();
    _translation = widget.translation ?? WiredashTranslationData();
  }

  void _onDataStateChange() {
    setState(() {
      // Call setState to notify child widgets which depend on the data state
    });
  }

  @override
  Widget build(BuildContext context) {
    return WiredashState(
      data: _data,
      child: WiredashTheme(
        data: _theme,
        child: WiredashTranslation(
          data: _translation,
          child: WiredashScaffold(
            child: CaptureWidget(
              key: _captureKey,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  WiredashStateData get data => _data;
}
