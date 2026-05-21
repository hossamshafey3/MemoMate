import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchHistoricalData extends AnalyticsEvent {
  final String? patientId;
  final List<dynamic>? preloadedChecks;
  final List<dynamic>? preloadedMris;

  const FetchHistoricalData({
    this.patientId,
    this.preloadedChecks,
    this.preloadedMris,
  });

  @override
  List<Object?> get props => [patientId, preloadedChecks, preloadedMris];
}

class ChangeFeatureCategory extends AnalyticsEvent {
  final int categoryIndex;

  const ChangeFeatureCategory(this.categoryIndex);

  @override
  List<Object?> get props => [categoryIndex];
}

class ChangeSubFeature extends AnalyticsEvent {
  final int subFeatureIndex;

  const ChangeSubFeature(this.subFeatureIndex);

  @override
  List<Object?> get props => [subFeatureIndex];
}
