import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playground/src/extensions.dart';
import 'package:flutter_playground/src/render_object/models/event.dart';
import 'package:flutter_playground/src/render_object/models/resource.dart';
import 'package:flutter_playground/src/render_object/models/time_mode.dart';
import 'package:flutter_playground/src/render_object/models/view_mode.dart';
import 'package:flutter_playground/src/render_object/widgets/calendar_day_view.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// The entry point of the render object preview.
void main() => runZonedGuarded<void>(
  () => runApp(const App()),
  (error, stackTrace) => dev.log('Top level exception: $error\n$stackTrace'),
);

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Render Object Preview',
    themeMode: ThemeMode.dark,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: const _Home(),
  );
}

class _Home extends StatefulWidget {
  const _Home({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  late CalendarTimeMode _timeMode;
  late CalendarViewMode _viewMode;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _viewMode = CalendarViewMode.day;
    _timeMode = CalendarTimeMode.minutes15;
  }

  void _onTodayPressed() {
    if (!mounted) return;
    HapticFeedback.heavyImpact().ignore();
    _currentDate = DateTime.now();
    setState(() {});
  }

  void _onPageChange(DateTime date, int page) {
    if (!mounted) return;
    dev.log('Page changed to $date, page: $page');
    HapticFeedback.heavyImpact().ignore();
    _currentDate = date;
    setState(() {});
  }

  void _onTimeModeChange(CalendarTimeMode mode) {
    if (!mounted) return;
    dev.log('Time mode changed to $mode');
    HapticFeedback.heavyImpact().ignore();
    _timeMode = mode;
    setState(() {});
  }

  void _onViewModeChange(CalendarViewMode mode) {
    if (!mounted) return;
    dev.log('View mode changed to $mode');
    HapticFeedback.heavyImpact().ignore();
    _viewMode = mode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final emptyTitleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    final timeModeList = <CalendarTimeModeSelectData>[
      CalendarTimeModeSelectData(text: CalendarTimeMode.minutes5.name, value: CalendarTimeMode.minutes5),
      CalendarTimeModeSelectData(text: CalendarTimeMode.minutes10.name, value: CalendarTimeMode.minutes10),
      CalendarTimeModeSelectData(text: CalendarTimeMode.minutes15.name, value: CalendarTimeMode.minutes15),
      CalendarTimeModeSelectData(text: CalendarTimeMode.minutes30.name, value: CalendarTimeMode.minutes30),
    ];
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Calendar'.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('d MMM, yyyy').format(_currentDate.withoutTime),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
                height: 1,
              ),
            ),
          ],
        ),
        leadingWidth: 106,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            PullDownButton(
              buttonBuilder: (context, showMenu) => SizedBox(
                height: 28,
                child: CupertinoButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact().ignore();
                    showMenu.call();
                  },
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context),
                  child: Text(
                    _viewMode.map<String>(
                      day: () => 'Day',
                      week: () => 'Week',
                      month: () => 'Month',
                      list: () => 'List',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context) => CalendarViewMode.values
                  .map(
                    (e) => PullDownMenuItem.selectable(
                      title: e.alias,
                      selected: _viewMode == e,
                      onTap: () => _onViewModeChange(e),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(width: 8),
            PullDownButton(
              itemBuilder: (context) => timeModeList
                  .map<PullDownMenuItem>(
                    (t) => PullDownMenuItem.selectable(
                      selected: _timeMode == t.value,
                      title: t.text,
                      onTap: () => _onTimeModeChange(t.value),
                    ),
                  )
                  .toList(growable: false),
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: () {
                  HapticFeedback.heavyImpact().ignore();
                  showMenu.call();
                },
                minimumSize: const Size(28, 28),
                padding: const EdgeInsets.all(4),
                borderRadius: BorderRadius.circular(8),
                color: CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context),
                child: Icon(
                  CupertinoIcons.calendar,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            height: 28,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: _onTodayPressed,
              color: CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context),
              child: Text(
                'Today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => _viewMode.map<Widget>(
          day: () => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Calendar$DayView(
              bottomPadding: context.hasBottomNotch ? context.bottomNotch : kDefaultPadding,
              resources: CalendarResource.$mocks,
              events: CalendarEvent.$mocks,
              width: constraints.maxWidth,
              onPageChange: _onPageChange,
              timeMode: _timeMode,
            ),
          ),
          week: () => Center(child: Text('Week view is not implemented yet', style: emptyTitleStyle)),
          month: () => Center(child: Text('Month view is not implemented yet', style: emptyTitleStyle)),
          list: () => Center(child: Text('List view is not implemented yet', style: emptyTitleStyle)),
        ),
      ),
    );
  }
}
