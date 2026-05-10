import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc() : super(const AnalyticsState()) {
    on<FetchHistoricalData>(_onFetchHistoricalData);
    on<ChangeFeatureCategory>(_onChangeFeatureCategory);
    on<ChangeSubFeature>(_onChangeSubFeature);
  }

  void _onFetchHistoricalData(
      FetchHistoricalData event, Emitter<AnalyticsState> emit) {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    
    // Hardcoded mock data for 7 sequential checkups as requested.
    // Structure: Feature -> SubFeature -> List of 7 values.
    final mockData = {
      'dates': [
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now().subtract(const Duration(days: 150)),
        DateTime.now().subtract(const Duration(days: 120)),
        DateTime.now().subtract(const Duration(days: 90)),
        DateTime.now().subtract(const Duration(days: 60)),
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      ],
      'Vitals & Labs': [
        [24.0, 24.5, 25.1, 25.5, 26.0, 25.8, 26.2], // BMI
        [118.0, 120.0, 125.0, 130.0, 135.0, 142.0, 145.0], // Systolic BP
        [78.0, 80.0, 82.0, 85.0, 88.0, 92.0, 95.0], // Diastolic BP
        [180.0, 190.0, 205.0, 210.0, 220.0, 230.0, 245.0], // Cholesterol Total
        [90.0, 95.0, 110.0, 120.0, 130.0, 145.0, 165.0], // Cholesterol LDL
        [65.0, 62.0, 58.0, 55.0, 50.0, 45.0, 38.0], // Cholesterol HDL (lower is worse)
        [120.0, 130.0, 145.0, 160.0, 175.0, 190.0, 210.0], // Cholesterol Triglycerides
      ],
      'Cognitive Tests': [
        [28.0, 28.0, 27.0, 25.0, 24.0, 22.0, 19.0], // MMSE Score
        [9.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0], // Functional Assessment
        [6.0, 6.0, 5.0, 5.0, 4.0, 3.0, 2.0], // ADL Score
      ],
      'Lifestyle': [
        [0.0, 0.0, 2.0, 5.0, 8.0, 12.0, 15.0], // Smoking
        [2.0, 2.0, 4.0, 6.0, 8.0, 10.0, 16.0], // Alcohol Consumption
        [5.0, 4.5, 4.0, 3.0, 2.0, 1.5, 1.0], // Physical Activity
        [9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0], // Diet Quality
        [8.0, 7.5, 7.0, 6.0, 5.0, 4.5, 4.0], // Sleep Quality
      ],
      'Behavioral Check': [
        [0.0, 0.0, 0.0, 1.0, 1.0, 2.0, 2.0], // Memory Complaints (0=Rare, 1=Occasional, 2=Frequent)
        [0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 2.0], // Behavioral Problems
        [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 2.0], // Confusion
        [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 2.0], // Disorientation
        [0.0, 0.0, 0.0, 1.0, 1.0, 2.0, 2.0], // Personality Changes
        [0.0, 0.0, 1.0, 1.0, 1.0, 2.0, 2.0], // Difficulty Completing Tasks
        [0.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0], // Forgetfulness
      ],
      'Medical History': [
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], // Family History of Alzheimer\'s (0=None, 1=Mild, 2=Severe)
        [0.0, 0.0, 1.0, 1.0, 1.0, 2.0, 2.0], // Cardiovascular Disease
        [0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0], // Diabetes
        [0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 2.0], // Depression
        [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], // Head Injury
      ],
      'MRI Progression': [
        [0.0, 0.0, 1.0, 1.0, 2.0, 2.0, 3.0], // MRI Classifications (0=None, 1=Very Mild, 2=Mild, 3=Moderate)
      ],
    };

    emit(state.copyWith(
      status: AnalyticsStatus.loaded,
      historicalData: mockData,
      selectedCategoryIndex: 0,
      selectedSubFeatureIndex: 0,
    ));
  }

  void _onChangeFeatureCategory(
      ChangeFeatureCategory event, Emitter<AnalyticsState> emit) {
    if (state.selectedCategoryIndex != event.categoryIndex) {
      emit(state.copyWith(
        selectedCategoryIndex: event.categoryIndex,
        selectedSubFeatureIndex: 0, // Reset subfeature when category changes
      ));
    }
  }

  void _onChangeSubFeature(
      ChangeSubFeature event, Emitter<AnalyticsState> emit) {
    if (state.selectedSubFeatureIndex != event.subFeatureIndex) {
      emit(state.copyWith(
        selectedSubFeatureIndex: event.subFeatureIndex,
      ));
    }
  }
}
