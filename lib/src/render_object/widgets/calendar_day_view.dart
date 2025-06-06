import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_playground/src/extensions.dart';
import 'package:flutter_playground/src/render_object/models/event.dart';
import 'package:flutter_playground/src/render_object/models/resource.dart';
import 'package:flutter_playground/src/render_object/models/time_mode.dart';
import 'package:flutter_playground/src/render_object/typedefs.dart';
import 'package:flutter_playground/src/render_object/widgets/linked_scroll_controller.dart';

/// Default padding.
const double kDefaultPadding = 16;

/// Default width for the vertical separator in the calendar render widget.
const double kVerticalSeparatorWidth = 0.5;

/// Default height for the hour in the calendar render widget.
const double kDefaultHourHeight = 100;

/// Default width for the timeline in the calendar render widget.
const double kDefaultTimeLineWidth = 50;

/// Default [Event] width.
const double kDefaultEventWidth = 167.5;

/// Default padding for the events in the calendar render widget.
const double kDefaultEventPadding = 5;

/// Default border radius for the events in the calendar render widget.
const double kDefaultEventBorderRadius = 10;

/// {@template calendar_day_view}
/// Calendar$DayView widget.
/// {@endtemplate}
class Calendar$DayView extends StatefulWidget {
  /// {@macro calendar_day_view}
  const Calendar$DayView({
    required this.events,
    required this.width,
    this.resources,
    this.resourceBuilder,
    this.minDate,
    this.maxDate,
    this.startTime,
    this.startHour = 0,
    this.endHour = 24,
    this.bottomPadding = 0,
    this.resourcesHeight = 66,
    this.textStyle,
    this.secondaryTextStyle,
    this.hourHeight = kDefaultHourHeight,
    this.showCurrentTimeIndicator,
    this.onPageChange,
    this.timeMode = CalendarTimeMode.minutes15,
    super.key, // ignore: unused_element_parameter
  });

  /// Calendar events.
  final List<CalendarEvent> events;

  /// Calendar resources.
  final List<CalendarResource>? resources;

  /// The resource builder for the calendar.
  final ResourceBuilder? resourceBuilder;

  /// The start hour of the calendar.
  final int startHour;

  /// The end hour of the calendar.
  final int endHour;

  /// The width of the calendar.
  final double width;

  /// The height of each hour in the calendar.
  final double hourHeight;

  /// The bottom padding of the calendar.
  final double bottomPadding;

  /// The height of the calendar resources section.
  final double resourcesHeight;

  /// The minimum date for the calendar.
  final DateTime? minDate;

  /// The maximum date for the calendar.
  final DateTime? maxDate;

  /// The start time of the calendar.
  final TimeOfDay? startTime;

  /// The time mode for the calendar.
  final CalendarTimeMode timeMode;

  /// The text style for the secondary text in the calendar.
  final TextStyle? textStyle;

  /// The text style for the secondary text in the calendar.
  final TextStyle? secondaryTextStyle;

  /// Whether to show the current time indicator.
  final bool? showCurrentTimeIndicator;

  /// This callback will run whenever page will change.
  final CalendarPageChangeCallBack? onPageChange;

  static final DateTime _minDate = DateTime(1970).withoutTime.add(const Duration(days: 365));

  static final DateTime _maxDate = DateTime(275759).withoutTime.subtract(const Duration(days: 365));

  @override
  State<Calendar$DayView> createState() => _Calendar$DayViewState();
}

class _Calendar$DayViewState extends State<Calendar$DayView> {
  late DateTime _minDate;
  late DateTime _maxDate;

  late int _totalDays;
  late double _hourHeight;
  late double _columnWidth;

  late CalendarTimeMode _timeMode;

  late final ValueNotifier<int> _currentIndex;
  late final ValueNotifier<DateTime> _currentDate;

  late final PageController _pageController;

  late final LinkedScrollControllerGroup _scrollController;
  ScrollController? _resourcesHorizontalScroollController;
  ScrollController? _calendarHorizontalScrollController;

