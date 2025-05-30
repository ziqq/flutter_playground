import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_playground/src/extensions.dart';
import 'package:flutter_playground/src/render_object/event.dart';

/// Default padding.
const double kDefaultPadding = 16;

/// Default height for the hour in the calendar render widget.
const double kDefaultHourHeight = 80;

/// Default width for the timeline in the calendar render widget.
const double kDefaultTimeLineWidth = 50;

/// Default padding for the events in the calendar render widget.
const double kDefaultEventPadding = 5;

/// Default border radius for the events in the calendar render widget.
const double kDefaultEventBorderRadius = 10;

/// A notifier that refreshes the calendar time line every minute.
typedef CalendarTimeLineRefreshController = ValueListenable<DateTime>;

/// A callback that is called when the calendar page changes.
typedef CalendarPageChangeCallBack = void Function(DateTime date, int page);

/// {@template calendar_day_view}
/// Calendar$DayView widget.
/// {@endtemplate}
class Calendar$DayView extends StatefulWidget {
  /// {@macro calendar_day_view}
  const Calendar$DayView({
    required this.events,
    required this.width,
    this.minDate,
    this.maxDate,
    this.startHour = 0,
    this.endHour = 24,
    this.bottomPadding = 0,
    this.secondaryTextStyle,
    this.hourHeight = kDefaultHourHeight,
    this.showCurrentTimeIndicator,
    this.onPageChange,
    super.key, // ignore: unused_element_parameter
  });

  final List<CalendarEvent> events;
  final int startHour;
  final int endHour;
  final double width;
  final double hourHeight;
  final double bottomPadding;
  final DateTime? minDate;
  final DateTime? maxDate;
  final TextStyle? secondaryTextStyle;
  final bool? showCurrentTimeIndicator;

  /// This callback will run whenever page will change.
  final CalendarPageChangeCallBack? onPageChange;

  static final DateTime _minDate = DateTime(1970).withoutTime;

  static final DateTime _maxDate = DateTime(275759).withoutTime;

  @override
  State<Calendar$DayView> createState() => _Calendar$DayViewState();
}

class _Calendar$DayViewState extends State<Calendar$DayView> {
  late DateTime _minDate;
  late DateTime _maxDate;
  late int _totalDays;

  late final ValueNotifier<DateTime> _currentDate;
  late final ValueNotifier<int> _currentIndex;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _minDate = widget.minDate ?? Calendar$DayView._minDate;
    _maxDate = widget.maxDate ?? Calendar$DayView._maxDate;
    _totalDays = _maxDate.getDayDifference(_minDate) + 1;

    _currentDate = ValueNotifier<DateTime>(DateTime.now().withoutTime);
    _currentIndex = ValueNotifier<int>(_currentDate.value.getDayDifference(_minDate));
    _pageController = PageController(initialPage: _currentIndex.value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    _currentDate.dispose();
    super.dispose();
  }

