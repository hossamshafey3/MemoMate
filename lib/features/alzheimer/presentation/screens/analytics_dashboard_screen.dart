import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';

import '../../logic/analytics_bloc.dart';
import '../../logic/analytics_event.dart';
import '../../logic/analytics_state.dart';
import '../widgets/base_line_chart_widget.dart';
import '../widgets/binary_scatter_chart_widget.dart';
import '../widgets/mri_scatter_chart_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AnalyticsDashboardScreen
//  Provides the BLoC and converts to a StatefulWidget so we can trigger
//  a fresh fetch every time the route is resumed (didChangeDependencies /
//  RouteAware pattern is kept simple via initState + didUpdateWidget).
// ─────────────────────────────────────────────────────────────────────────────
class AnalyticsDashboardScreen extends StatelessWidget {
  final String? patientId;
  final List<dynamic>? preloadedChecks;
  final List<dynamic>? preloadedMris;
  const AnalyticsDashboardScreen({
    super.key,
    this.patientId,
    this.preloadedChecks,
    this.preloadedMris,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc()
        ..add(
          FetchHistoricalData(
            patientId: patientId,
            preloadedChecks: preloadedChecks,
            preloadedMris: preloadedMris,
          ),
        ),
      child: _AnalyticsDashboardView(
        patientId: patientId,
        preloadedChecks: preloadedChecks,
        preloadedMris: preloadedMris,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AnalyticsDashboardView  (StatefulWidget for auto-refresh on resume)
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsDashboardView extends StatefulWidget {
  final String? patientId;
  final List<dynamic>? preloadedChecks;
  final List<dynamic>? preloadedMris;
  const _AnalyticsDashboardView({
    this.patientId,
    this.preloadedChecks,
    this.preloadedMris,
  });

  @override
  State<_AnalyticsDashboardView> createState() =>
      _AnalyticsDashboardViewState();
}

class _AnalyticsDashboardViewState extends State<_AnalyticsDashboardView>
    with RouteAware {
  static const List<String> categories = [
    'Vitals & Labs',
    'Cognitive Tests',
    'Lifestyle',
    'Behavioral Check',
    'Medical History',
    'MRI Progression',
  ];

  static const Map<String, List<String>> subFeatures = {
    'Vitals & Labs': [
      'BMI',
      'Systolic BP',
      'Diastolic BP',
      'Chol. Total',
      'Chol. LDL',
      'Chol. HDL',
      'Triglycerides',
      'Hypertension',
    ],
    'Cognitive Tests': ['MMSE Score', 'Functional Assessment', 'ADL Score'],
    'Lifestyle': [
      'Smoking',
      'Alcohol',
      'Physical Activity',
      'Diet Quality',
      'Sleep Quality',
    ],
    'Behavioral Check': [
      'Memory Complaints',
      'Behavioral Problems',
      'Confusion',
      'Disorientation',
      'Personality Changes',
      'Difficulty Tasks',
      'Forgetfulness',
    ],
    'Medical History': [
      'Family History',
      'Cardiovascular Disease',
      'Diabetes',
      'Depression',
      'Head Injury',
    ],
    'MRI Progression': ['MRI Classifications'],
  };


  // ── Pull-to-refresh handler ───────────────────────────────────────────────
  Future<void> _refresh() async {
    context.read<AnalyticsBloc>().add(
      FetchHistoricalData(
        patientId: widget.patientId,
        preloadedChecks: widget.preloadedChecks,
        preloadedMris: widget.preloadedMris,
      ),
    );
    await context.read<AnalyticsBloc>().stream.firstWhere(
      (s) =>
          s.status == AnalyticsStatus.loaded ||
          s.status == AnalyticsStatus.error,
    );
  }

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
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 22.r,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 22.r,
            ),
            onPressed: () => context.read<AnalyticsBloc>().add(
              FetchHistoricalData(
                patientId: widget.patientId,
                preloadedChecks: widget.preloadedChecks,
                preloadedMris: widget.preloadedMris,
              ),
            ),
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
        listener: (context, state) {
          if (state.status == AnalyticsStatus.loaded) {
            setState(() {});
          }
        },
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading ||
              state.status == AnalyticsStatus.initial ||
              (state.historicalData.isEmpty &&
                  state.status != AnalyticsStatus.error)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AnalyticsStatus.error &&
              state.historicalData.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.primary.withValues(alpha: 0.4),
                      size: 64.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.errorMessage ?? 'Could not load data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AnalyticsBloc>().add(
                        FetchHistoricalData(
                          patientId: widget.patientId,
                          preloadedChecks: widget.preloadedChecks,
                          preloadedMris: widget.preloadedMris,
                        ),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentCategory = categories[state.selectedCategoryIndex];
          final currentSubFeatures = subFeatures[currentCategory]!;
          final dates = List<DateTime>.from(
            state.historicalData['dates'] ?? [],
          );
          final mriDates = state.historicalData['mriDates'] != null
              ? List<DateTime>.from(state.historicalData['mriDates'])
              : dates;
          final categoryData = List<List<double>>.from(
            state.historicalData[currentCategory] ?? [],
          );

          if (dates.isEmpty && mriDates.isEmpty || categoryData.isEmpty) {
            return Center(
              child: Text(
                'No data available for "$currentCategory" yet.',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final currentValues =
              categoryData[state.selectedSubFeatureIndex.clamp(
                0,
                categoryData.length - 1,
              )];
          final chartDates = currentCategory == 'MRI Progression'
              ? mriDates
              : dates;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: SafeArea(
              child: Column(
                children: [
                  if (state.status == AnalyticsStatus.error)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      color: Colors.orange.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.errorMessage ?? 'Could not refresh data.',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.read<AnalyticsBloc>().add(
                              FetchHistoricalData(
                                patientId: widget.patientId,
                                preloadedChecks: widget.preloadedChecks,
                                preloadedMris: widget.preloadedMris,
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                            context.read<AnalyticsBloc>().add(
                              ChangeFeatureCategory(index),
                            );
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : AppColors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          backgroundColor: AppColors.grey.withValues(
                            alpha: 0.1,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChartCard(
                              currentCategory,
                              state.selectedSubFeatureIndex,
                              currentValues,
                              chartDates,
                              categoryData,
                            ),
                            SizedBox(height: 20.h),
                             if (currentCategory != 'MRI Progression' &&
                                 !_isBinaryScatterMode(currentCategory, state.selectedSubFeatureIndex)) ...[
                               // ── Legend Row (continuous features only) ────────────
                               Container(
                                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.circular(12.r),
                                   border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
                                 ),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                   children: currentCategory == 'Cognitive Tests'
                                       ? [
                                           _buildLegendItem(Colors.green, 'High Score (Safe)'),
                                           _buildLegendItem(Colors.orange, 'Moderate'),
                                           _buildLegendItem(Colors.red, 'Low Score (Risk)'),
                                         ]
                                       : [
                                           _buildLegendItem(Colors.green, 'Safe / Normal'),
                                           _buildLegendItem(Colors.orange, 'Moderate'),
                                           _buildLegendItem(Colors.red, 'High Risk'),
                                         ],
                                 ),
                               ),
                               
                               SizedBox(height: 12.h),
                               Padding(
                                 padding: EdgeInsets.symmetric(horizontal: 8.w),
                                 child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Icon(Icons.info_outline_rounded, size: 16.r, color: AppColors.primary),
                                     SizedBox(width: 8.w),
                                     Expanded(
                                       child: Text(
                                         currentCategory == 'Cognitive Tests'
                                             ? 'Lower scores indicate increased risk. MMSE scores below 24 suggest cognitive impairment. ADL and Functional Assessment scores confirm daily functioning ability.'
                                             : 'These points represent the progression of the patient\'s condition over the last 7 recorded checks. High values indicate increased risk.',
                                         style: GoogleFonts.poppins(
                                           fontSize: 11.sp,
                                           color: AppColors.black.withValues(alpha: 0.6),
                                           fontStyle: FontStyle.italic,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],

                             if (_isBinaryScatterMode(currentCategory, state.selectedSubFeatureIndex) &&
                                 currentCategory != 'MRI Progression') ...[
                               SizedBox(height: 12.h),
                               Padding(
                                 padding: EdgeInsets.symmetric(horizontal: 8.w),
                                 child: Row(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Icon(Icons.scatter_plot_rounded, size: 16.r, color: AppColors.primary),
                                     SizedBox(width: 8.w),
                                     Expanded(
                                       child: Text(
                                         'Red dots indicate a risk/symptom was present (Yes). Green dots indicate a normal/clear status (No). Each column represents one health check.',
                                         style: GoogleFonts.poppins(
                                           fontSize: 11.sp,
                                           color: AppColors.black.withValues(alpha: 0.6),
                                           fontStyle: FontStyle.italic,
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],

                            SizedBox(height: 24.h),
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
                                children: List.generate(
                                  currentSubFeatures.length,
                                  (index) {
                                    final isSelected =
                                        state.selectedSubFeatureIndex == index;
                                    return FilterChip(
                                      label: Text(currentSubFeatures[index]),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        context.read<AnalyticsBloc>().add(
                                          ChangeSubFeature(index),
                                        );
                                      },
                                      selectedColor: AppColors.secondary,
                                      checkmarkColor: AppColors.primary,
                                      labelStyle: GoogleFonts.poppins(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 12.sp,
                                      ),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // ── Determine whether the current selection should render a binary scatter ─
  bool _isBinaryScatterMode(String category, int subFeatureIndex) {
    if (category == 'Behavioral Check') return true;
    if (category == 'Medical History') return true;
    if (category == 'Lifestyle' && subFeatureIndex == 0) return true;  // Smoking
    if (category == 'Vitals & Labs' && subFeatureIndex == 7) return true; // Hypertension
    return false;
  }

  Widget _buildChartCard(
    String category,
    int subFeatureIndex,
    List<double> values,
    List<DateTime> dates,
    List<List<double>> allCategoryData,
  ) {
    if (category == 'MRI Progression') {
      return MriScatterChartWidget(values: values, dates: dates);
    }

    // ── Binary scatter routing ──────────────────────────────────────────────
    if (_isBinaryScatterMode(category, subFeatureIndex)) {
      final title = subFeatures[category]![subFeatureIndex];
      String? subtitle;
      if (category == 'Behavioral Check') {
        subtitle = 'Binary scatter — Red: Risk Present, Green: Normal status';
      } else if (category == 'Medical History') {
        subtitle = 'Binary scatter — Red: Condition Present, Green: Condition Absent';
      } else if (category == 'Lifestyle' && subFeatureIndex == 0) {
        subtitle = 'Binary scatter — Red: Active smoker, Green: Non-smoker';
      } else if (category == 'Vitals & Labs' && subFeatureIndex == 7) {
        subtitle = 'Binary scatter — Red: Hypertension Diagnosed, Green: Normal BP status';
      }
      
      return BinaryScatterChartWidget(
        values: values,
        dates: dates,
        title: title,
        subtitle: subtitle,
        minY: 0.0,
        maxY: 1.0,
        interval: 1.0,
      );
    }

    // ── Standard line chart for all continuous features ─────────────────────
    String title = subFeatures[category]![subFeatureIndex];
    Color Function(double) getColorForValue;

    double minY = 0;
    double maxY = 10;
    int interval = 2;

    if (category == 'Vitals & Labs') {
      if (subFeatureIndex == 0) {
        minY = 10;
        maxY = 40;
        interval = 5;
        getColorForValue = (v) => v >= 18.5 && v <= 24.9
            ? Colors.green
            : (v < 18.5 ? Colors.red : (v < 30 ? Colors.orange : Colors.red));
      } else if (subFeatureIndex == 1) {
        // Systolic BP: 90 - 180 mmHg
        minY = 90; maxY = 180; interval = 15;
        getColorForValue = (v) =>
            v < 120 ? Colors.green : (v < 140 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) {
        minY = 40;
        maxY = 120;
        interval = 10;
        getColorForValue = (v) =>
            v < 80 ? Colors.green : (v < 90 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 3) {
        minY = 100;
        maxY = 300;
        interval = 50;
        getColorForValue = (v) =>
            v < 200 ? Colors.green : (v < 240 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 4) {
        minY = 50;
        maxY = 200;
        interval = 25;
        getColorForValue = (v) =>
            v < 100 ? Colors.green : (v < 160 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 5) {
        minY = 20;
        maxY = 100;
        interval = 10;
        getColorForValue = (v) =>
            v >= 60 ? Colors.green : (v >= 40 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 6) {
        minY = 0;
        maxY = 500;
        interval = 100;
        getColorForValue = (v) =>
            v < 150 ? Colors.green : (v < 200 ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }
    } else if (category == 'Cognitive Tests') {
      if (subFeatureIndex == 0) {
        minY = 0;
        maxY = 30;
        interval = 5;
        getColorForValue = (v) =>
            v >= 24 ? Colors.green : (v >= 10 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 1) {
        minY = 0;
        maxY = 10;
        interval = 2;
        getColorForValue = (v) =>
            v >= 8 ? Colors.green : (v >= 5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) {
        minY = 0; maxY = 10; interval = 2;
        getColorForValue = (v) =>
            v >= 5 ? Colors.green : (v >= 3 ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }
    } else if (category == 'Lifestyle') {
      // Hours per activity: 0 - 24
      minY = 0; maxY = 24; interval = 4;
      if (subFeatureIndex == 1) {
        getColorForValue = (v) =>
            v <= 3 ? Colors.green : (v <= 14 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 2) {
        getColorForValue = (v) =>
            v >= 4 ? Colors.green : (v >= 1.5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 3) {
        getColorForValue = (v) =>
            v >= 8 ? Colors.green : (v >= 5 ? Colors.orange : Colors.red);
      } else if (subFeatureIndex == 4) {
        getColorForValue = (v) => (v >= 7 && v <= 9)
            ? Colors.green
            : ((v >= 5 && v <= 10) ? Colors.orange : Colors.red);
      } else {
        getColorForValue = (v) => AppColors.primary;
      }

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
          return '${val.toInt()} active behaviors';
        } else if (category == 'Medical History') {
          return val.toInt() == 1 ? 'Condition Present' : 'Condition Absent';
        }
        return val.toStringAsFixed(1);
      },
    );
  }
}
