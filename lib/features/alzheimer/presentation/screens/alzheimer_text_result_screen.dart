import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/alzheimer/data/analytics_refresh_notifier.dart';
import 'package:gradproj/features/alzheimer/data/analytics_repository.dart';
import 'package:gradproj/features/alzheimer/data/models/ai_diagnosis_result_model.dart';
import 'package:dio/dio.dart';
import 'alzheimer_mri_screen.dart';
import 'ai_results_screen.dart';


class AlzheimerTextResultScreen extends StatefulWidget {
  final bool diagnosed;
  final Map<String, dynamic> data;

  const AlzheimerTextResultScreen({
    super.key,
    required this.diagnosed,
    required this.data,
  });

  @override
  State<AlzheimerTextResultScreen> createState() => _AlzheimerTextResultScreenState();
}

class _AlzheimerTextResultScreenState extends State<AlzheimerTextResultScreen> {
  bool _isSaving = false;

  Future<void> _saveCheckToBackend() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final model = AiDiagnosisResultModel(
        alzheimerDetected: widget.diagnosed,
        clinicalFeatures: Map<String, dynamic>.from(widget.data),
      );
      await AnalyticsRepository().saveCheck(model);
      AnalyticsRefreshNotifier.instance.notify();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved successfully to your history')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AiResultsScreen()),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to save result.';
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? e.message ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _automatedSaveAndProceed() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final model = AiDiagnosisResultModel(
        alzheimerDetected: widget.diagnosed,
        clinicalFeatures: Map<String, dynamic>.from(widget.data),
      );
      await AnalyticsRepository().saveCheck(model);
      AnalyticsRefreshNotifier.instance.notify();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AlzheimerMriScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detected = widget.diagnosed;
    final cardColor = detected ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Premium Gradient Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(10.w, 54.h, 20.w, 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.settings.name == '/alzheimerHub' || route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Diagnosis Result',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  // Premium Elevated Verdict Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(28.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: cardColor.withValues(alpha: 0.35),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            detected
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            color: cardColor,
                            size: 56.r,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          detected ? "Alzheimer's Detected" : "No Alzheimer's Detected",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: cardColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          detected
                              ? 'Additional MRI scanning is highly recommended to confirm this clinical finding.'
                              : 'Your cognitive and behavioral checks align within normal limits. However, continue regular checkups for preventive health.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.black.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Actions block
                  if (_isSaving)
                    Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'Processing and saving...',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    if (detected) ...[
                      // Proceed to MRI Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton.icon(
                          onPressed: _automatedSaveAndProceed,
                          icon: Icon(Icons.image_search_rounded, color: Colors.white, size: 22.r),
                          label: Text(
                            'Proceed to MRI Scan',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Save Result Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: _saveCheckToBackend,
                        icon: Icon(Icons.save_rounded, color: Colors.white, size: 22.r),
                        label: Text(
                          'Save Result Only',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Return to Hub Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            (route) => route.settings.name == '/alzheimerHub' || route.isFirst,
                          );
                        },
                        icon: Icon(Icons.home_rounded, color: AppColors.primary, size: 22.r),
                        label: Text(
                          'Return to Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Back button alternative
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_return_rounded, color: AppColors.grey),
                      label: Text(
                        'Back to Assessment',
                        style: GoogleFonts.poppins(
                          color: AppColors.grey,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
