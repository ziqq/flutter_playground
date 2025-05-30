import 'package:flutter/material.dart' show TimeOfDay, Color, Colors;
import 'package:meta/meta.dart';

/// Mock services data
const _services = <String>['Service #1', 'Service #2', 'Service #3'];

/// Mock subtitle generated from services
final _subtitle = _services.join(', ').trim();

/// {@template event_model}
/// A model that represents an event for a render object.
/// {@endtemplate}
@immutable
class CalendarEvent {
  /// {@macro event_model}
  const CalendarEvent({
    required this.relationID,
    required this.resourceID,
    required this.start,
    required this.end,
    this.id,
    this.idS,
    this.subtitle,
    this.title = '',
    this.comment = '',
    this.hasNote = false,
    this.isOnline = false,
    this.isChecked = false,
    this.color = const Color(0xff5856D6),
  }) : assert(id != null || idS != null, 'id or idS must be not null');

  /// A [hasNote] used for showing note icon.
  final bool hasNote;

  /// A [isOnline] used for showing online icon.
  final bool isOnline;

  /// A [isChecked] used for showing checked icon.
  final bool isChecked;

  /// An [id] used for unique event.
  final int? id;

  /// An [idS] used for unique event.
  final List<int>? idS;

  /// An [relationID] used relation with parrent event.
  final int relationID;

  /// A [resourceID] used for unique resource.
  final int resourceID;

  /// A [color] used for showing event color.
  /// E.g: new, done, in progress, error.
  final Color color;

  /// A [title] used for showing event title.
  final String title;

  /// A [comment] used for showing event comment.
  final String comment;

  /// A [subtitle] used for showing event subtitle.
  final String? subtitle;

  /// An [end] used for only showing time, not for position. Used when [start] in present day.
  final TimeOfDay end;

  /// A [start] used for only showing time, not for position. Used when [end] in present day.
  final TimeOfDay start;

  /// A list of mock events for testing purposes.
  /// This list contains several predefined [CalendarEvent] instances with various properties.
  static final List<CalendarEvent> mocks = [
    CalendarEvent(
      start: const TimeOfDay(hour: 2, minute: 30),
      end: const TimeOfDay(hour: 4, minute: 0),
      title: '🛠 Maintenance',
      color: Colors.orange,

      // Additional properties
      id: 1,
      relationID: 1,
      resourceID: 1,
      comment: 'Comment #1',
      subtitle: _subtitle,
      hasNote: true,
    ),
    CalendarEvent(
      start: const TimeOfDay(hour: 3, minute: 40),
      end: const TimeOfDay(hour: 5, minute: 40),
      title: '🛠 Maintenance II',
      color: Colors.deepOrangeAccent,

      // Additional properties
      id: 2,
      relationID: 2,
      resourceID: 2,
      comment: 'Comment #2',
      subtitle: _subtitle,
      isOnline: true,
    ),
    CalendarEvent(
      start: const TimeOfDay(hour: 5, minute: 20),
      end: const TimeOfDay(hour: 7, minute: 00),
      title: '🛠 Maintenance III',
      color: Colors.redAccent,

      // Additional properties
      id: 3,
      relationID: 3,
      resourceID: 3,
      comment: 'Comment #2',
      subtitle: _subtitle,
      isChecked: true,
    ),
    CalendarEvent(
      start: const TimeOfDay(hour: 8, minute: 0),
      end: const TimeOfDay(hour: 9, minute: 30),
      title: '☕️ Coffee with Alex',
      color: Colors.green,

      // Additional properties
      id: 4,
      relationID: 4,
      resourceID: 4,
      comment: 'Comment #3',
      subtitle: _subtitle,
    ),
    CalendarEvent(
      start: const TimeOfDay(hour: 15, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
      title: '📞 Call with Team',
      color: Colors.blue,

      // Additional properties
      id: 5,
      relationID: 5,
      resourceID: 5,
      comment: 'Comment #4',
      subtitle: _subtitle,
    ),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent &&
        other.id == id &&
        other.idS == idS &&
        other.relationID == relationID &&
        other.resourceID == resourceID &&
        other.hasNote == hasNote &&
        other.isOnline == isOnline &&
        other.isChecked == isChecked &&
        other.title == title &&
        other.comment == comment &&
        other.color == color &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(
    id,
    idS,
    relationID,
    resourceID,
    hasNote,
    isOnline,
    isChecked,
    title,
    color,
    comment,
    subtitle,
    start,
    end,
  );
}
