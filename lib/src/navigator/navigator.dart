import 'dart:collection';

import 'package:flutter/material.dart';

// --- Application navigator --- //

/// Simplified navigator that allows to change the pages declaratively.
/// You can add a custom controller with interceptors and other features.
/// You can pass controller down the widget tree to change the pages from anywhere with InheritedWidget.
class AppNavigator extends StatefulWidget {
  const AppNavigator({
    required this.home,
    this.controller,
    super.key,
  });

  /// Fallback page when the pages list is empty.
  final Page<Object?> home;

  /// Custom controller to change the pages declaratively.
  final ValueNotifier<List<Page<Object?>>>? controller;

  /// Change the pages declaratively.
  static void change(
    BuildContext context,
    List<Page<Object?>> Function(List<Page<Object?>>) fn,
  ) =>
      context.findAncestorStateOfType<_AppNavigatorState>()?.change(fn);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  late ValueNotifier<List<Page<Object?>>> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        ValueNotifier<List<Page<Object?>>>(<Page<Object?>>[widget.home]);
    if (_controller.value.isEmpty) {
      _controller.value = <Page<Object?>>[widget.home];
    }
    _controller.addListener(_onStateChanged);
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(_controller, widget.controller)) {
      _controller.removeListener(_onStateChanged);
      _controller = widget.controller ??
          ValueNotifier<List<Page<Object?>>>(<Page<Object?>>[widget.home]);
      if (_controller.value.isEmpty) {
        _controller.value = <Page<Object?>>[widget.home];
      }
      _controller.addListener(_onStateChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }

  /// Change the pages declaratively.
  void change(List<Page<Object?>> Function(List<Page<Object?>>) fn) {
    final pages = fn(_controller.value);
    if (identical(pages, _controller.value)) return; // No changes
    // Remove duplicates and null keys
    final keys = <LocalKey>{};
    final newPages = <Page<Object?>>[];
    for (var i = pages.length - 1; i >= 0; i--) {
      final page = pages[i];
      final key = page.key;
      if (keys.contains(page.key) || key == null) continue;
      keys.add(key);
      newPages.insert(0, page);
    }
    if (newPages.isEmpty) newPages.add(widget.home);
    _controller.value = UnmodifiableListView<Page<Object?>>(newPages);
  }

  @protected
  void _onStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @protected
  void _onDidRemovePage(Page<Object?> route) {
    if (!route.canPop) return;
    final pages = _controller.value;
    if (pages.length <= 1) return;
    // You can implement custom logic here
    _controller.value =
        UnmodifiableListView<Page<Object?>>(pages.sublist(0, pages.length - 1));
  }

  @override
  Widget build(BuildContext context) => Navigator(
        pages: _controller.value.toList(growable: false),
        onDidRemovePage: _onDidRemovePage,
      );
}
