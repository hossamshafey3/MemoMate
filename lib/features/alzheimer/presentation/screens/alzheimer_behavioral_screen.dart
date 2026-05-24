import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:dio/dio.dart';
import 'alzheimer_wizard_progress.dart';
import 'alzheimer_text_result_screen.dart';

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

  String? _errorMsg;
  bool _isLoading = false;

  static const String _apiUrl =
      'https://hossam12323-alzheimer-api.hf.space/predict-text';

  Future<void> _runDiagnosis() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
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
          _isLoading = false;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlzheimerTextResultScreen(
                diagnosed: diagnosed,
                data: Map<String, dynamic>.from(widget.data),
              ),
            ),
          );
        }
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


                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
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
