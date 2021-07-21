import 'dart:ui';

import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/wiredash_model.dart';
import 'package:wiredash/src/media_query_from_window.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';
import 'package:wiredash/src/wiredash_controller.dart';
import 'package:wiredash/src/wiredash_provider.dart';

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
    Key? key,
    required this.projectId,
    required this.secret,
    required this.navigatorKey,
    this.options,
    this.theme,
    required this.child,
  }) : super(key: key);

  /// Reference to the app [Navigator] to show the Wiredash bottom sheet
  final GlobalKey<NavigatorState> navigatorKey;

  /// Your Wiredash projectId
  final String projectId;

  /// Your Wiredash project secret
  final String secret;

  /// Customize Wiredash's behaviour and language
  final WiredashOptionsData? options;

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
  final WiredashThemeData? theme;

  /// Your application
  final Widget child;

  @override
  WiredashState createState() => WiredashState();

  /// The [WiredashController] from the closest [Wiredash] instance that
  /// encloses the given context.
  ///
  /// Use it to start Wiredash
  ///
  /// ```dart
  /// Wiredash.of(context).show();
  /// ```
  static WiredashController? of(BuildContext context) {
    final state = context.findAncestorStateOfType<WiredashState>();
    if (state == null) return null;
    return WiredashController(state._wiredashModel);
  }
}

class WiredashState extends State<Wiredash> {
  late WiredashModel _wiredashModel;

  late WiredashOptionsData _options;
  late WiredashThemeData _theme;

  late BackdropController _backdropController;

  @override
  void initState() {
    super.initState();

    _updateDependencies();

    const fileSystem = LocalFileSystem();
    final storage = PendingFeedbackItemStorage(
      fileSystem,
      SharedPreferences.getInstance,
      () async => (await getApplicationDocumentsDirectory()).path,
    );

    final api = WiredashApi(
      httpClient: Client(),
      projectId: widget.projectId,
      secret: widget.secret,
    );

    final feedbackSubmitter = kIsWeb
        ? DirectFeedbackSubmitter(api)
        : (RetryingFeedbackSubmitter(fileSystem, storage, api)
          ..submitPendingFeedbackItems());

    _backdropController = BackdropController();
    _wiredashModel = WiredashModel(feedbackSubmitter, _backdropController);
  }

  @override
  void dispose() {
    _wiredashModel.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDependencies();
  }

  void _updateDependencies() {
    // TODO fix update _api
    // TODO validate everything gets updated
    setState(() {
      _options = widget.options ?? WiredashOptionsData();
      _theme = widget.theme ?? WiredashThemeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WiredashProvider(
      wiredashModel: _wiredashModel,
      child: WiredashOptions(
        data: _options,
        child: WiredashLocalizations(
          // Both DefaultTextEditingShortcuts and DefaultTextEditingActions are
          // required to make text edits like deletion of characters possible on macOS
          child: DefaultTextEditingShortcuts(
            child: DefaultTextEditingActions(
              child: WiredashTheme(
                data: _theme,
                child: MediaQueryFromWindow(
                  // Directionality required for all Text widgets
                  child: Directionality(
                    textDirection:
                        widget.options?.textDirection ?? TextDirection.ltr,
                    // Localizations required for all Flutter UI widgets
                    child: Localizations(
                      locale: widget.options?.currentLocale ?? window.locale,
                      delegates: const [
                        DefaultMaterialLocalizations.delegate,
                        DefaultCupertinoLocalizations.delegate,
                        DefaultWidgetsLocalizations.delegate,
                      ],
                      // Overlay is required for text edit functions such as copy/paste on mobile
                      child: Overlay(initialEntries: [
                        OverlayEntry(builder: (context) {
                          // use a stateful widget as direct child or hot reload will not work for that widget
                          return WiredashBackdrop(
                            controller: _backdropController,
                            child: widget.child,
                          );
                        })
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
