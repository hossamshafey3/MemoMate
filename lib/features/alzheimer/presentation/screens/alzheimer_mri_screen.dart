import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class AlzheimerMriScreen extends StatefulWidget {
  const AlzheimerMriScreen({super.key});

  @override
  State<AlzheimerMriScreen> createState() => _AlzheimerMriScreenState();
}

class _AlzheimerMriScreenState extends State<AlzheimerMriScreen> {
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMsg;

  static const String _apiUrl =
      'https://hossam12323-alzheimer-api.hf.space/predict-mri';

  final Map<String, Color> _resultColors = {
    'No Impairment': Colors.green,
    'Very Mild Impairment': Colors.orange,
    'Mild Impairment': Colors.deepOrange,
    'Moderate Impairment': Colors.red,
  };

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
        _errorMsg = null;
      });
    }
  }

  Future<void> _runClassification() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _result = null;
      _errorMsg = null;
    });

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 60);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_image!.path,
            filename: 'mri_scan.jpg'),
      });

      final response = await dio.post(_apiUrl, data: formData);

      if (response.statusCode == 200) {
        setState(() {
          _result = response.data as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg =
              response.data['error'] ?? 'Unexpected response from server';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      final errData = e.response?.data;
      setState(() {
        _errorMsg = (errData is Map && errData.containsKey('error'))
            ? errData['error']
            : (e.message ?? 'Failed to connect to server');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 54.h, 20.w, 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.75)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 22.r),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.biotech_rounded,
                        color: Colors.white, size: 28.r),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MRI Scan Analysis',
                            style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Upload a grayscale brain MRI scan',
                            style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color:
                                    Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),

                  // Image picker area
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 220.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _image != null
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          width: _image != null ? 2 : 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 48.r,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5)),
                                SizedBox(height: 12.h),
                                Text('Tap to select MRI image',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.6))),
                                SizedBox(height: 4.h),
                                Text(
                                    'Only grayscale brain MRI scans are accepted',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade400)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18.r),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Change image button
                  if (_image != null)
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.swap_horiz_rounded,
                          color: AppColors.primary, size: 18.r),
                      label: Text('Change Image',
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp, color: AppColors.primary)),
                    ),

                  SizedBox(height: 8.h),

                  // Error
                  if (_errorMsg != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 20.r),
                          SizedBox(width: 10.w),
                          Expanded(
                              child: Text(_errorMsg!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade700))),
                        ],
                      ),
                    ),

                  // Classify button
                  _isLoading
                      ? Column(
                          children: [
                            SizedBox(height: 8.h),
                            CircularProgressIndicator(
                                color: AppColors.primary),
                            SizedBox(height: 10.h),
                            Text('Processing MRI scan...',
                                style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: AppColors.primary)),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton.icon(
                            onPressed:
                                _image == null ? null : _runClassification,
                            icon: Icon(Icons.psychology_rounded,
                                color: Colors.white, size: 20.r),
                            label: Text('Start AI Classification',
                                style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14.r)),
                            ),
                          ),
                        ),

                  // Result card
                  if (_result != null) ...[
                    SizedBox(height: 24.h),
                    _buildResultCard(_result!),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final diagnosis = result['diagnosis'] as String? ?? 'Unknown';
    final confidence = result['confidence'] as String? ?? '';
    final color = _resultColors[diagnosis] ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              diagnosis == 'No Impairment'
                  ? Icons.check_circle_outline_rounded
                  : Icons.warning_amber_rounded,
              color: color,
              size: 40.r,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            diagnosis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (confidence.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              'Confidence: $confidence',
              style: GoogleFonts.poppins(
                  fontSize: 13.sp, color: Colors.grey.shade600),
            ),
          ],
          SizedBox(height: 16.h),
          _buildSeverityBar(diagnosis),
        ],
      ),
    );
  }

  Widget _buildSeverityBar(String diagnosis) {
    final levels = [
      'No Impairment',
      'Very Mild Impairment',
      'Mild Impairment',
      'Moderate Impairment',
    ];
    final idx = levels.indexOf(diagnosis);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Severity Level',
            style: GoogleFonts.poppins(
                fontSize: 11.sp, color: Colors.grey.shade500)),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(levels.length, (i) {
            final colors = [Colors.green, Colors.orange, Colors.deepOrange, Colors.red];
            final active = i <= idx;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4.w : 0),
                height: 8.h,
                decoration: BoxDecoration(
                  color: active ? colors[i] : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
