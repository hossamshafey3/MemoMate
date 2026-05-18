import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:gradproj/features/alzheimer/data/analytics_refresh_notifier.dart';
import 'package:gradproj/features/alzheimer/data/analytics_repository.dart';
import 'package:gradproj/features/alzheimer/data/models/ai_diagnosis_result_model.dart';
import 'alzheimer_mri_screen.dart';
import 'alzheimer_wizard_progress.dart';
import 'ai_results_screen.dart';

class AlzheimerBehavioralScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const AlzheimerBehavioralScreen({super.key, required this.data});

  @override
  State<AlzheimerBehavioralScreen> createState() =>
      _AlzheimerBehavioralScreenState();
}

class _AlzheimerBehavioralScreenState
    extends State<AlzheimerBehavioralScreen> {
  bool _memory = false;
  bool _behavior = false;
  bool _confusion = false;
  bool _disorientation = false;
  bool _personality = false;
  bool _difficulty = false;
  bool _forget = false;

  bool? _isPositive;
  String? _errorMsg;
  bool _isLoading = false;
  bool _isSaving = false;

  static const String _apiUrl =
      'https://hossam12323-alzheimer-api.hf.space/predict-text';

  Future<void> _runDiagnosis() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _isPositive = null;
    });

    widget.data.addAll({
      'MemoryComplaints': _memory ? 1 : 0,
      'BehavioralProblems': _behavior ? 1 : 0,
      'Confusion': _confusion ? 1 : 0,
      'Disorientation': _disorientation ? 1 : 0,
      'PersonalityChanges': _personality ? 1 : 0,
      'DifficultyCompletingTasks': _difficulty ? 1 : 0,
      'Forgetfulness': _forget ? 1 : 0,
    });

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await dio.post(
        _apiUrl,
        data: jsonEncode(widget.data),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        final bool diagnosed = result['diagnosis'] == 1;

        setState(() {
          _isPositive = diagnosed;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = e.message ?? 'Failed to connect to AI server';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'An unexpected error occurred';
      });
    }
  }

  /// Saves the completed check to the Memomate backend when requested.
  Future<void> _saveCheckToBackend(bool diagnosed) async {
    setState(() {
      _isSaving = true;
    });
    try {
      final model = AiDiagnosisResultModel(
        alzheimerDetected: diagnosed,
        clinicalFeatures: Map<String, dynamic>.from(widget.data),
      );
      await AnalyticsRepository().saveCheck(model);
      // Notify the AnalyticsDashboard to re-fetch immediately
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
          SnackBar(content: Text('Error: $errorMessage')),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 6,
            title: 'Behavioral Check',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  _buildSwitch('Memory Complaints', _memory,
                          (v) => setState(() => _memory = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Behavioral Problems', _behavior,
                          (v) => setState(() => _behavior = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Confusion', _confusion,
                          (v) => setState(() => _confusion = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Disorientation', _disorientation,
                          (v) => setState(() => _disorientation = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Personality Changes', _personality,
                          (v) => setState(() => _personality = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Difficulty Completing Tasks', _difficulty,
                          (v) => setState(() => _difficulty = v)),
                  SizedBox(height: 34.h), // مسافة 34 كما طلبتِ
                  _buildSwitch('Forgetfulness', _forget,
                          (v) => setState(() => _forget = v)),

                  SizedBox(height: 40.h),

                  // Error message
                  if (_errorMsg != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 20.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 22.r),
                          SizedBox(width: 12.w),
                          Expanded(
                              child: Text(_errorMsg!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14.sp, color: Colors.red))),
                        ],
                      ),
                    ),

                  // Run button
                  _isLoading
                      ? Column(
                    children: [
                      CircularProgressIndicator(
                          color: AppColors.primary),
                      SizedBox(height: 12.h),
                      Text('Analyzing data...',
                          style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: AppColors.primary)),
                    ],
                  )
                      : SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: _runDiagnosis,
                      icon: Icon(Icons.smart_toy_outlined,
                          color: Colors.white, size: 22.r),
                      label: Text('Run AI Diagnosis',
                          style: GoogleFonts.poppins(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14.r)),
                        elevation: 2,
                      ),
                    ),
                  ),

                  // Result
                  if (_isPositive != null) ...[
                    SizedBox(height: 34.h),
                    _buildResultCard(),
                    SizedBox(height: 24.h),
                    // Save Button
                    _isSaving
                        ? Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 12.h),
                              Text('Saving result...',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15.sp, color: AppColors.primary)),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton.icon(
                              onPressed: () => _saveCheckToBackend(_isPositive!),
                              icon: Icon(Icons.save_rounded, color: Colors.white, size: 22.r),
                              label: Text('Save Result',
                                  style: GoogleFonts.poppins(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r)),
                                elevation: 2,
                              ),
                            ),
                          ),
                  ],
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _automatedSaveAndProceed() async {
    setState(() {
      _isSaving = true;
    });
    try {
      final model = AiDiagnosisResultModel(
        alzheimerDetected: _isPositive!,
        clinicalFeatures: Map<String, dynamic>.from(widget.data),
      );
      await AnalyticsRepository().saveCheck(model);
      AnalyticsRefreshNotifier.instance.notify();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlzheimerMriScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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

  Widget _buildResultCard() {
    final detected = _isPositive!;
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: detected ? Colors.red.shade300 : Colors.green.shade300,
            width: 2),
        boxShadow: [
          BoxShadow(
            color:
            (detected ? Colors.red : Colors.green).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(
            detected
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            color: detected ? Colors.red : Colors.green,
            size: 50.r,
          ),
          SizedBox(height: 15.h),
          Text(
            detected ? "Alzheimer's Detected" : "No Alzheimer's Detected",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: detected ? Colors.red : Colors.green,
            ),
          ),
          if (detected) ...[
            SizedBox(height: 12.h),
            Text(
              'Additional MRI scanning is recommended for confirmation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.black.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 20.h),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: _automatedSaveAndProceed,
                      icon: Icon(Icons.image_search_rounded,
                          color: Colors.white, size: 22.r),
                      label: Text('Proceed to MRI Scan',
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
            color: value
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 15.sp, // زيادة حجم الخط
                fontWeight: FontWeight.w500,
                color: AppColors.black)),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h), // زيادة المساحة الداخلية
      ),
    );
  }
}
