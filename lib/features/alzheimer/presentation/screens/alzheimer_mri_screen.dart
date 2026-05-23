import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'alzheimer_mri_result_screen.dart';

class AlzheimerMriScreen extends StatefulWidget {
  const AlzheimerMriScreen({super.key});

  @override
  State<AlzheimerMriScreen> createState() => _AlzheimerMriScreenState();
}

class _AlzheimerMriScreenState extends State<AlzheimerMriScreen> {
  File? _image;
  bool _isLoading = false;
  String? _errorMsg;

  static const String _apiUrl =
      'https://hossam12323-alzheimer-api.hf.space/predict-mri';

  // --- دالة الفحص وتغيير الحجم لـ 128*128 ---
  Future<File?> _validateAndResizeMRI(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) return null;

      int coloredPixels = 0;
      int totalSamples = 150;
      for (int i = 0; i < totalSamples; i++) {
        var p = decodedImage.getPixel(
            (i * 11) % decodedImage.width, (i * 17) % decodedImage.height);

        if ((p.r - p.g).abs() > 20 || (p.g - p.b).abs() > 20) {
          coloredPixels++;
        }
      }

      if (coloredPixels > (totalSamples * 0.1)) {
        if (mounted) {
          setState(() => _errorMsg = "Invalid MRI: Please upload a MRI scan only.");
        }
        return null;
      }

      img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 128,
        height: 128,
        interpolation: img.Interpolation.linear,
      );

      final directory = await Directory.systemTemp.createTemp();
      final processedFile = File('${directory.path}/validated_mri.png');
      await processedFile.writeAsBytes(img.encodePng(resizedImage));

      return processedFile;
    } catch (e) {
      if (mounted) setState(() => _errorMsg = "Error processing image.");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _isLoading = true;
        _errorMsg = null;
      });

      File? validated = await _validateAndResizeMRI(File(picked.path));

      setState(() {
        _isLoading = false;
        if (validated != null) {
          _image = validated;
          _errorMsg = null;
        } else {
          _image = null;
        }
      });
    }
  }

  Future<void> _runClassification() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_image!.path, filename: 'mri.png'),
      });

      final response = await dio.post(_apiUrl, data: formData);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlzheimerMriResultScreen(aiResult: data),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Failed to connect to server';
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
            padding: EdgeInsets.fromLTRB(10.w, 54.h, 20.w, 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                ),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('MRI Scan Analysis',
                        style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),

                  // حاوية الصورة مع Stack لإضافة أيقونة التعديل
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 280.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                            border: Border.all(
                              color: _image != null ? AppColors.primary : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22.r),
                            child: _image == null && !_isLoading
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 54.r, color: AppColors.primary.withValues(alpha: 0.4)),
                                SizedBox(height: 12.h),
                                Text('Tap to select MRI Image',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16.sp, color: Colors.grey)),
                              ],
                            )
                                : _isLoading && _image == null
                                ? const Center(child: CircularProgressIndicator())
                                : SizedBox.expand(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (_image != null && !_isLoading)
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                color: AppColors.primary,
                                size: 20.r,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  if (_errorMsg != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.shade100)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(_errorMsg!,
                                style: GoogleFonts.poppins(color: Colors.red, fontSize: 13.sp)),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: (_image != null && !_isLoading) ? _runClassification : null,
                      icon: const Icon(Icons.psychology_rounded, color: Colors.white),
                      label: Text('Start AI Classification',
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}