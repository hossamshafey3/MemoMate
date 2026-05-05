import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'alzheimer_behavioral_screen.dart';
import 'alzheimer_wizard_progress.dart';

class AlzheimerCognitiveScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const AlzheimerCognitiveScreen({super.key, required this.data});

  @override
  State<AlzheimerCognitiveScreen> createState() =>
      _AlzheimerCognitiveScreenState();
}

class _AlzheimerCognitiveScreenState extends State<AlzheimerCognitiveScreen> {
  final TextEditingController _mmse = TextEditingController();
  final TextEditingController _func = TextEditingController();
  final TextEditingController _adl = TextEditingController();

  @override
  void dispose() {
    _mmse.dispose();
    _func.dispose();
    _adl.dispose();
    super.dispose();
  }

  void _next() {
    widget.data.addAll({
      'MMSE': double.tryParse(_mmse.text) ?? 20.0,
      'FunctionalAssessment': double.tryParse(_func.text) ?? 5.0,
      'ADL': double.tryParse(_adl.text) ?? 8.0,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AlzheimerBehavioralScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 5,
            title: 'Cognitive Tests',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _buildInfoCard(),
                  SizedBox(height: 20.h),
                  _buildField(_mmse, 'MMSE Score', '0 – 30',
                      'Mini Mental State Examination'),
                  SizedBox(height: 14.h),
                  _buildField(_func, 'Functional Assessment', '0 – 10',
                      'Ability to perform daily functions'),
                  SizedBox(height: 14.h),
                  _buildField(_adl, 'ADL Score', '0 – 10',
                      'Activities of Daily Living score'),
                  SizedBox(height: 40.h),
                  _NextButton(onTap: _next),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: Colors.amber.shade700, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Lower MMSE scores (< 24) suggest cognitive impairment. ADL and Functional scores help confirm daily functioning ability.',
              style: GoogleFonts.poppins(
                  fontSize: 11.sp, color: Colors.amber.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint,
      String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.poppins(
              fontSize: 14.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                fontSize: 12.sp, color: Colors.grey.shade400),
            labelStyle: GoogleFonts.poppins(
                fontSize: 13.sp, color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(14.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            filled: true,
            fillColor: AppColors.primary.withValues(alpha: 0.03),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.w, top: 4.h),
          child: Text(
            description,
            style: GoogleFonts.poppins(
                fontSize: 11.sp, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text('Next  →',
            style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}
