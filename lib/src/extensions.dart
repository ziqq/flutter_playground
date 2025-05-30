import 'package:flutter/material.dart' show BuildContext, Theme, ThemeData, MediaQuery, MediaQueryData;
import 'package:intl/intl.dart' as intl;

/// {@template int_extensions}
/// Extensions for [int].
/// {@endtemplate}
extension IntExtension on int {
  /// Append leading zero to the integer if it is less than 10.
  String appendLeadingZero() => toString().padLeft(2, '0');
}

/// A utility with extensions for [DateTime].
extension DateTimeExtension on DateTime {
  static final intl.DateFormat _formatter = intl.DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Returns [DateTime] without timestamp.
  DateTime get withoutTime => DateTime(year, month, day);

  /* sendToServer(dateTime.toIso8601String()); <= PROBLEM */
  /// Never use `DateTime.toIso8601String()` on a local date
  /// to serialize and pass to the server or database.
  /// Since this method does not add a timezone padding
  /// to the resulting string.
  /// This will 100% lead to errors!
  ///
  /// Use toLocalIso8601String instead and it will be fine.
  String toLocalIso8601String() {
    final dateTime = toLocal();
    final tz = dateTime.timeZoneOffset;

    final buffer = StringBuffer()
      ..write(_formatter.format(dateTime))
      ..write(tz.isNegative ? '-' : '+')
      ..write(tz.inHours.abs().toString().padLeft(2, '0'))
      ..write(':')
      ..write((tz.inMinutes.abs() % 60).toString().padLeft(2, '0'));

    return buffer.toString();
  }

  /// Checks the [DateTime] with [target] and return result as [bool]
  /// [withoutYear] says whether to check along with the year or not
  bool sameDay({DateTime? target, bool withTime = false, bool withoutYear = false}) {
    final t = target ?? DateTime.now();
    if (withoutYear) return t.month == month && t.day == day;
    if (withTime) return t.year == year && t.month == month && t.day == day && t.hour == hour && t.minute == minute;
    return t.year == year && t.month == month && t.day == day;
  }
}

/// {@template context_extensions}
/// Extensions for [BuildContext].
/// {@endtemplate}
extension ContextExtension on BuildContext {
  /// Get [ThemeData] from current context.
  ThemeData get theme => Theme.of(this);

  /// Get [MediaQueryData] from current context.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Check device has bottom notch.
  bool get hasBottomNotch => mediaQuery.viewPadding.bottom > 0 || mediaQuery.systemGestureInsets.bottom != 0;

  /// Get bottom offset.
  double get bottomNotch =>
      mediaQuery.viewPadding.bottom > 0 ? mediaQuery.viewPadding.bottom : mediaQuery.systemGestureInsets.bottom;

  /// Check keyboard white space.
  double get keyboardWhiteSpace => mediaQuery.viewInsets.bottom;

  /// Check keyboard is opening.
  bool get keyboardIsOpen => keyboardWhiteSpace > 0;

  /// Get device screen height.
  double get screenHeight => mediaQuery.size.height;

  /// Get device screen width.
  double get screenWidth => mediaQuery.size.width;
}
