import 'package:file/local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/wiredash_scaffold.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/pending_feedback_item_storage.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
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
  late GlobalKey<CaptureState> captureKey;
  late GlobalKey<NavigatorState> navigatorKey;

  late UserManager userManager;
  late BuildInfoManager buildInfoManager;

  late WiredashApi _api;
  late FeedbackModel _feedbackModel;

  late WiredashOptionsData _options;
  late WiredashThemeData _theme;

  @override
  void initState() {
    super.initState();
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );

    captureKey = GlobalKey<CaptureState>();
    navigatorKey = widget.navigatorKey;

    _updateDependencies();

    _api = WiredashApi(
      httpClient: Client(),
      projectId: widget.projectId,
      secret: widget.secret,
    );

    userManager = UserManager();
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

    _feedbackModel = FeedbackModel(
      captureKey,
      navigatorKey,
      userManager,
      feedbackSubmitter,
      DeviceInfoGenerator(
        buildInfoManager,
        WidgetsBinding.instance!.window,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDependencies();
  }

  void _updateDependencies() {
    setState(() {
      _options = widget.options ?? WiredashOptionsData();
      _theme = widget.theme ?? WiredashThemeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WiredashProvider(
      userManager: userManager,
      feedbackModel: _feedbackModel,
      child: WiredashOptions(
        data: _options,
        child: WiredashLocalizations(
          child: WiredashTheme(
            data: _theme,
            child: WiredashScaffold(
              child: Capture(
                key: captureKey,
                initialColor: _theme.firstPenColor,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void show() {
    _feedbackModel.show();
  }
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
