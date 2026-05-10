import 'package:equatable/equatable.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final Map<String, dynamic> historicalData;
  final int selectedCategoryIndex;
  final int selectedSubFeatureIndex;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.historicalData = const {},
    this.selectedCategoryIndex = 0,
    this.selectedSubFeatureIndex = 0,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    Map<String, dynamic>? historicalData,
    int? selectedCategoryIndex,
    int? selectedSubFeatureIndex,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      historicalData: historicalData ?? this.historicalData,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedSubFeatureIndex: selectedSubFeatureIndex ?? this.selectedSubFeatureIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        historicalData,
        selectedCategoryIndex,
        selectedSubFeatureIndex,
        errorMessage,
      ];
}
