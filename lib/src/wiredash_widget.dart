import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/wiredash_model.dart';
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
    return WiredashController(state);
  }
}

class WiredashState extends State<Wiredash> {
  late GlobalKey<NavigatorState> navigatorKey;

  late BuildInfoManager buildInfoManager;

  late WiredashApi _api;
  late WiredashModel _wiredashModel;

  late WiredashOptionsData _options;
  late WiredashThemeData _theme;

  // TODO save somewhere else
  String? userId;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );

    navigatorKey = widget.navigatorKey;

    _updateDependencies();

    _api = WiredashApi(
      httpClient: Client(),
      projectId: widget.projectId,
      secret: widget.secret,
    );

    buildInfoManager = BuildInfoManager(PlatformBuildInfo());

    const fileSystem = LocalFileSystem();
    final storage = PendingFeedbackItemStorage(
      fileSystem,
      SharedPreferences.getInstance,
      () async => (await getApplicationDocumentsDirectory()).path,
    );

    final feedbackSubmitter = kIsWeb
        ? DirectFeedbackSubmitter(_api)
        : (RetryingFeedbackSubmitter(fileSystem, storage, _api)
          ..submitPendingFeedbackItems());

    _wiredashModel = WiredashModel(feedbackSubmitter);
  }

  @override
  void dispose() {
    _wiredashModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDependencies();
  }

  void _updateDependencies() {
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
          child: WiredashTheme(
            data: _theme,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void show() {
    assert(widget.navigatorKey.currentState != null, '''
Wiredash couldn't access your app's root navigator.

This is likely to happen when you forget to add the navigator key to your 
Material- / Cupertino- or WidgetsApp widget. 

To fix this, simply assign the same GlobalKey you assigned to Wiredash 
to your Material- / Cupertino- or WidgetsApp widget, like so:

return Wiredash(
  projectId: "YOUR-PROJECT-ID",
  secret: "YOUR-SECRET",
  navigatorKey: _navigatorKey, // <-- should be the same
  child: MaterialApp(
    navigatorKey: _navigatorKey, // <-- should be the same
    title: 'Flutter Demo',
    home: ...
  ),
);

For more info on how to setup Wiredash, check out 
https://github.com/wiredashio/wiredash-sdk

If this did not fix the issue, please file an issue at 
https://github.com/wiredashio/wiredash-sdk/issues

Thanks!
''');
  }
  // TODO actually show wiredash
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
