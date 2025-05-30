// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playground/src/dragable_grid_gallery/dragable_grid_gallery.dart';

@pragma('vm:entry-point')
void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.background');

  channel.setMethodCallHandler((call) async {
    if (call.method == 'backgroundHandler') {
      debugPrint('🔥 Dart: backgroundHandler вызван');
      await _backgroundHandler();
    }
  });

  debugPrint('✅ Dart Background Main готов');
}

Future<void> _backgroundHandler() async {
  debugPrint('🔥 Бекграунд-хендлер отработал!');
}

void main() => runZonedGuarded<void>(
      () {
        WidgetsFlutterBinding.ensureInitialized();
        runApp(const App());
      },
      (error, stackTrace) => log('Top level exception: $error\n$stackTrace'),
    );

final List<IconData> icons = [
  Icons.abc,
  Icons.back_hand,
  Icons.cabin,
  Icons.dangerous,
  Icons.earbuds,
  Icons.face,
  Icons.gamepad,
  Icons.h_plus_mobiledata,
  Icons.image,
];

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final List<Widget> galleries = List.generate(
    4,
    (index) => IconButton(
      onPressed: () {},
      icon: Icon(icons[index]),
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Material App',
        theme: ThemeData.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: DragableGridGallery(galleries: galleries),
          ),
        ),
      );
}
