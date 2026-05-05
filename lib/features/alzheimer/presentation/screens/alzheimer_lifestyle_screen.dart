import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'alzheimer_cognitive_screen.dart';
import 'alzheimer_wizard_progress.dart';

class AlzheimerLifestyleScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const AlzheimerLifestyleScreen({super.key, required this.data});

  @override
  State<AlzheimerLifestyleScreen> createState() =>
      _AlzheimerLifestyleScreenState();
}

class _AlzheimerLifestyleScreenState extends State<AlzheimerLifestyleScreen> {
  bool _smoking = false;
  double _alcohol = 0;
  double _activity = 5;
  double _diet = 5;
  double _sleep = 5;

  void _next() {
    widget.data.addAll({
      'Smoking': _smoking ? 1 : 0,
      'AlcoholConsumption': _alcohol,
      'PhysicalActivity': _activity,
      'DietQuality': _diet,
      'SleepQuality': _sleep,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AlzheimerCognitiveScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 4,
            title: 'Lifestyle',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _buildSwitch('Smoking', _smoking,
                      (v) => setState(() => _smoking = v)),
                  SizedBox(height: 16.h),
                  _buildSlider('Alcohol Consumption', _alcohol, 20,
                      (v) => setState(() => _alcohol = v)),
                  _buildSlider('Physical Activity (hrs/week)', _activity, 10,
                      (v) => setState(() => _activity = v)),
                  _buildSlider('Diet Quality', _diet, 10,
                      (v) => setState(() => _diet = v)),
                  _buildSlider('Sleep Quality (hrs)', _sleep, 10,
                      (v) => setState(() => _sleep = v)),
                  SizedBox(height: 32.h),
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black)),
        subtitle: Text('Does the patient smoke?',
            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }

  Widget _buildSlider(
      String label, double current, double max, ValueChanged<double> onChange) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black)),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  current.toStringAsFixed(0),
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: current,
            min: 0,
            max: max,
            divisions: max.toInt(),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withValues(alpha: 0.2),
            onChanged: onChange,
          ),
        ],
      ),
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
