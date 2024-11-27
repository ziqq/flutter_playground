import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_playground/src/dragable_grid_gallery/dragable_grid_gallery.dart';
import 'package:flutter_playground/src/dragable_grid_gallery/gallery_item.dart';

typedef GalleryItemDragUpdate = void Function(GalleryItemDrag, Offset, Offset);
typedef GalleryItemDragCallback = void Function(GalleryItemDrag);

Offset _overlayOrigin(BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

/// {@template gallery_drag}
/// A drag that represents an item in the gallery.
/// {@endtemplate}
class GalleryItemDrag extends Drag {
  /// {@macro gallery_drag}
  GalleryItemDrag({
    required GalleryItemWidgetState item,
    Offset initialPosition = Offset.zero,
    this.onDragUpdate,
    this.onDragCancel,
    this.onDragEnd,
  }) {
    final itemBox = item.context.findRenderObject()! as RenderBox;
    gridState = item.gridState;
    index = item.index;
    child = item.widget.child;
    dragPosition = initialPosition;
    dragOffset = itemBox.globalToLocal(initialPosition);
    itemSize = itemBox.size;
  }

  /// The index of the item in the gallery.
  late int index;

  /// The size of the item.
  late Size itemSize;

  /// The offset of the drag.
  late Offset dragOffset;

  /// The position of the drag.
  late Offset dragPosition;

  /// The child widget.
  late Widget child;

  /// The state of the gallery.
  late DragableGridGalleryState gridState;

  /// Callback for drag update.
  final GalleryItemDragUpdate? onDragUpdate;

  /// Callback for drag end.
  final GalleryItemDragCallback? onDragEnd;

  /// Callback for drag cancel.
  final GalleryItemDragCallback? onDragCancel;

  @override
  void update(DragUpdateDetails details) {
    final delta = details.delta;
    dragPosition += delta;
    onDragUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    onDragEnd?.call(this);
  }

  @override
  void cancel() {
    onDragCancel?.call(this);
  }

  /// get the top-left position of the dragging item
  Offset overlayPosition(BuildContext context) =>
      dragPosition - dragOffset - _overlayOrigin(context);

  Widget buildOverlay(BuildContext context) => _DraggingItemOverlay(
        position: overlayPosition(context),
        gridState: gridState,
        size: itemSize,
        index: index,
        child: child,
      );
}

/// Overlay for dragging item.
class _DraggingItemOverlay extends StatelessWidget {
  const _DraggingItemOverlay({
    required this.index,
    required this.size,
    required this.position,
    required this.child,
    required this.gridState,
    super.key, // ignore: unused_element
  });

  /// The index of the item in the gallery.
  final int index;

  /// The size of the item.
  final Size size;

  /// The position of the item.
  final Offset position;

  /// The child widget.
  final Widget child;

  /// The state of the gallery.
  final DragableGridGalleryState gridState;

  @override
  Widget build(BuildContext context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: Material(
          elevation: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
            ),
            child: SizedBox.fromSize(size: size, child: child),
          ),
        ),
      );
}