  /// Called when user change page using any gesture or inbuilt functions.
  ///
  void _onPageChange(int index) {
    if (!mounted) return;

    _currentDate.value = DateTime(
      _currentDate.value.year,
      _currentDate.value.month,
      _currentDate.value.day + (index - _currentIndex.value),
    );
    _currentIndex.value = index;

    /* if (!widget.keepScrollOffset) {
      animateToDuration(widget.startDuration);
    } */

    widget.onPageChange?.call(_currentDate.value, _currentIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    final $secondaryTextStyle =
        widget.secondaryTextStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
        ) ??
        DefaultTextStyle.of(context).style.copyWith(fontSize: 12);
    return SizedBox(
      // Calculate the calendar height based on the number of hours and the hour height
      height: (widget.endHour - widget.startHour) * widget.hourHeight + kDefaultPadding * 2 + widget.bottomPadding,
      child: PageView.builder(
        itemCount: _totalDays,
        controller: _pageController,
        onPageChanged: _onPageChange,
        itemBuilder: (context, index) {
          final date = DateTime(_minDate.year, _minDate.month, _minDate.day + index);
          final keyValue = widget.hourHeight.toString() + date.toString();
          final isToday = date.sameDay();
          log('date: $date, isToday: $isToday');
          return Stack(
            key: ValueKey(keyValue),
            children: [
              _CalendarRenderWidget(
                secondaryTextStyle: $secondaryTextStyle,
                bottomPadding: widget.bottomPadding,
                hourHeight: widget.hourHeight,
                startHour: widget.startHour,
                endHour: widget.endHour,
                width: widget.width,
                events: CalendarEvent.mocks,
              ),
              if ((widget.showCurrentTimeIndicator ?? false) || isToday) ...[
                RepaintBoundary(
                  key: ValueKey('calendar_day_view_current_time_indicator_$keyValue'),
                  child: _Calendar$CurrentTimeIndicatorWidget(
                    hourHeight: 80,
                    startHour: 0,
                    textStyle: $secondaryTextStyle,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Виджет с кастомным RenderBox
class _CalendarRenderWidget extends LeafRenderObjectWidget {
  const _CalendarRenderWidget({
    required this.secondaryTextStyle,
    required this.events,
    required this.width,
    this.bottomPadding,
    this.hourHeight = kDefaultHourHeight,
    this.startHour,
    this.endHour,
    super.key, // ignore: unused_element_parameter
  });

  final List<CalendarEvent> events;
  final double width;
  final double hourHeight;
  final double? bottomPadding;
  final int? startHour;
  final int? endHour;
  final TextStyle secondaryTextStyle;

  @override
  RenderObject createRenderObject(BuildContext context) => _CalendarRenderView(
    secondaryTextStyle: secondaryTextStyle,
    bottomPadding: bottomPadding,
    hourHeight: hourHeight,
    startHour: startHour,
    endHour: endHour,
    events: events,
    width: width,
  );

  @override
  void updateRenderObject(BuildContext context, covariant _CalendarRenderView renderObject) {
    renderObject
      ..secondaryTextStyle = secondaryTextStyle
      ..hourHeight = hourHeight
      ..startHour = startHour
      ..endHour = endHour
      ..events = events
      ..width = width;
  }
}

class _CalendarRenderView extends RenderBox {
  _CalendarRenderView({
    required List<CalendarEvent> events,
    required double? bottomPadding,
    required double hourHeight,
    required double width,
    required TextStyle secondaryTextStyle,
    int? startHour,
    int? endHour,
  }) : _startHour = startHour ?? 0,
       _endHour = endHour ?? 24,
       _events = events,
       _width = width,
       _hourHeight = hourHeight,
       _bottomPadding = bottomPadding,
       _secondaryTextStyle = secondaryTextStyle;

  List<CalendarEvent> _events;
  double? _bottomPadding;
  double _hourHeight;
  double _width;
  int _startHour;
  int _endHour;
  TextStyle _secondaryTextStyle;

  // ignore: avoid_setters_without_getters
  set events(List<CalendarEvent> value) {
    if (_events != value) {
      _events = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set bottomPadding(double value) {
    if (_bottomPadding != value) {
      _bottomPadding = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set secondaryTextStyle(TextStyle value) {
    if (_secondaryTextStyle != value) {
      _secondaryTextStyle = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set hourHeight(double value) {
    if (_hourHeight != value) {
      _hourHeight = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set width(double value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set startHour(int? value) {
    if (_startHour != value && value != null) {
      _startHour = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set endHour(int? value) {
    if (_endHour != value && value != null) {
      _endHour = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    // Calculate the calendar height based on the number of hours and the hour height
    final contentHeight = (_endHour - _startHour) * _hourHeight;
    size = Size(_width, contentHeight + kDefaultPadding * 2 + (_bottomPadding ?? 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    _paintTimeLine(canvas, offset);

    final sortedEvents = [..._events]..sort((a, b) => a.start.compareTo(b.start));
    final overlappingGroups = <List<CalendarEvent>>[];

    for (final event in sortedEvents) {
      var added = false;
      for (final group in overlappingGroups) {
        if (group.any((e) => _eventsOverlap(e, event))) {
          group.add(event);
          added = true;
          break;
        }
      }
      if (!added) overlappingGroups.add([event]);
    }

    for (final group in overlappingGroups) {
      final count = group.length;
      for (var i = 0; i < count; i++) {
        final event = group[i];
        _paintEvent(canvas, event, offset, count, i);
      }
    }
  }

  /// Paints a single event on the calendar.
  void _paintEvent(Canvas canvas, CalendarEvent event, Offset offset, int groupSize, int groupIndex) {
    final start = event.start.hour + event.start.minute / 60.0 - _startHour;
    final end = event.end.hour + event.end.minute / 60.0 - _startHour;

    final top = offset.dy + kDefaultPadding + start * _hourHeight;
    final bottom = offset.dy + kDefaultPadding + end * _hourHeight;

    final totalAvailableWidth = size.width - kDefaultTimeLineWidth - kDefaultEventPadding / 2;
    final singleEventWidth = totalAvailableWidth / groupSize;
    final left = offset.dx + kDefaultTimeLineWidth + groupIndex * singleEventWidth + kDefaultEventPadding / 2;

    final rect = Rect.fromLTRB(left, top, left + singleEventWidth - 5, bottom);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(kDefaultEventBorderRadius));

    final timeTextSpan = TextSpan(
      text:
          '${event.start.hour.appendLeadingZero()}:${event.start.minute.appendLeadingZero()} - ${event.end.hour.appendLeadingZero()}:${event.end.minute.appendLeadingZero()}',
      style: _secondaryTextStyle.copyWith(height: 1.2),
    );

    final eventTextSpan = TextSpan(
      text: event.title,
      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
    );

    final subtitleTextSpan = TextSpan(
      text: event.subtitle,
      style: _secondaryTextStyle.copyWith(height: 1.2, overflow: TextOverflow.ellipsis),
    );

    final commentTextSpan = TextSpan(text: event.comment, style: _secondaryTextStyle.copyWith(height: 1.2));

    final textPainters = <TextPainter>[
      TextPainter(text: timeTextSpan, textDirection: TextDirection.ltr),
      TextPainter(text: eventTextSpan, textDirection: TextDirection.ltr),
      TextPainter(text: subtitleTextSpan, textDirection: TextDirection.ltr),
      TextPainter(text: commentTextSpan, textDirection: TextDirection.ltr),
    ];

    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRect(Rect.fromLTRB(rect.left, rect.top, rect.left + 2, rect.bottom), Paint()..color = event.color)
      ..drawRRect(rrect, Paint()..color = event.color.withAlpha(40));

    var dy = rect.top + kDefaultEventPadding;
    for (final painter in textPainters) {
      painter
        ..maxLines = 1
        ..ellipsis = ' '
        ..layout(maxWidth: rect.width /* - kDefaultEventPadding */)
        ..paint(canvas, Offset(rect.left + kDefaultEventPadding, dy));
      dy += painter.height + kDefaultEventPadding / 4;
    }

    canvas.restore();
  }

  bool _eventsOverlap(CalendarEvent a, CalendarEvent b) => a.start.isBefore(b.end) && b.start.isBefore(a.end);

  /// Paints the time line on the calendar.
  void _paintTimeLine(Canvas canvas, Offset offset) {
    final linePaint =
        Paint() // TODO(ziqq): Maybe should be a theme color?
          ..color = Colors.white12
          ..strokeWidth = 1;

    for (var i = 0; i <= _endHour; i++) {
      final y = offset.dy + kDefaultPadding + i * _hourHeight;
      // TODO(ziqq): Fix 00 if you want to show time split by 10-15-30 minutes
      final textSpan = TextSpan(text: '${i.appendLeadingZero()}:00', style: _secondaryTextStyle);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();

      tp.paint(canvas, Offset(offset.dx + tp.size.width / 3.5, y - tp.height / 2));
      canvas.drawLine(Offset(offset.dx + kDefaultTimeLineWidth, y), Offset(offset.dx + size.width, y), linePaint);
    }
  }
}

/// Виджет для отображения текущего времени в виде красной линии и текста.
/// {@macro calendar_day_view}
class _Calendar$CurrentTimeIndicatorWidget extends LeafRenderObjectWidget {
  /// {@macro calendar_day_view}
  const _Calendar$CurrentTimeIndicatorWidget({
    required this.hourHeight,
    required this.startHour,
    required this.textStyle,
    super.key, // ignore: unused_element_parameter
  });

  final double hourHeight;
  final double startHour;
  final TextStyle textStyle;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCurrentTimeIndicator(hourHeight: hourHeight, startHour: startHour, textStyle: textStyle);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCurrentTimeIndicator renderObject) {
    renderObject
      ..hourHeight = hourHeight
      ..startHour = startHour
      ..textStyle = textStyle;
  }
}

/// RenderBox для отображения текущего времени в виде красной линии и текста.
/// {@macro calendar_day_view}
class _RenderCurrentTimeIndicator extends RenderBox {
  /// {@macro calendar_day_view}
  _RenderCurrentTimeIndicator({required double hourHeight, required double startHour, required TextStyle textStyle})
    : _hourHeight = hourHeight,
      _startHour = startHour,
      _textStyle = textStyle {
    _ticker = Ticker(_startTicker)..start();
  }

  Ticker? _ticker;
  Timer? _timer;
  double _hourHeight;
  double _startHour;
  TextStyle _textStyle;

  // ignore: avoid_setters_without_getters
  set hourHeight(double value) {
    if (_hourHeight != value) {
      _hourHeight = value;
      markNeedsPaint();
    }
  }

  // ignore: avoid_setters_without_getters
  set startHour(double value) {
    if (_startHour != value) {
      _startHour = value;
      markNeedsPaint();
    }
  }

  // ignore: avoid_setters_without_getters
  set textStyle(TextStyle value) {
    if (_textStyle != value) {
      _textStyle = value;
      markNeedsPaint();
    }
  }

  /// Тикер для обновления текущего времени.
  void _tick(Timer? _) {
    if (!attached) return;
    if (debugDisposed ?? false) return;
    markNeedsPaint();
  }

  /// Запускает таймер, который будет обновлять текущее время каждую минуту.
  void _startTicker(Duration _) {
    // Отменяем, если уже есть
    _timer?.cancel();

    // Вычисляем время до начала следующей минуты
    final now = DateTime.now();
    final secondsToNextMinute = 60 - now.second;
    final millisecondsToNextMinute = 1000 * secondsToNextMinute - now.millisecond;

    // Сначала ждем до начала следующей минуты
    Future.delayed(Duration(milliseconds: millisecondsToNextMinute), () {
      _tick(null); // Первая отрисовка точно в начале минуты
      _timer = Timer.periodic(const Duration(minutes: 1), _tick);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker
      ?..stop()
      ..dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, 1);
  }

  @override
  void detach() {
    _ticker?.dispose();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final now = DateTime.now();
    final currentHour = now.hour + now.minute / 60.0 + now.second / 3600.0 - _startHour;
    final y = offset.dy + kDefaultPadding + currentHour * _hourHeight;

    // Красная линия
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1;

    canvas.drawLine(Offset(offset.dx + kDefaultTimeLineWidth - 10, y), Offset(offset.dx + size.width, y), linePaint);

    // Текст времени
    final textSpan = TextSpan(
      text: '${now.hour.appendLeadingZero()}:${now.minute.appendLeadingZero()}',
      style: _textStyle.copyWith(color: Colors.white, height: 1, fontWeight: FontWeight.w600),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

    // Current time width
    final left = offset.dx + tp.size.width / 4.5;
    final top = y - tp.height / 2;

    final width = tp.size.width * 1.4;
    final rect = Rect.fromLTRB(left, top - 2, width, top + tp.size.height + 2);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    canvas
      // Сохраняем состояние и обрезаем всё по rrect
      ..save()
      ..clipRRect(rrect)
      // Рисуем бордер внутри с обрезкой по скруглению
      ..drawRect(Rect.fromLTRB(rect.left, rect.top, width, rect.bottom), Paint()..color = Colors.red)
      // Возвращаем контекст
      ..restore();

    tp.paint(canvas, Offset(offset.dx + tp.size.width / 3.5, y - tp.height / 2));
  }
}

/// A widget that refreshes the calendar time line every minute.
/// {@macro calendar_day_view}
class _CalendarTimeLineRefresher extends StatefulWidget {
  /// {@macro calendar_day_view}
  const _CalendarTimeLineRefresher({
    required this.builder,
    super.key, // ignore: unused_element_parameter
  });

  final Widget Function(BuildContext context, CalendarTimeLineRefreshController notifier) builder;

  @override
  State<_CalendarTimeLineRefresher> createState() => _CalendarAutoRefreshState();
}

/// State for widget [_CalendarTimeLineRefresher].
class _CalendarAutoRefreshState extends State<_CalendarTimeLineRefresher> {
  late final ValueNotifier<DateTime> _notifier;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(DateTime.now());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _notifier.value = DateTime.now());
  }

  @override
  void dispose() {
    _notifier.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context, _notifier);
}