  TextStyle get _textStyle =>
      widget.textStyle ??
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
        fontSize: 11,
        height: 1.2,
      ) ??
      DefaultTextStyle.of(context).style.copyWith(fontSize: 11, height: 1.2);

  TextStyle get _secondaryTextStyle =>
      widget.secondaryTextStyle ??
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
        fontSize: 10,
        height: 1.2,
      ) ??
      DefaultTextStyle.of(context).style.copyWith(fontSize: 10, height: 1.2);

  @override
  void initState() {
    super.initState();
    _columnWidth = widget.width - kDefaultTimeLineWidth;
    _timeMode = widget.timeMode;

    _scrollController = LinkedScrollControllerGroup();
    _calendarHorizontalScrollController = _scrollController.addAndGet();
    _resourcesHorizontalScroollController = _scrollController.addAndGet();

    _minDate = widget.minDate ?? Calendar$DayView._minDate;
    _maxDate = widget.maxDate ?? Calendar$DayView._maxDate;
    _totalDays = _maxDate.getDayDifference(_minDate) + 1;

    _currentDate = ValueNotifier<DateTime>(DateTime.now().withoutTime);
    _currentIndex = ValueNotifier<int>(_currentDate.value.getDayDifference(_minDate));
    _pageController = PageController(initialPage: _currentIndex.value);

    _calculateHourHeight();
    _calculateWidth();
  }

  @override
  void didUpdateWidget(covariant Calendar$DayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeMode != oldWidget.timeMode) {
      _timeMode = widget.timeMode;
      _calculateHourHeight();
      _calculateWidth();
    }
    if (!identical(widget.resources, oldWidget.resources)) {
      _calculateWidth();
    }
  }

  @override
  void dispose() {
    _resourcesHorizontalScroollController?.dispose();
    _calendarHorizontalScrollController?.dispose();
    _pageController.dispose();
    _currentIndex.dispose();
    _currentDate.dispose();
    super.dispose();
  }

  void _calculateHourHeight() {
    if (!mounted) return;
    _hourHeight = switch (widget.timeMode) {
      CalendarTimeMode.minutes5 => widget.hourHeight * 3,
      CalendarTimeMode.minutes10 => widget.hourHeight * 1.5,
      CalendarTimeMode.minutes15 => widget.hourHeight,
      CalendarTimeMode.minutes30 => widget.hourHeight / 2,
    };
  }

  void _calculateWidth() {
    if (!mounted) return;
    if (widget.resources == null) return;
    if (widget.resources?.isEmpty ?? true) return;

    final length = widget.resources?.length ?? 1;
    final separatorWidth = length == 1 ? kVerticalSeparatorWidth * 2 : kVerticalSeparatorWidth * length;
    _columnWidth = math.max<double>(
      (widget.width - kDefaultTimeLineWidth - separatorWidth) / length,
      kDefaultEventWidth,
    );

    setState(() {});
  }

  /// Called when user change page using any gesture or inbuilt functions.
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

  /// Default resource builder for the calendar.
  Widget _defaultResourceBuilder(BuildContext context, int index) {
    final resource = widget.resources?[index];
    if (resource == null) return const SizedBox.shrink();
    return SizedBox(
      width: _columnWidth,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            SizedBox.square(
              dimension: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    resource.name[0],
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: CupertinoColors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Text(resource.name, style: _textStyle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = (widget.endHour - widget.startHour) * _hourHeight + kDefaultPadding * 2 + widget.bottomPadding;
    Widget addResources({required Widget child}) => widget.resources != null
        ? Column(
            children: [
              // --- Resources --- //
              // TODO(ziqq): Add resources support
              SizedBox(
                height: widget.resourcesHeight,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: kDefaultTimeLineWidth),
                  controller: _resourcesHorizontalScroollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.resources?.length ?? 0,
                  itemBuilder: widget.resourceBuilder != null
                      ? (context, index) => widget.resourceBuilder?.call(context, widget.resources![index], index)
                      : _defaultResourceBuilder,
                ),
              ),

              // --- Calendar --- //
              Expanded(child: child),
            ],
          )
        : child;

    return SizedBox(
      // Calculate the calendar height based on the number of hours and the hour height
      height: height,
      child: PageView.builder(
        itemCount: _totalDays,
        controller: _pageController,
        onPageChanged: _onPageChange,
        itemBuilder: (context, index) {
          final date = DateTime(_minDate.year, _minDate.month, _minDate.day + index);
          final keyValue = _hourHeight.toString() + date.toString();
          final isToday = date.sameDay();
          return addResources(
            child: SingleChildScrollView(
              key: ValueKey(keyValue),
              child: SizedBox(
                height: height,
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is OverscrollNotification) {
                          // Передаём жест PageView если дошли до края
                          Scrollable.ensureVisible(context);
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _calendarHorizontalScrollController,
                        // physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: height,
                          child: RepaintBoundary(
                            key: ValueKey('calendar_day_view_day_$keyValue'),
                            child: _CalendarRenderWidget(
                              columnWidth: _columnWidth * (widget.resources?.length ?? 1) + kDefaultTimeLineWidth,
                              hourHeight: _hourHeight,
                              secondaryTextStyle: _secondaryTextStyle,
                              textStyle: _textStyle,
                              bottomPadding: widget.bottomPadding,
                              resources: widget.resources,
                              startHour: widget.startHour,
                              timeMode: widget.timeMode,
                              endHour: widget.endHour,
                              events: widget.events,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- Current Time Line --- //
                    RepaintBoundary(
                      key: ValueKey('calendar_day_view_current_time_line_$keyValue'),
                      child: _CurrentTimeLineWidget(
                        settings: CurrentTimeLineSettings(
                          secondaryTextStyle: _secondaryTextStyle,
                          textStyle: _textStyle,
                          hourHeight: _hourHeight,
                          endHour: widget.endHour,
                          startHour: widget.startHour,
                          bottomPadding: widget.bottomPadding,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),

                    // --- Current Time Indicator --- //
                    if ((widget.showCurrentTimeIndicator ?? false) || isToday) ...[
                      RepaintBoundary(
                        key: ValueKey('calendar_day_view_current_time_indicator_$keyValue'),
                        child: _CurrentTimeIndicatorWidget(
                          settings: CurrentTimeIndicatorSettings(
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            startHour: widget.startHour,
                            hourHeight: _hourHeight,
                            textStyle: _textStyle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalendarDayViewSettings {
  CalendarDayViewSettings({
    required this.resources,
    required this.events,
    required this.timeMode,
    required this.bottomPadding,
    required this.hourHeight,
    required this.columnWidth,
    required this.textStyle,
    required this.secondaryTextStyle,
    this.startHour = 0,
    this.endHour = 24,
  });

  final List<CalendarResource>? resources;
  final List<CalendarEvent> events;
  final double? bottomPadding;
  final double hourHeight;
  final double columnWidth;
  final int startHour;
  final int endHour;
  final CalendarTimeMode timeMode;
  final TextStyle textStyle;
  final TextStyle secondaryTextStyle;
}

/// Виджет с кастомным RenderBox
class _CalendarRenderWidget extends LeafRenderObjectWidget {
  const _CalendarRenderWidget({
    required this.secondaryTextStyle,
    required this.textStyle,
    required this.columnWidth,
    required this.hourHeight,
    required this.timeMode,
    required this.resources,
    required this.events,
    this.bottomPadding,
    this.startHour,
    this.endHour,
    super.key, // ignore: unused_element_parameter
  });

  final List<CalendarResource>? resources;
  final List<CalendarEvent> events;
  final double columnWidth;
  final double hourHeight;
  final double? bottomPadding;
  final int? startHour;
  final int? endHour;
  final TextStyle textStyle;
  final TextStyle secondaryTextStyle;
  final CalendarTimeMode timeMode;

  @override
  RenderObject createRenderObject(BuildContext context) => _CalendarRenderView(
    secondaryTextStyle: secondaryTextStyle,
    textStyle: textStyle,
    bottomPadding: bottomPadding,
    columnWidth: columnWidth,
    hourHeight: hourHeight,
    startHour: startHour,
    timeMode: timeMode,
    endHour: endHour,
    resources: resources,
    events: events,
  );

  @override
  void updateRenderObject(BuildContext context, covariant _CalendarRenderView renderObject) {
    renderObject
      ..secondaryTextStyle = secondaryTextStyle
      ..textStyle = textStyle
      ..resources = resources
      ..events = events
      ..bottomPadding = bottomPadding
      ..columnWidth = columnWidth
      ..hourHeight = hourHeight
      ..startHour = startHour
      ..timeMode = timeMode
      ..endHour = endHour;
  }
}

class _CalendarRenderView extends RenderBox {
  _CalendarRenderView({
    required List<CalendarResource>? resources,
    required List<CalendarEvent> events,
    required CalendarTimeMode timeMode,
    required double? bottomPadding,
    required double hourHeight,
    required double columnWidth,
    required TextStyle textStyle,
    required TextStyle secondaryTextStyle,
    int? startHour,
    int? endHour,
  }) : _startHour = startHour ?? 0,
       _endHour = endHour ?? 24,
       _resources = resources,
       _events = events,
       _columnWidth = columnWidth,
       _timeMode = timeMode,
       _hourHeight = hourHeight,
       _bottomPadding = bottomPadding,
       _textStyle = textStyle,
       _secondaryTextStyle = secondaryTextStyle;

  List<CalendarResource>? _resources;
  List<CalendarEvent> _events;
  double? _bottomPadding;
  double _hourHeight;
  double _columnWidth;
  int _startHour;
  int _endHour;
  CalendarTimeMode _timeMode;
  TextStyle _textStyle;
  TextStyle _secondaryTextStyle;

  // ignore: avoid_setters_without_getters
  set resources(List<CalendarResource>? value) {
    if (!listEquals(_resources, value)) {
      _resources = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set events(List<CalendarEvent> value) {
    if (!listEquals(_events, value)) {
      _events = value;
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
  set textStyle(TextStyle value) {
    if (_textStyle != value) {
      _textStyle = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set timeMode(CalendarTimeMode value) {
    if (_timeMode != value) {
      _timeMode = value;
      markNeedsLayout();
    }
  }

  // ignore: avoid_setters_without_getters
  set bottomPadding(double? value) {
    if (_bottomPadding != value) {
      _bottomPadding = value;
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
  set columnWidth(double value) {
    if (_columnWidth != value) {
      _columnWidth = value;
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
    size = Size(_columnWidth, contentHeight + kDefaultPadding * 2 + (_bottomPadding ?? 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    _paintTimeLines(canvas, offset);

    final resourceEventMap = <int, List<CalendarEvent>>{};

    for (final resource in _resources ?? <CalendarResource>[]) {
      resourceEventMap[resource.id] = [];
    }

    for (final event in _events) {
      if (resourceEventMap.containsKey(event.resourceID)) {
        resourceEventMap[event.resourceID]?.add(event);
      }
    }

    final hasResources = _resources != null && _resources!.isNotEmpty;
    final columnCount = hasResources ? _resources!.length : 1;
    final columnWidth = (size.width - kDefaultTimeLineWidth) / columnCount;

    for (var i = 0; i < columnCount; i++) {
      final resource = hasResources ? _resources![i] : null;
      final events = hasResources ? (resourceEventMap[resource?.id] ?? <CalendarEvent>[]) : _events;

      final dx = offset.dx + kDefaultTimeLineWidth + i * columnWidth;
      final columnOffset = Offset(dx, offset.dy);

      final sortedEvents = [...events]..sort((a, b) => a.start.compareTo(b.start));
      final overlappingGroups = _groupOverlappingEvents(sortedEvents);

      for (final group in overlappingGroups) {
        for (var j = 0; j < group.length; j++) {
          final event = group[j];
          _paintEvent(canvas, event, columnOffset, group.length, j, columnWidth);
        }
      }
    }

    /// Paint the vertical separators between columns.
    final separatorPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = kVerticalSeparatorWidth;

    for (var i = 0; i < columnCount + 1; i++) {
      final dx = offset.dx + kDefaultTimeLineWidth + i * columnWidth;
      canvas.drawLine(Offset(dx, offset.dy + kDefaultPadding), Offset(dx, offset.dy + size.height), separatorPaint);
    }

    /* final sortedEvents = [..._events]..sort((a, b) => a.start.compareTo(b.start));
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
    } */
  }

  /// Paints a single event on the calendar.
  void _paintEvent(
    Canvas canvas,
    CalendarEvent event,
    Offset offset,
    int groupSize,
    int groupIndex,
    double columnWidth,
  ) {
    final start = event.start.hour + event.start.minute / 60.0 - _startHour;
    final end = event.end.hour + event.end.minute / 60.0 - _startHour;

    final top = offset.dy + kDefaultPadding + start * _hourHeight;
    final bottom = offset.dy + kDefaultPadding + end * _hourHeight;

    // final totalAvailableWidth = size.width - kDefaultTimeLineWidth - kDefaultEventPadding / 2;
    // final singleEventWidth = totalAvailableWidth / groupSize;
    // final left = offset.dx + kDefaultTimeLineWidth + groupIndex * singleEventWidth + kDefaultEventPadding / 2;
    final singleEventWidth = columnWidth / groupSize;
    final left = offset.dx + groupIndex * singleEventWidth + kDefaultEventPadding / 2;

    final rect = Rect.fromLTRB(left, top, left + singleEventWidth - 5, bottom);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(kDefaultEventBorderRadius));

    // TODO(ziqq): Add text style with 10 font size and height 1.2.
    final timeTextSpan = TextSpan(
      text:
          '${event.start.hour.appendLeadingZero()}:${event.start.minute.appendLeadingZero()} - ${event.end.hour.appendLeadingZero()}:${event.end.minute.appendLeadingZero()}',
      style: _secondaryTextStyle,
    );

    final commentTextSpan = TextSpan(text: event.comment, style: _secondaryTextStyle);

    final eventTextSpan = TextSpan(text: event.title, style: _textStyle);

    final subtitleTextSpan = TextSpan(text: event.subtitle, style: _secondaryTextStyle);

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

  /// Paints the time line on the calendar.
  void _paintTimeLines(Canvas canvas, Offset offset) {
    final linePaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    final minutesStep = _timeMode.minutes;
    final totalMinutes = (_endHour - _startHour) * 60;

    for (var minute = 0; minute <= totalMinutes; minute += minutesStep) {
      final y = offset.dy + kDefaultPadding + (minute / 60.0) * _hourHeight;
      // final isFullHour = minute % 60 == 0;

      /* if (isFullHour) {
        final hour = _startHour + (minute ~/ 60);
        final textSpan = TextSpan(text: '${hour.appendLeadingZero()}:00', style: _secondaryTextStyle);
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();

        tp.paint(canvas, Offset(offset.dx + tp.size.width / 3.5, y - tp.height / 2));
      } */

      canvas.drawLine(Offset(offset.dx + kDefaultTimeLineWidth, y), Offset(offset.dx + size.width, y), linePaint);
    }
  }

  List<List<CalendarEvent>> _groupOverlappingEvents(List<CalendarEvent> sortedEvents) {
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
    return overlappingGroups;
  }

  bool _eventsOverlap(CalendarEvent a, CalendarEvent b) => a.start.isBefore(b.end) && b.start.isBefore(a.end);
}

/// Settings for the current time line in the calendar.
class CurrentTimeLineSettings {
  const CurrentTimeLineSettings({
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.textStyle,
    required this.secondaryTextStyle,
    this.bottomPadding,
    this.backgroundColor,
  });

  final int startHour;
  final int endHour;
  final double? bottomPadding;
  final double hourHeight;
  final Color? backgroundColor;
  final TextStyle textStyle;
  final TextStyle secondaryTextStyle;
}

/// A widget that displays the current time line in the calendar.
/// {@macro calendar_day_view}
class _CurrentTimeLineWidget extends LeafRenderObjectWidget {
  /// {@macro calendar_day_view}
  const _CurrentTimeLineWidget({
    required this.settings,
    super.key, // ignore: unused_element_parameter
  });

  final CurrentTimeLineSettings settings;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCurrentTimeLine(settings: settings);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCurrentTimeLine renderObject) {
    renderObject.settings = settings;
  }
}

class _RenderCurrentTimeLine extends RenderBox {
  _RenderCurrentTimeLine({required CurrentTimeLineSettings settings}) : _settings = settings;

  CurrentTimeLineSettings _settings;

  // ignore: avoid_setters_without_getters
  set settings(CurrentTimeLineSettings value) {
    if (_settings != value) {
      _settings = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    // Calculate the calendar height based on the number of hours and the hour height
    final contentHeight = (_settings.endHour - _settings.startHour) * _settings.hourHeight;
    // Calculate the calendar height based on the number of hours and the hour height
    size = Size(kDefaultTimeLineWidth, contentHeight + kDefaultPadding * 2 + (_settings.bottomPadding ?? 0));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final linePaint =
        Paint() // TODO(ziqq): Maybe should be a theme color?
          ..color = Colors.white12
          ..strokeWidth = 1;

    // Draw vertical line background for the current time indicator
    final verticalLineBgPaint = Paint()
      ..color = _settings.backgroundColor ?? Colors.transparent
      ..strokeWidth = kDefaultTimeLineWidth;

    canvas.drawLine(
      Offset(offset.dx + kDefaultTimeLineWidth / 2, offset.dy),
      Offset(offset.dx + kDefaultTimeLineWidth / 2, offset.dy + constraints.maxHeight),
      verticalLineBgPaint,
    );

    for (var i = 0; i <= _settings.endHour; i++) {
      final y = offset.dy + kDefaultPadding + i * _settings.hourHeight;
      // TODO(ziqq): Fix 00 if you want to show time split by 10-15-30 minutes
      final textSpan = TextSpan(
        text: '${i.appendLeadingZero()}:00',
        style: _settings.textStyle.copyWith(color: _settings.secondaryTextStyle.color),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();

      tp.paint(canvas, Offset(offset.dx + tp.size.width / 2.7, y - tp.height / 2));
      canvas.drawLine(Offset(offset.dx + kDefaultTimeLineWidth, y), Offset(offset.dx + size.width, y), linePaint);
    }
  }
}

/// Settings for the current time indicator in the calendar.
class CurrentTimeIndicatorSettings {
  const CurrentTimeIndicatorSettings({
    required this.hourHeight,
    required this.startHour,
    required this.textStyle,
    required this.backgroundColor,
  });

  final int startHour;
  final double hourHeight;
  final TextStyle textStyle;
  final Color backgroundColor;
}

/// Виджет для отображения текущего времени в виде красной линии и текста.
/// {@macro calendar_day_view}
class _CurrentTimeIndicatorWidget extends LeafRenderObjectWidget {
  /// {@macro calendar_day_view}
  const _CurrentTimeIndicatorWidget({
    required this.settings,
    super.key, // ignore: unused_element_parameter
  });

  final CurrentTimeIndicatorSettings settings;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCurrentTimeIndicator(settings: settings);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderCurrentTimeIndicator renderObject) {
    renderObject.settings = settings;
  }
}

/// RenderBox для отображения текущего времени в виде красной линии и текста.
/// {@macro calendar_day_view}
class _RenderCurrentTimeIndicator extends RenderBox {
  /// {@macro calendar_day_view}
  _RenderCurrentTimeIndicator({required CurrentTimeIndicatorSettings settings}) : _settings = settings {
    _ticker = Ticker(_startTicker)..start();
  }

  CurrentTimeIndicatorSettings _settings;
  Ticker? _ticker;
  Timer? _timer;

  // ignore: avoid_setters_without_getters
  set settings(CurrentTimeIndicatorSettings value) {
    if (_settings != value) {
      _settings = value;
      markNeedsPaint();
    }
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

  /// Тикер для обновления текущего времени.
  void _tick(Timer? _) {
    if (!attached) return;
    if (debugDisposed ?? false) return;
    markNeedsPaint();
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
    final currentHour = now.hour + now.minute / 60.0 + now.second / 3600.0 - _settings.startHour;
    final y = offset.dy + kDefaultPadding + currentHour * _settings.hourHeight;

    // Красная линия
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1;

    canvas.drawLine(Offset(offset.dx + kDefaultTimeLineWidth - 10, y), Offset(offset.dx + size.width, y), linePaint);

    // Текст времени
    final textSpan = TextSpan(
      text: '${now.hour.appendLeadingZero()}:${now.minute.appendLeadingZero()}',
      style: _settings.textStyle.copyWith(color: Colors.white, height: 1, fontWeight: FontWeight.w600),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();

    // Current time width
    final left = offset.dx + tp.size.width / 4.5;
    final top = y - tp.height / 2;

    final width = tp.size.width + 11;
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
