// ignore: must_be_immutable
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/utils/build_info.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

// ignore: must_be_immutable
class MockGlobalKey<T extends State<StatefulWidget>> extends Mock
    implements GlobalKey<T> {}

class MockUserManager extends Mock implements UserManager {}

class MockBuildInfoManager extends Mock implements BuildInfoManager {}

class MockBuildInfo extends Mock implements BuildInfo {}

class MockRetryingFeedbackSubmitter extends Mock
    implements RetryingFeedbackSubmitter {}
