import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/alzheimer/data/analytics_refresh_notifier.dart';
import 'package:gradproj/features/alzheimer/data/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;
  late final StreamSubscription<void> _refreshSub;

  AnalyticsBloc({AnalyticsRepository? repository})
      : _repository = repository ?? AnalyticsRepository(),
        super(const AnalyticsState()) {
    on<FetchHistoricalData>(_onFetchHistoricalData);
    on<ChangeFeatureCategory>(_onChangeFeatureCategory);
    on<ChangeSubFeature>(_onChangeSubFeature);

    // ── Auto-refresh: re-fetch whenever a new result is saved anywhere ──────
    _refreshSub = AnalyticsRefreshNotifier.instance.stream.listen((_) {
      add(FetchHistoricalData());
    });
  }

  @override
  Future<void> close() {
    _refreshSub.cancel();
    return super.close();
  }

  // ── Fetch from backend ────────────────────────────────────────────────────
  Future<void> _onFetchHistoricalData(
      FetchHistoricalData event, Emitter<AnalyticsState> emit) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    try {
      final data = await _repository.getHistoricalAnalytics();

      if (_allListsEmpty(data)) {
        emit(state.copyWith(
          status: AnalyticsStatus.error,
          errorMessage:
              'No records found. Please complete a health check first.',
        ));
        return;
      }

      emit(state.copyWith(
        status: AnalyticsStatus.loaded,
        historicalData: data,
        selectedCategoryIndex: state.selectedCategoryIndex,
        selectedSubFeatureIndex: state.selectedSubFeatureIndex,
      ));
    } catch (e) {
      // Keep any previously loaded data so the UI stays usable.
      emit(state.copyWith(
        status: AnalyticsStatus.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  void _onChangeFeatureCategory(
      ChangeFeatureCategory event, Emitter<AnalyticsState> emit) {
    if (state.selectedCategoryIndex != event.categoryIndex) {
      emit(state.copyWith(
        selectedCategoryIndex: event.categoryIndex,
        selectedSubFeatureIndex: 0,
      ));
    }
  }

  void _onChangeSubFeature(
      ChangeSubFeature event, Emitter<AnalyticsState> emit) {
    if (state.selectedSubFeatureIndex != event.subFeatureIndex) {
      emit(state.copyWith(selectedSubFeatureIndex: event.subFeatureIndex));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _allListsEmpty(Map<String, dynamic> data) {
    final dates = data['dates'];
    if (dates is List && dates.isNotEmpty) return false;
    final mriDates = data['mriDates'];
    if (mriDates is List && mriDates.isNotEmpty) return false;
    return true;
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') ||
        msg.contains('no internet') ||
        msg.contains('connectionerror')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('timeout')) {
      return 'Server is taking too long. Please try again.';
    }
    if (msg.contains('401') ||
        msg.contains('unauthorised') ||
        msg.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    return 'Could not load analytics data. Pull down to retry.';
  }
}
