import 'dart:async';

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

/// {@template calendar_day_view}
/// Calendar$DayView widget.
/// {@endtemplate}
class Calendar$DayView extends StatelessWidget {
  /// {@macro calendar_day_view}
  const Calendar$DayView({
    required this.events,
    required this.width,
    this.startHour = 0,
    this.endHour = 24,
    this.bottomPadding,
    this.hourHeight = kDefaultHourHeight,
    this.secondaryTextStyle,
    this.showCurrentTimeIndicator = true,
    super.key, // ignore: unused_element_parameter
  });

  final List<CalendarEvent> events;
  final int startHour;
  final int endHour;
  final double width;
  final double hourHeight;
  final double? bottomPadding;
  final TextStyle? secondaryTextStyle;
  final bool showCurrentTimeIndicator;

  @override
  Widget build(BuildContext context) {
    final $secondaryTextStyle =
        secondaryTextStyle ??
        Theme.of(context).textTheme.bodySmall ??
        DefaultTextStyle.of(context).style.copyWith(fontSize: 12);
    return SizedBox(
      // Calculate the calendar height based on the number of hours and the hour height
      height: (endHour - startHour) * hourHeight + kDefaultPadding * 2 + (bottomPadding ?? 0),
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, i) => Stack(
          children: [
            _CalendarRenderWidget(
              secondaryTextStyle: $secondaryTextStyle,
              bottomPadding: bottomPadding,
              hourHeight: hourHeight,
              startHour: startHour,
              endHour: endHour,
              width: width,
              events: CalendarEvent.mocks,
            ),
            if (showCurrentTimeIndicator) ...[
              RepaintBoundary(
                key: const Key('calendar_day_view_current_time_indicator'),
                child: _Calendar$CurrentTimeIndicatorWidget(
                  hourHeight: 80,
                  startHour: 0,
                  textStyle: $secondaryTextStyle,
                ),
              ),
            ],
          ],
        ),
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
    for (final event in _events) _paintEvent(canvas, event, offset);
  }

  /// Paints a single event on the calendar.
  void _paintEvent(Canvas canvas, CalendarEvent event, Offset offset) {
    final start = event.start.hour + event.start.minute / 60.0 - _startHour;
    final end = event.end.hour + event.end.minute / 60.0 - _startHour;

    final top = offset.dy + kDefaultPadding + start * _hourHeight;
    final bottom = offset.dy + kDefaultPadding + end * _hourHeight;

    // Простейшее смещение для наглядности
    final left = offset.dx + (_events.indexOf(event)) + kDefaultTimeLineWidth + 10;

    // Event width
    final width = size.width - left - 10;
    final rect = Rect.fromLTRB(left, top, left + width, bottom);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(kDefaultEventBorderRadius));

    canvas
      // Сохраняем состояние и обрезаем всё по rrect
      ..save()
      ..clipRRect(rrect)
      // Рисуем бордер внутри с обрезкой по скруглению
      ..drawRect(Rect.fromLTRB(rect.left, rect.top, rect.left + 3, rect.bottom), Paint()..color = event.color)
      // Рисуем сам фон поверх
      ..drawRRect(rrect, Paint()..color = event.color.withAlpha(40))
      // Возвращаем контекст
      ..restore();

    final textSpan = TextSpan(
      text: event.title,
      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
    );

    TextPainter(text: textSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: rect.width - 8)
      ..paint(canvas, Offset(rect.left + kDefaultEventPadding, rect.top + kDefaultEventPadding));
  }

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
  void _tick(Timer? _) => markNeedsPaint();

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
    _ticker?.dispose();
    _timer?.cancel();
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

class _RenderEventBox extends RenderBox {
  _RenderEventBox({
    required CalendarEvent event,
    required double width,
    required double height,
    required TextStyle secondaryTextStyle,
  }) : _event = event,
       _width = width,
       _height = height,
       _secondaryTextStyle = secondaryTextStyle;

  double _width;
  double _height;
  TextStyle _secondaryTextStyle;
  CalendarEvent _event;

  @override
  void performLayout() {
    size = Size(_width, _height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background with gradient
    final gradient = LinearGradient(
      colors: [_event.color, _event.color.withValues(alpha: 0.2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.01, 0.01],
    );

    final backgroundPaint = Paint()..shader = gradient.createShader(rect);

    const radius = Radius.circular(kDefaultEventBorderRadius);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: radius,
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );

    canvas.drawRRect(rrect, backgroundPaint);

    // Left color line
    final linePaint = Paint()..color = _event.color;
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 3, rect.height), linePaint);

    // Text
    final textSpan = TextSpan(text: '${_event.start} - ${_event.end}\n${_event.title}', style: _secondaryTextStyle);

    TextPainter(text: textSpan, textDirection: TextDirection.ltr, maxLines: 4)
      ..layout(maxWidth: size.width - 10)
      ..paint(canvas, offset + const Offset(6, 4));
  }
}

class _EventBox extends LeafRenderObjectWidget {
  const _EventBox({
    required this.event,
    required this.width,
    required this.height,
    super.key, // ignore: unused_element_parameter
  });

  final CalendarEvent event;
  final double width;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEventBox(
    event: event,
    width: width,
    height: height,
    secondaryTextStyle: Theme.of(context).textTheme.bodySmall ?? DefaultTextStyle.of(context).style,
  );

  @override
  void updateRenderObject(BuildContext context, covariant _RenderEventBox renderObject) {
    renderObject
      .._event = event
      .._width = width
      .._height = height
      .._secondaryTextStyle = Theme.of(context).textTheme.bodySmall ?? DefaultTextStyle.of(context).style;
  }
}

class _CalendarTimeLineRefresher extends StatefulWidget {
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

/// A notifier that refreshes the calendar time line every minute.
typedef CalendarTimeLineRefreshController = ValueListenable<DateTime>;
