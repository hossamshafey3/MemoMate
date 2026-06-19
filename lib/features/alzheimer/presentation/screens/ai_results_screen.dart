import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/alzheimer/data/analytics_repository.dart';
import 'package:intl/intl.dart';

import 'ai_result_detail_screen.dart';

class AiResultsScreen extends StatefulWidget {
  final String? patientId;
  final List<dynamic>? preloadedChecks;
  final List<dynamic>? preloadedMris;

  const AiResultsScreen({
    super.key,
    this.patientId,
    this.preloadedChecks,
    this.preloadedMris,
  });

  @override
  State<AiResultsScreen> createState() => _AiResultsScreenState();
}

class _AiResultsScreenState extends State<AiResultsScreen> {
  final AnalyticsRepository _repository = AnalyticsRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.preloadedChecks != null || widget.preloadedMris != null) {
        final List<Map<String, dynamic>> history = [];
        if (widget.preloadedChecks != null) {
          for (var check in widget.preloadedChecks!) {
            if (check is Map) {
              final checkMap = Map<String, dynamic>.from(check);
              final textData =
                  checkMap['text_data']?.toString() ??
                  (checkMap['result'] == 1
                      ? 'Alzheimer\'s Detected'
                      : 'No Alzheimer\'s Detected');
              final resultVal =
                  checkMap['result'] ??
                  (checkMap['text_data']?.toString().toLowerCase().contains(
                            'detected',
                          ) ==
                          true
                      ? 1
                      : 0);

              history.add({
                ...checkMap,
                'type': 'Full AI Diagnosis',
                'text_data': textData,
                'result': resultVal,
              });
            }
          }
        }
        if (widget.preloadedMris != null) {
          for (var mri in widget.preloadedMris!) {
            if (mri is Map) {
              final mriMap = Map<String, dynamic>.from(mri);
              final textData =
                  mriMap['text_data']?.toString() ??
                  mriMap['result']?.toString() ??
                  'No Result';

              history.add({
                ...mriMap,
                'type': 'MRI-Only',
                'text_data': textData,
                'result': textData,
              });
            }
          }
        }
        history.sort((a, b) {
          final dateA =
              DateTime.tryParse(
                (a['createdAt'] ?? a['date'] ?? '').toString(),
              ) ??
              DateTime(2000);
          final dateB =
              DateTime.tryParse(
                (b['createdAt'] ?? b['date'] ?? '').toString(),
              ) ??
              DateTime(2000);
          return dateB.compareTo(dateA);
        });
        setState(() {
          _history = history;
          _isLoading = false;
        });
        return;
      }

      final data = await _repository.getAllResults(patientId: widget.patientId);
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load history. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI Results',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64.r,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(_error!, style: GoogleFonts.poppins(fontSize: 16.sp)),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: _fetchHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _history.isEmpty
          ? Center(
              child: Text(
                'No saved results found.',
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return _buildResultCard(item);
                },
              ),
            ),
      bottomNavigationBar: widget.patientId != null
          ? null
          : Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.settings.name == '/alzheimerHub' || route.isFirst,
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
            ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    final type = item['type'] ?? 'Diagnosis';
    final rawDate = item['createdAt'] ?? item['date'] ?? '';
    final date = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

    final textData = item['text_data']?.toString();
    final rawResult = item['result'];

    // Determine verdict string
    String verdict = 'No Result';
    if (textData != null && textData.isNotEmpty && textData != 'null') {
      verdict = textData;
    } else if (rawResult != null) {
      // Fallback for numeric results
      if (rawResult == 1) {
        verdict = 'Alzheimer\'s Detected';
      } else if (rawResult == 0) {
        verdict = 'No Alzheimer\'s Detected';
      } else {
        verdict = rawResult.toString();
      }
    }

    // Determine if detected
    bool isDetected = false;
    if (rawResult is num) {
      isDetected = rawResult > 0;
    } else {
      final vLow = verdict.toLowerCase();
      isDetected = vLow.contains('detected') && !vLow.contains('no');
    }

    final color = isDetected ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiResultDetailScreen(
              result: item,
              isDoctor: widget.patientId != null,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Verdict:',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              verdict,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
