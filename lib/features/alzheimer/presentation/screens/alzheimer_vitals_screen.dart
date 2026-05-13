import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'alzheimer_medical_history_screen.dart';
import 'alzheimer_wizard_progress.dart';

class AlzheimerVitalsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const AlzheimerVitalsScreen({super.key, required this.data});

  @override
  State<AlzheimerVitalsScreen> createState() => _AlzheimerVitalsScreenState();
}

class _AlzheimerVitalsScreenState extends State<AlzheimerVitalsScreen> {
  final Map<String, TextEditingController> _ctrls = {
    'BMI': TextEditingController(),
    'SystolicBP': TextEditingController(),
    'DiastolicBP': TextEditingController(),
    'CholesterolTotal': TextEditingController(),
    'CholesterolLDL': TextEditingController(),
    'CholesterolHDL': TextEditingController(),
    'CholesterolTriglycerides': TextEditingController(),
  };

  final Map<String, String> _hints = {
    'BMI': '18.5 – 40',
    'SystolicBP': '90 – 180 mmHg',
    'DiastolicBP': '60 – 120 mmHg',
    'CholesterolTotal': '100 – 300 mg/dL',
    'CholesterolLDL': '50 – 200 mg/dL',
    'CholesterolHDL': '20 – 100 mg/dL',
    'CholesterolTriglycerides': '50 – 500 mg/dL',
  };

  bool _hypertension = false;

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    for (final e in _ctrls.entries) {
      widget.data[e.key] = double.tryParse(e.value.text) ?? 0.0;
    }
    widget.data['Hypertension'] = _hypertension ? 1 : 0;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AlzheimerMedicalHistoryScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 2,
            title: 'Vitals & Labs',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                SizedBox(height: 8.h),
                ..._ctrls.entries
                    .map((e) => _buildField(e.key, e.value, _hints[e.key]!)),
                SizedBox(height: 8.h),
                _buildSwitch('Hypertension', _hypertension,
                    (v) => setState(() => _hypertension = v)),
                SizedBox(height: 32.h),
                _NextButton(onTap: _next),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController ctrl, String hint) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.poppins(
            fontSize: 14.sp, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: 12.sp, color: Colors.grey.shade400),
          labelStyle:
              GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.primary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(14.r),
          ),
          filled: true,
          fillColor: AppColors.primary.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  Widget _buildSwitch(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
