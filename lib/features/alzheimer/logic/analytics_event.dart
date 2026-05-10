import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchHistoricalData extends AnalyticsEvent {}

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
