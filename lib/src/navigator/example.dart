import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_playground/src/navigator/navigator.dart';

void main() => runZonedGuarded<void>(
      () => runApp(App(controller: ValueNotifier<List<Page<Object?>>>([]))),
      (error, stackTrace) => dev.log('Top level error: $error\n$stackTrace'),
    );

class App extends StatelessWidget {
  const App({required this.controller, super.key});

  final ValueNotifier<List<Page<Object?>>> controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Declarative Navigator Example',
        debugShowCheckedModeBanner: true,
        theme: ThemeData.dark(),
        builder: (context, _) => AppNavigator(
          home: AppPages.home.page,
          controller: controller,
        ),
      );
}

// Pages and screens, just for the example
enum AppPages {
  home('Home'),
  settings('Settings'),
  history('History'),
  wallet('Wallet'),
  chat('Chat'),
  account('Account');

  const AppPages(this.title);

  final String title;

  Page<Object?> get page => MaterialPage<Object?>(
        key: ValueKey<AppPages>(this),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: <Widget>[
                // Show modal dialog
                IconButton(
                  icon: const Icon(Icons.warning),
                  tooltip: 'Show modal dialog',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Warning'),
                      content: const Text('This is a warning message.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Go to settings page
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Drop routes and go to settings',
                  onPressed: () => AppNavigator.change(
                    context,
                    (pages) => [
                      AppPages.home.page,
                      AppPages.settings.page,
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                shrinkWrap: true,
                // Show list of new routes
                children: AppPages.values
                    .where((e) => e != this)
                    .map<Widget>(
                      (e) => ListTile(
                        title: Text(e.title),
                        onTap: () => AppNavigator.change(
                          context,
                          (pages) => [...pages, e.page],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      );
}
