import 'dart:convert';

import 'package:flutter/widgets.dart';

/// {@template calendar_time_mode}
/// Calendar time mode's ennumiration
/// {@endtemplate}
enum CalendarTimeMode {
  /// 5 min
  minutes5(5),

  /// 10 min
  minutes10(10),

  /// 15 min
  minutes15(15),

  /// 30 min
  minutes30(30);

  const CalendarTimeMode(this.minutes);

  /// The value of the time mode in minutes.
  final int minutes;

  /* String getLocalizedValue(BuildContext context) {
    final min = CalendarLocalization.of(context).textMinuteShort;
    return switch (this) {
      minutes5 => '${minutes5.value} $min',
      minutes10 => '${minutes10.value} $min',
      minutes15 => '${minutes15.value} $min',
      minutes30 => '${minutes30.value} $min',
    };
  } */
}

/// {@template calendar_time_mode_codec}
/// Codec for [CalendarTimeMode]
/// {@endtemplate}
final class CalendarTimeModeCodec extends Codec<CalendarTimeMode, String> {
  /// {@macro calendar_time_mode_codec}
  const CalendarTimeModeCodec();

  @override
  Converter<String, CalendarTimeMode> get decoder => const _TimeModeDecoder();

  @override
  Converter<CalendarTimeMode, String> get encoder => const _TimeModeEncoder();
}

final class _TimeModeDecoder extends Converter<String, CalendarTimeMode> {
  const _TimeModeDecoder();

  @override
  CalendarTimeMode convert(String input) => switch (input) {
    'CalendarTimeMode.minutes15' => CalendarTimeMode.minutes15,
    'CalendarTimeMode.minutes5' => CalendarTimeMode.minutes5,
    'CalendarTimeMode.minutes10' => CalendarTimeMode.minutes10,
    'CalendarTimeMode.minutes30' => CalendarTimeMode.minutes30,
    _ => throw ArgumentError.value(input, 'input', 'Cannot convert $input to $CalendarTimeMode'),
  };
}

final class _TimeModeEncoder extends Converter<CalendarTimeMode, String> {
  const _TimeModeEncoder();

  @override
  String convert(CalendarTimeMode input) => switch (input) {
    CalendarTimeMode.minutes15 => 'CalendarTimeMode.minutes15',
    CalendarTimeMode.minutes5 => 'CalendarTimeMode.minutes5',
    CalendarTimeMode.minutes10 => 'CalendarTimeMode.minutes10',
    CalendarTimeMode.minutes30 => 'CalendarTimeMode.minutes30',
  };
}

/// {@template calendar_time_mode_select_data}
/// The [CalendarTimeModeSelectData] class is a data model
/// that represents a time mode select data.
/// {@endtemplate}
@immutable
class CalendarTimeModeSelectData {
  /// {@macro calendar_time_mode_select_data}
  const CalendarTimeModeSelectData({required this.text, required this.value});

  /// The text of the time mode.
  final String text;

  /// The value of the time mode.
  final CalendarTimeMode value;

  @override
  bool operator ==(covariant CalendarTimeModeSelectData other) {
    if (identical(this, other)) return true;
    return other.text == text && other.value == value;
  }

  @override
  int get hashCode => text.hashCode ^ value.hashCode;

  @override
  String toString() => 'CalendarTimeModeSelectData{text: $text, value: $value}';
}
