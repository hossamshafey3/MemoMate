import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/alzheimer/data/analytics_refresh_notifier.dart';
import 'package:gradproj/features/alzheimer/data/analytics_repository.dart';
import 'package:gradproj/features/alzheimer/data/models/mri_classification_model.dart';
import 'package:dio/dio.dart';
import 'ai_results_screen.dart'; // استيراد صفحة النتائج المطلوبة


class AlzheimerMriResultScreen extends StatefulWidget {
  final Map<String, dynamic> aiResult;

  const AlzheimerMriResultScreen({
    super.key,
    required this.aiResult,
  });

  @override
  State<AlzheimerMriResultScreen> createState() => _AlzheimerMriResultScreenState();
}

class _AlzheimerMriResultScreenState extends State<AlzheimerMriResultScreen> {
  bool _isSaving = false;

  final Map<String, Color> _resultColors = {
    'No Impairment': Colors.green,
    'Very Mild Impairment': Colors.orange,
    'Mild Impairment': Colors.deepOrange,
    'Moderate Impairment': Colors.red,
  };

  Future<void> _saveMriToBackend() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final diagnosis = widget.aiResult['diagnosis']?.toString() ?? '';
      final confidence = widget.aiResult['confidence']?.toString();
      final model = MriClassificationModel(
        mriResult: diagnosis,
        confidence: confidence,
      );
      await AnalyticsRepository().saveMriResult(model);
      AnalyticsRefreshNotifier.instance.notify();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved successfully to your history')),
        );

        // الانتقال المباشر لصفحة AiResultsScreen عند نجاح الحفظ
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

  @override
  Widget build(BuildContext context) {
    final diagnosis = widget.aiResult['diagnosis']?.toString() ?? 'Unknown';
    final themeColor = _resultColors[diagnosis] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
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
                    Navigator.popUntil(context, ModalRoute.withName('/alzheimerHub'));
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                ),
                SizedBox(width: 8.w),
                Text(
                  'MRI Analysis Result',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // عرض التشخيص النهائي فقط بدون أي نصوص فرعية أو تفاصيل
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      diagnosis == 'No Impairment'
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      color: themeColor,
                      size: 80.r,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    diagnosis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: themeColor,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 64.h),

                  // أزرار التحكم وحالة الحفظ
                  if (_isSaving)
                    Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16.h),
                        Text(
                          'Saving your report...',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    // زر الحفظ الذي يقوم بعمل الـ Navigation لـ AiResultsScreen
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: _saveMriToBackend,
                        icon: Icon(Icons.save_rounded, color: Colors.white, size: 22.r),
                        label: Text(
                          'Save Result',
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
                          elevation: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Return to Hub Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.popUntil(context, ModalRoute.withName('/alzheimerHub'));
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

                    // زر الرجوع العادي
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_return_rounded, color: AppColors.grey),
                      label: Text(
                        'Back to Upload',
                        style: GoogleFonts.poppins(
                          color: AppColors.grey,
                          fontSize: 15.sp,
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
