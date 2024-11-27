import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playground/src/dragable_grid_gallery/dragable_grid_gallery.dart';

/// {@template gallery_item}
/// A widget that represents an item in the gallery.
/// {@endtemplate}
class GalleryItemWidget extends StatefulWidget {
  /// {@macro gallery_item}
  const GalleryItemWidget({
    required this.index,
    required this.child,
    this.curve = Curves.easeIn,
    super.key,
  });

  /// The index of the item in the gallery.
  final int index;

  /// The curve of the animation.
  final Curve curve;

  /// The child widget.
  final Widget child;

  @override
  State<GalleryItemWidget> createState() => GalleryItemWidgetState();
}

/// State for widget [GalleryItemWidget].
class GalleryItemWidgetState extends State<GalleryItemWidget> with GalleryItemDragDelegate {
  AnimationController? _controller;

  ValueKey<int> get key => ValueKey<int>(widget.index);

  bool get isTransitionCompleted => _controller == null || _controller!.status == AnimationStatus.completed;

  @override
  int get index => widget.index;

  @override
  Curve get curve => widget.curve;

  @override
  AnimationController? get animation => _controller;

  @override
  set animation(AnimationController? value) => _controller = value;

  @override
  void initState() {
    super.initState();
    gridState = DragableGridGallery.of(context)..register(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox;
      size = box.size;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GalleryItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print('update: from ${oldWidget.index} to ${widget.index}');

    if (oldWidget.index != widget.index) {
      gridState
        ..unregister(oldWidget.index, this)
        ..register(this);
    }
  }

  @override
  void deactivate() {
    gridState.unregister(index, this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox;
      size = box.size;
    });
    gridState.register(this); */

    if (isDragging) return const SizedBox();
    return GalleryItemDragStartListener(
      index: index,
      child: Transform.translate(
        offset: offset,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border.all()),
          child: Align(child: widget.child),
        ),
      ),
    );
  }
}

/// A listener that listens for drag start events.
///
/// {@macro gallery_item}
class GalleryItemDragStartListener extends StatelessWidget {
  /// {@macro gallery_item}
  const GalleryItemDragStartListener({
    required this.index,
    required this.child,
    this.enabled = true,
    super.key,
  });

  /// Whether the drag is enabled.
  final bool enabled;

  /// The index of the item in the gallery.
  final int index;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: enabled ? (event) => _startDragging(context, event) : null,
        child: child,
      );

  MultiDragGestureRecognizer createRecognizer() => ImmediateMultiDragGestureRecognizer(debugOwner: this);

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final gestureSetting = MediaQuery.maybeOf(context)?.gestureSettings;
    final grid = DragableGridGallery.maybeOf(context);
    grid?.startDragging(
      index: index,
      event: event,
      recognizer: createRecognizer()..gestureSettings = gestureSetting,
    );
  }
}

/// A mixin that provides drag delegate for gallery items.
mixin GalleryItemDragDelegate<T extends StatefulWidget> on State<T> {
  late DragableGridGalleryState gridState;

  bool isDragging = false;

  Size? size;
  Offset startOffset = Offset.zero;
  Offset targetOffset = Offset.zero;

  int get index;
  Curve get curve;

  AnimationController? get animation;
  set animation(AnimationController? value);

  bool get isTransitionEnd => animation == null;

  Offset get offset {
    if (animation != null) {
      final t = curve.transform(animation!.value);
      return Offset.lerp(startOffset, targetOffset, t)!;
    }
    return targetOffset;
  }

  /// return the original [RenderBox]'s top-left
  /// the effective geometry should be (itemPosition - targetOffset) & size!
  Rect get geometry {
    final box = context.findRenderObject() as RenderBox;
    final itemPosition = box.localToGlobal(Offset.zero);
    size = box.size;
    return itemPosition & size!;
  }

  Rect get translatedGeometry => geometry.translate(targetOffset.dx, targetOffset.dy);

  void apply({
    required int moving,
    required Size gapSize,
    bool playAnimation = true,
  }) {
    translateTo(moving: moving, gapSize: gapSize);

    if (playAnimation) {
      animate();
    } else {
      jump();
    }
    rebuild();
  }

  void translateTo({required int moving, required Size gapSize}) {
    if (index == moving) {
      targetOffset = Offset.zero;
      return;
    }

    final original = gridState.calculateCoordinate(index);
    final target = gridState.calculateCoordinate(moving);
    final mainAxis = gridState.widget.scrollDirection;

    var verticalSpacing = 0.0;
    var horizontalSpacing = 0.0;

    switch (mainAxis) {
      case Axis.vertical:
        verticalSpacing = gridState.widget.mainAxisSpacing;
        horizontalSpacing = gridState.widget.crossAxisSpacing;
        break;
      case Axis.horizontal:
        verticalSpacing = gridState.widget.crossAxisSpacing;
        horizontalSpacing = gridState.widget.mainAxisSpacing;
        break;
    }

    targetOffset = (target - original).scale(gapSize.width + horizontalSpacing, gapSize.height + verticalSpacing);
  }

  void animate() {
    if (animation == null) {
      animation = AnimationController(
        vsync: gridState,
        duration: const Duration(milliseconds: 100),
      )
        ..addListener(rebuild)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            startOffset = targetOffset;
            animation?.dispose();
            animation = null;
            rebuild();
          }
        })
        ..forward();
    } else {
      startOffset = offset;
      animation?.forward(from: 0);
    }
  }

  void jump() {
    animation?.dispose();
    animation = null;
    startOffset = targetOffset;
    // rebuild();
  }

  void rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void reset() {
    animation?.dispose();
    animation = null;
    isDragging = false;
    startOffset = Offset.zero;
    targetOffset = Offset.zero;
    rebuild();
  }
}
