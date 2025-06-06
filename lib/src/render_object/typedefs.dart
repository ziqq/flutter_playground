import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_playground/src/render_object/models/resource.dart';

/// A notifier that refreshes the calendar time line every minute.
typedef CalendarTimeLineRefreshController = ValueListenable<DateTime>;

/// A callback that is called when the calendar page changes.
typedef CalendarPageChangeCallBack = void Function(DateTime date, int page);

/// This is a builder for the avatar of the resource.
typedef ResourceBuilder = Widget Function(BuildContext context, CalendarResource resource, int index);
