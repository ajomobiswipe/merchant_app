import 'dart:js_interop';

import 'package:web/web.dart' as web;

web.EventListener? _popStateListener;
bool _authenticatedHistoryGuardEnabled = false;

bool rewindBrowserHistory(int entryCount) {
  if (entryCount <= 0) return false;

  web.window.history.go(-entryCount);
  return true;
}

/// Keeps stale Login/Splash entries from becoming visible after authentication.
void setAuthenticatedHistoryGuard(bool enabled) {
  _authenticatedHistoryGuardEnabled = enabled;

  if (!enabled) {
    disposeBrowserHistoryGuard();
    return;
  }

  if (_popStateListener != null) return;

  _popStateListener = ((web.Event _) {
    if (!_authenticatedHistoryGuardEnabled || !_isAuthenticationLocation()) {
      return;
    }

    web.window.history.forward();
  }).toJS;
  web.window.addEventListener('popstate', _popStateListener);
}

void disposeBrowserHistoryGuard() {
  final listener = _popStateListener;
  if (listener != null) {
    web.window.removeEventListener('popstate', listener);
    _popStateListener = null;
  }
  _authenticatedHistoryGuardEnabled = false;
}

bool _isAuthenticationLocation() {
  final fragment = web.window.location.hash.toLowerCase();
  return fragment.isEmpty ||
      fragment == '#' ||
      fragment.startsWith('#/login') ||
      fragment.startsWith('#/splash');
}
