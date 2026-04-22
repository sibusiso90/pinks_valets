import 'package:flutter/services.dart';

/// Thin haptics wrapper. Centralises tactile feedback so primary actions,
/// selection changes, and success / error moments all feel consistent.
///
/// Using the platform APIs directly (HapticFeedback.*) is fine — this just
/// gives us named intents so screens don't have to reason about which API
/// to pick for a given moment.
class Haptics {
  Haptics._();

  /// A short, soft tick — selection changes (chip, tab, slot pick).
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// A slightly heavier tap — primary button press.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium impact — confirming an action (confirm & pay, submit).
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Strong impact — celebratory moments (booking confirmed).
  static Future<void> heavy() => HapticFeedback.heavyImpact();
}
