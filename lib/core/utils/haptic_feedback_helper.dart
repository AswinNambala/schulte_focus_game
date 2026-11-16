import 'package:flutter/services.dart';

class HapticFeedbackHelper {
  static bool enabled = true;

  static void lightImpact() {
    if (enabled) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact() {
    if (enabled) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact() {
    if (enabled) {
      HapticFeedback.heavyImpact();
    }
  }

  static void errorImpact() {
    if (enabled) {
      HapticFeedback.vibrate();
    }
  }
}
