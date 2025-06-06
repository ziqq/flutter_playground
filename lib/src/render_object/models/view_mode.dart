import 'dart:convert';

/// {@template calendar_view_mode}
/// CalendarViewMode enumeration
/// {@endtemplate}
enum CalendarViewMode implements Comparable<CalendarViewMode> {
  /// day
  day('unit'),

  /// week
  week('week'),

  /// month
  month('month'),

  /// list
  list('list');

  /// {@macro calendar_view_mode}
  const CalendarViewMode(this.alias);

  /// Creates a new instance of [CalendarViewMode] from a given string.
  static CalendarViewMode fromAlias(String? alias, {CalendarViewMode? fallback}) =>
      switch (alias?.trim().toLowerCase()) {
        'unit' => day,
        'week' => week,
        'month' => month,
        'list' => list,
        _ => fallback ?? (throw ArgumentError.value(alias)),
      };

  /// The alias of the mode
  final String alias;

  /// View mode is day.
  bool get isDay => this == day;

  /// View mode is list.
  bool get isList => this == list;

  /// View mode is week.
  bool get isWeek => this == week;

  /// View mode is month.
  bool get isMonth => this == month;

  /// Pattern matching
  T map<T>({
    required T Function() day,
    required T Function() week,
    required T Function() month,
    required T Function() list,
  }) => switch (this) {
    CalendarViewMode.day => day(),
    CalendarViewMode.week => week(),
    CalendarViewMode.month => month(),
    CalendarViewMode.list => list(),
  };

  /// Pattern matching
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? day,
    T Function()? week,
    T Function()? month,
    T Function()? list,
  }) => map<T>(day: day ?? orElse, week: week ?? orElse, month: month ?? orElse, list: list ?? orElse);

  /// Pattern matching
  T? maybeMapOrNull<T>({T Function()? day, T Function()? week, T Function()? month, T Function()? list}) =>
      maybeMap<T?>(orElse: () => null, day: day, week: week, month: month, list: list);

  @override
  int compareTo(CalendarViewMode other) => index.compareTo(other.index);

  @override
  String toString() => alias;

  /// Get a localized alias
  /* String toLocalize(BuildContext context) => switch (this) {
    day => CalendarLocalization.of(context).textDay,
    list => CalendarLocalization.of(context).textList,
    week => CalendarLocalization.of(context).textWeek,
  }; */
}

/// {@template calendar_view_mode_codec}
/// Codec for [CalendarViewMode]
/// {@endtemplate}
final class CalendarViewModeCodec extends Codec<CalendarViewMode, String> {
  /// {@macro calendar_view_mode_codec}
  const CalendarViewModeCodec();

  @override
  Converter<String, CalendarViewMode> get decoder => const _ViewModeDecoder();

  @override
  Converter<CalendarViewMode, String> get encoder => const _ViewModeEncoder();
}

final class _ViewModeDecoder extends Converter<String, CalendarViewMode> {
  const _ViewModeDecoder();

  @override
  CalendarViewMode convert(String input) => switch (input) {
    'CalendarViewMode.day' => CalendarViewMode.day,
    'CalendarViewMode.list' => CalendarViewMode.list,
    'CalendarViewMode.week' => CalendarViewMode.week,
    'CalendarViewMode.month' => CalendarViewMode.month,
    _ => throw ArgumentError.value(input, 'input', 'Cannot convert $input to $CalendarViewMode'),
  };
}

final class _ViewModeEncoder extends Converter<CalendarViewMode, String> {
  const _ViewModeEncoder();

  @override
  String convert(CalendarViewMode input) => switch (input) {
    CalendarViewMode.day => 'CalendarViewMode.day',
    CalendarViewMode.list => 'CalendarViewMode.list',
    CalendarViewMode.week => 'CalendarViewMode.week',
    CalendarViewMode.month => 'CalendarViewMode.month',
  };
}
