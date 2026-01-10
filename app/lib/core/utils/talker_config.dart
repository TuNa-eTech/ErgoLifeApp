import 'package:talker_flutter/talker_flutter.dart';

/// Global Talker instance for logging and error tracking
class TalkerConfig {
  static late Talker talker;

  /// Initialize Talker with default settings
  static void initialize() {
    talker = TalkerFlutter.init();
  }
}
