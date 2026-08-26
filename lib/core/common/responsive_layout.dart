import 'package:flutter/material.dart';

/// Shared screen-size rules for layouts that run on both mobile and web.
abstract final class AppBreakpoints {
  static const double tablet = 720;
  static const double desktop = 1024;
  static const double contentMaxWidth = 1360;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Phone and narrow browser widths use the stacked mobile layout.
  static bool isSingleColumn(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;
}