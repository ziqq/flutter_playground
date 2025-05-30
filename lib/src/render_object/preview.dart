import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_playground/src/extensions.dart';
import 'package:flutter_playground/src/render_object/calendar_day_view.dart';
import 'package:flutter_playground/src/render_object/event.dart';

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

class _Home extends StatelessWidget {
  const _Home({
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      forceMaterialTransparency: true,
      title: Text(
        'RENDER OBJECT PREVIEW',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Calendar$DayView(
          bottomPadding: context.hasBottomNotch ? context.bottomNotch : kDefaultPadding,
          hourHeight: kDefaultHourHeight,
          width: constraints.maxWidth,
          events: CalendarEvent.mocks,
        ),
      ),
    ),
  );
}
