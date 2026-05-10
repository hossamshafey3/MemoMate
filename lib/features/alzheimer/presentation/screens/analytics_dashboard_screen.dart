import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';

import '../../logic/analytics_bloc.dart';
import '../../logic/analytics_event.dart';
import '../../logic/analytics_state.dart';
import '../widgets/base_line_chart_widget.dart';
import '../widgets/mri_scatter_chart_widget.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc()..add(FetchHistoricalData()),
      child: const _AnalyticsDashboardView(),
    );
  }
}

class _AnalyticsDashboardView extends StatelessWidget {
  const _AnalyticsDashboardView();

  static const List<String> categories = [
    'Vitals & Labs',
    'Cognitive Tests',
    'Lifestyle',
    'Behavioral Check',
    'Medical History',
    'MRI Progression'
  ];

  static const Map<String, List<String>> subFeatures = {
    'Vitals & Labs': [
      'BMI',
      'Systolic BP',
      'Diastolic BP',
      'Chol. Total',
      'Chol. LDL',
      'Chol. HDL',
      'Triglycerides'
    ],
    'Cognitive Tests': ['MMSE Score', 'Functional Assessment', 'ADL Score'],
    'Lifestyle': [
      'Smoking',
      'Alcohol',
      'Physical Activity',
      'Diet Quality',
      'Sleep Quality'
    ],
    'Behavioral Check': [
      'Memory Complaints',
      'Behavioral Problems',
      'Confusion',
      'Disorientation',
      'Personality Changes',
      'Difficulty Tasks',
      'Forgetfulness'
    ],
    'Medical History': [
      'Family History',
      'Cardiovascular Disease',
      'Diabetes',
      'Depression',
      'Head Injury'
    ],
    'MRI Progression': ['MRI Classifications'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analytics Dashboard',
          style: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary, size: 22.r),
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading ||
              state.status == AnalyticsStatus.initial ||
              state.historicalData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AnalyticsStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'An error occurred'));
          }

          final currentCategory = categories[state.selectedCategoryIndex];
          final currentSubFeatures = subFeatures[currentCategory]!;
          final dates = List<DateTime>.from(state.historicalData['dates'] ?? []);
          final categoryData = List<List<double>>.from(state.historicalData[currentCategory] ?? []);
          
          if (dates.isEmpty || categoryData.isEmpty) {
            return const Center(child: Text('Data is missing for this category.'));
          }
          
          final currentValues = categoryData[state.selectedSubFeatureIndex];

          return SafeArea(
            child: Column(
              children: [
                // 1. Main Category Tabs (Top)
                SizedBox(
                  height: 50.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, _) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final isSelected = state.selectedCategoryIndex == index;
                      return ChoiceChip(
                        label: Text(categories[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          context.read<AnalyticsBloc>().add(ChangeFeatureCategory(index));
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppColors.black,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        backgroundColor: AppColors.grey.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),

                // 2. Chart Component
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChart(currentCategory, state.selectedSubFeatureIndex, currentValues, dates),
                          SizedBox(height: 24.h),

                          // 3. Sub-feature Chips (Below Chart)
                          if (currentSubFeatures.length > 1) ...[
                            Text(
                              'Select Metric',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: List.generate(currentSubFeatures.length, (index) {
                                final isSelected = state.selectedSubFeatureIndex == index;
                                return FilterChip(
                                  label: Text(currentSubFeatures[index]),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    context.read<AnalyticsBloc>().add(ChangeSubFeature(index));
                                  },
                                  selectedColor: AppColors.secondary,
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: GoogleFonts.poppins(
                                    color: isSelected ? AppColors.primary : AppColors.black,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    fontSize: 12.sp,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(String category, int subFeatureIndex, List<double> values, List<DateTime> dates) {
    if (category == 'MRI Progression') {
      return MriScatterChartWidget(values: values, dates: dates);
    }

    String title = subFeatures[category]![subFeatureIndex];
    Color Function(double) getColorForValue;
    double minY = 0;
    double maxY = 100;
    int interval = 20;

    // Vitals & Labs Logic
    if (category == 'Vitals & Labs') {
      if (subFeatureIndex == 0) { // BMI
        minY = 10; maxY = 40; interval = 5;
        getColorForValue = (v) => v >= 18.5 && v <= 24.9 ? Colors.green : (v < 18.5 ? Colors.red : (v < 30 ? Colors.orange : Colors.red));
      } else if (subFeatureIndex == 1) { // Systolic BP
        minY = 80; maxY = 200; interval = 20;
        getColorForValue = (v) => v < 120 ? Colors.green : (v < 140 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) { // Diastolic BP
        minY = 40; maxY = 120; interval = 10;
        getColorForValue = (v) => v < 80 ? Colors.green : (v < 90 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 3) { // Chol Total
        minY = 100; maxY = 300; interval = 50;
        getColorForValue = (v) => v < 200 ? Colors.green : (v < 240 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 4) { // Chol LDL
        minY = 50; maxY = 200; interval = 25;
        getColorForValue = (v) => v < 100 ? Colors.green : (v < 160 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 5) { // Chol HDL
        minY = 20; maxY = 100; interval = 10;
        getColorForValue = (v) => v >= 60 ? Colors.green : (v >= 40 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 6) { // Triglycerides
        minY = 50; maxY = 300; interval = 50;
        getColorForValue = (v) => v < 150 ? Colors.green : (v < 200 ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }
    }
    // Cognitive Tests Logic
    else if (category == 'Cognitive Tests') {
      if (subFeatureIndex == 0) { // MMSE
        minY = 0; maxY = 30; interval = 5;
        getColorForValue = (v) => v >= 24 ? Colors.green : (v >= 10 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 1) { // Functional Assessment
        minY = 0; maxY = 10; interval = 2;
        getColorForValue = (v) => v >= 8 ? Colors.green : (v >= 5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) { // ADL
        minY = 0; maxY = 6; interval = 1;
        getColorForValue = (v) => v >= 5 ? Colors.green : (v >= 3 ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }
    }
    // Lifestyle Logic
    else if (category == 'Lifestyle') {
      if (subFeatureIndex == 0) { // Smoking
        minY = 0; maxY = 20; interval = 5;
        getColorForValue = (v) => v == 0 ? Colors.green : (v <= 10 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 1) { // Alcohol
        minY = 0; maxY = 20; interval = 5;
        getColorForValue = (v) => v <= 3 ? Colors.green : (v <= 14 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) { // Physical Activity
        minY = 0; maxY = 10; interval = 2;
        getColorForValue = (v) => v >= 4 ? Colors.green : (v >= 1.5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 3) { // Diet Quality
        minY = 0; maxY = 10; interval = 2;
        getColorForValue = (v) => v >= 8 ? Colors.green : (v >= 5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 4) { // Sleep Quality
        minY = 0; maxY = 12; interval = 2;
        getColorForValue = (v) => (v >= 7 && v <= 9) ? Colors.green : ((v >= 5 && v <= 10) ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }
    }
    // Behavioral Check Logic (0=Rare, 1=Occasional, 2=Frequent)
    else if (category == 'Behavioral Check') {
      minY = -0.5; maxY = 2.5; interval = 1;
      getColorForValue = (v) => v < 0.5 ? Colors.green : (v < 1.5 ? Colors.orange : Colors.red);
    }
    // Medical History Logic (0=None/Stable, 1=Mild, 2=Severe)
    else if (category == 'Medical History') {
      minY = -0.5; maxY = 2.5; interval = 1;
      getColorForValue = (v) => v < 0.5 ? Colors.green : (v < 1.5 ? Colors.orange : Colors.red);
    } else {
      getColorForValue = (v) => AppColors.primary;
    }

    return BaseLineChartWidget(
      values: values,
      dates: dates,
      title: title,
      minY: minY,
      maxY: maxY,
      interval: interval,
      getColorForValue: getColorForValue,
      getTooltipText: (val) {
        if (category == 'Behavioral Check') {
          if (val < 0.5) return 'Rare';
          if (val < 1.5) return 'Occasional';
          return 'Frequent';
        } else if (category == 'Medical History') {
          if (val < 0.5) return 'None/Stable';
          if (val < 1.5) return 'Mild';
          return 'Severe/Progression';
        }
        return val.toStringAsFixed(1);
      },
    );
  }
}
