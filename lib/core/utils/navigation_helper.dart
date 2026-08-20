import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anet_merchants/core/utils/browser_history.dart';

/// Keeps pushed-screen back navigation safe when a browser route is opened
/// directly or its history has been lost after a refresh.
abstract final class NavigationHelper {
  static void backOrGo(BuildContext context, String fallbackLocation) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    goToRoot(context, fallbackLocation);
  }

  /// Returns to the base Home history entry on web and clears the pushed
  /// Navigator stack on other platforms. This prevents browser Back from
  /// reopening completed filter, history, detail, and invoice flows.
  static void goHomeAndClearStack(BuildContext context, String homeLocation) {
    final router = GoRouter.of(context);
    final pushedRouteCount = router.routerDelegate.currentConfiguration.matches
        .whereType<ImperativeRouteMatch>()
        .length;

    if (rewindBrowserHistory(pushedRouteCount)) {
      return;
    }

    goToRoot(context, homeLocation);
  }

  static void goToRoot(BuildContext context, String location) {
    final router = GoRouter.of(context);

    Router.neglect(context, () {
      while (router.canPop()) {
        router.pop();
      }
      router.go(location);
    });
  }
}
