// ─────────────────────────────────────────────────────────────────────────────
//  analytics_refresh_notifier.dart  –  Memomate
//
//  A lightweight singleton Stream that lets ANY part of the app broadcast
//  "new data was saved" so the AnalyticsDashboardScreen can immediately
//  re-fetch from the server without needing a shared BLoC instance.
//
//  Usage (emit a refresh signal after saving):
//    AnalyticsRefreshNotifier.instance.notify();
//
//  Usage (listen in AnalyticsBloc or a widget):
//    AnalyticsRefreshNotifier.instance.stream.listen((_) { ... });
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

class AnalyticsRefreshNotifier {
  AnalyticsRefreshNotifier._();

  static final AnalyticsRefreshNotifier instance =
      AnalyticsRefreshNotifier._();

  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  /// Stream that emits a void event whenever new data is saved.
  Stream<void> get stream => _controller.stream;

  /// Call this after successfully saving a check or MRI result.
  void notify() => _controller.add(null);

  void dispose() => _controller.close();
}
