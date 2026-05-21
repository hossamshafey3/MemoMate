import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'alzheimer_hub_screen.dart';

class AiResultDetailScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AiResultDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final type = result['type'] ?? 'Diagnosis';
    final rawDate = result['createdAt'] ?? result['date'] ?? '';
    final date = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    final formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(date);

    final textData = result['text_data']?.toString();
    final rawResult = result['result'];

    // Determine verdict string for display
    String finalVerdict = 'No Result';
    if (textData != null && textData.isNotEmpty && textData != 'null') {
      finalVerdict = textData;
    } else if (rawResult != null) {
      if (rawResult == 1) {
        finalVerdict = 'Alzheimer\'s Detected';
      } else if (rawResult == 0) {
        finalVerdict = 'No Alzheimer\'s Detected';
      } else {
        finalVerdict = rawResult.toString();
      }
    }

    final features = result['features'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Divider(height: 32.h),
                  if (finalVerdict != 'No Result') ...[
                    _buildResultRow(
                      type == 'MRI-Only' ? 'MRI Classification' : 'AI Verdict',
                      finalVerdict,
                      (rawResult is num && rawResult > 0) ||
                              finalVerdict.toLowerCase().contains('detected')
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 32.h),

            if (features.isNotEmpty) ...[
              Text(
                'Clinical Features',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, indent: 20.w, endIndent: 20.w),
                  itemBuilder: (context, index) {
                    final key = features.keys.elementAt(index);
                    final value = features[key];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _formatKey(key),
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Text(
                            value.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else if (type == 'MRI-Only') ...[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 48.r,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No clinical features recorded for this MRI-only scan.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AlzheimerHubScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Hub',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatKey(String key) {
    // Convert CamelCase or snake_case to human readable
    final result = key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim();
    return result[0].toUpperCase() + result.substring(1);
  }
}
