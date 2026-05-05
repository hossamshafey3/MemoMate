import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'alzheimer_vitals_screen.dart';
import 'alzheimer_wizard_progress.dart';

class AlzheimerDemographicScreen extends StatefulWidget {
  const AlzheimerDemographicScreen({super.key});

  @override
  State<AlzheimerDemographicScreen> createState() =>
      _AlzheimerDemographicScreenState();
}

class _AlzheimerDemographicScreenState
    extends State<AlzheimerDemographicScreen> {
  final TextEditingController _ageController = TextEditingController();
  int _gender = 0;
  int _ethnicity = 0;
  int _educationLevel = 1;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _next() {
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 18 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid age (18–120)',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final data = <String, dynamic>{
      'Age': age,
      'Gender': _gender,
      'Ethnicity': _ethnicity,
      'EducationLevel': _educationLevel,
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlzheimerVitalsScreen(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AlzheimerWizardProgress(
            step: 1,
            title: 'Demographics',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _buildTextField(_ageController, 'Age', Icons.cake_rounded,
                      isNumeric: true),
                  SizedBox(height: 16.h),
                  _buildDropdown<int>(
                    label: 'Gender',
                    icon: Icons.wc_rounded,
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Male')),
                      DropdownMenuItem(value: 1, child: Text('Female')),
                    ],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdown<int>(
                    label: 'Ethnicity',
                    icon: Icons.people_outline_rounded,
                    value: _ethnicity,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Caucasian')),
                      DropdownMenuItem(
                          value: 1, child: Text('African American')),
                      DropdownMenuItem(value: 2, child: Text('Asian')),
                      DropdownMenuItem(value: 3, child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _ethnicity = v!),
                  ),
                  SizedBox(height: 16.h),
                  _buildDropdown<int>(
                    label: 'Education Level',
                    icon: Icons.school_rounded,
                    value: _educationLevel,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('None')),
                      DropdownMenuItem(value: 1, child: Text('High School')),
                      DropdownMenuItem(value: 2, child: Text("Bachelor's")),
                      DropdownMenuItem(
                          value: 3, child: Text('Higher Education')),
                    ],
                    onChanged: (v) => setState(() => _educationLevel = v!),
                  ),
                  SizedBox(height: 40.h),
                  _NextButton(onTap: _next),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {bool isNumeric = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontSize: 13.sp, color: AppColors.primary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20.r),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        filled: true,
        fillColor: AppColors.primary.withValues(alpha: 0.03),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.primary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20.r),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(14.r),
        ),
        filled: true,
        fillColor: AppColors.primary.withValues(alpha: 0.03),
      ),
      items: items,
      onChanged: onChanged,
      iconEnabledColor: AppColors.primary,
      dropdownColor: Colors.white,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 2,
        ),
        child: Text(
          'Next  →',
          style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
    );
  }
}
