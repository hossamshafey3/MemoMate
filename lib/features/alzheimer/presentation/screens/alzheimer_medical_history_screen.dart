import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'alzheimer_lifestyle_screen.dart';
import 'alzheimer_wizard_progress.dart';

class AlzheimerMedicalHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const AlzheimerMedicalHistoryScreen({super.key, required this.data});

  @override
  State<AlzheimerMedicalHistoryScreen> createState() =>
      _AlzheimerMedicalHistoryScreenState();
}

class _AlzheimerMedicalHistoryScreenState
    extends State<AlzheimerMedicalHistoryScreen> {
  bool _family = false;
  bool _heart = false;
  bool _diabetes = false;
  bool _depress = false;
  bool _head = false;

  void _next() {
    widget.data.addAll({
      'FamilyHistoryAlzheimers': _family ? 1 : 0,
      'CardiovascularDisease': _heart ? 1 : 0,
      'Diabetes': _diabetes ? 1 : 0,
      'Depression': _depress ? 1 : 0,
      'HeadInjury': _head ? 1 : 0,
    });
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AlzheimerLifestyleScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 3,
            title: 'Medical History',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                SizedBox(height: 8.h),
                _buildSwitch("Family History of Alzheimer's", _family,
                    (v) => setState(() => _family = v)),
                _buildSwitch('Cardiovascular Disease', _heart,
                    (v) => setState(() => _heart = v)),
                _buildSwitch(
                    'Diabetes', _diabetes, (v) => setState(() => _diabetes = v)),
                _buildSwitch(
                    'Depression', _depress, (v) => setState(() => _depress = v)),
                _buildSwitch('Head Injury', _head,
                    (v) => setState(() => _head = v)),
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

  Widget _buildSwitch(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
