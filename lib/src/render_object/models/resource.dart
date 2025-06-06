// Autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playground/src/extensions.dart';
import 'package:meta/meta.dart';

/// {@template resource_model}
/// The [CalendarResource] class is a data model
/// that represents a resource in the calendar.
/// {@endtemplate}
@immutable
class CalendarResource {
  /// {@macro resource_model}
  const CalendarResource({
    required this.id,
    required this.name,
    required this.color,
    required this.avatar,
    this.intervals = const <CalendarTimeInterval>[],
  });

  /// The unique identifier of the resource.
  final int id;

  /// The name of the resource.
  final String name;

  /// The color of the resource.
  final String? color;

  /// The avatar of the resource.
  /// This is a URL to the avatar image.
  final String? avatar;

  /// The intervals of the resource.
  final List<CalendarTimeInterval> intervals;

  /// Mock data for testing purposes.
  static const List<CalendarResource> $mocks = [
    CalendarResource(
      id: 1,
      name: 'Resource #1',
      color: '#FF5733',
      avatar: 'https://example.com/avatar1.png',
      intervals: [
        CalendarTimeInterval(start: TimeOfDay(hour: 9, minute: 0), end: TimeOfDay(hour: 12, minute: 0)),
        CalendarTimeInterval(start: TimeOfDay(hour: 13, minute: 0), end: TimeOfDay(hour: 17, minute: 0)),
      ],
    ),
    CalendarResource(id: 2, name: 'Resource #2', color: '#33FF57', avatar: 'https://example.com/avatar2.png'),
    // CalendarResource(id: 3, name: 'Resource #3', color: '#3357FF', avatar: 'https://example.com/avatar3.png'),
  ];

  @override
  String toString() => 'CalendarResource.$id{name: $name, color: $color, avatar: $avatar, intervals: $intervals}';

  @override
  bool operator ==(covariant CalendarResource other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.color == color &&
        other.avatar == avatar &&
        listEquals(other.intervals, intervals);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ color.hashCode ^ avatar.hashCode ^ intervals.hashCode;
}

/// {@template time_interval}
/// The [CalendarTimeInterval] class is a data model
/// that represents a time interval.
/// {@endtemplate}
@immutable
class CalendarTimeInterval {
  /// {@macro time_interval}
  const CalendarTimeInterval({required this.start, required this.end});

  /// Return interval with default values
  /// [start.hour]: 9
  /// [end.hour]: 18
  @literal
  const factory CalendarTimeInterval.empty() = _CalendarTimeInterval$Empty;

  /// Create a [CalendarTimeInterval] from a `Map<String, Object?>` object.
  factory CalendarTimeInterval.fromJson(Map<String, Object?> json) => CalendarTimeInterval(
    start: json['start'] != null ? json['start'].toString().toTimeOfDay() : const TimeOfDay(hour: 9, minute: 0),
    end: json['end'] != null ? json['end'].toString().toTimeOfDay() : const TimeOfDay(hour: 18, minute: 0),
  );

  /// The start time of the interval.
  final TimeOfDay start;

  /// The end time of the interval.
  final TimeOfDay end;

  CalendarTimeInterval copyWith({TimeOfDay? start, TimeOfDay? end}) =>
      CalendarTimeInterval(start: start ?? this.start, end: end ?? this.end);

  Map<String, Object?> toJson() => {'timeStart': start.toFormattedString(), 'timeEnd': end.toFormattedString()};

  @override
  String toString() => 'CalendarTimeInterval{start: $start, end: $end}';

  @override
  bool operator ==(Object other) {
    if (other is! CalendarTimeInterval) return false;
    return identical(this, other) || (start == other.start && end == other.end);
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// {@macro time_interval}
/// Empty entity of [CalendarTimeInterval]
final class _CalendarTimeInterval$Empty extends CalendarTimeInterval {
  /// {@macro time_interval}
  const _CalendarTimeInterval$Empty()
    : super(start: const TimeOfDay(hour: 9, minute: 0), end: const TimeOfDay(hour: 18, minute: 0));
}
