import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/doctor/data/models/patient_model.dart';
import 'package:gradproj/features/alzheimer/presentation/screens/ai_results_screen.dart';
import 'package:gradproj/features/alzheimer/presentation/screens/analytics_dashboard_screen.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/core/services/auth_storage.dart';

class PatientDetailsScreen extends StatelessWidget {
  final PatientModel patient;
  final DoctorProfile? doctor;
  final bool isPendingRequest;
  final bool fromChat;

  const PatientDetailsScreen({
    super.key,
    required this.patient,
    this.doctor,
    this.isPendingRequest = false,
    this.fromChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patient Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF993299), // Purple tone from UI
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: patient.patientImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(patient.patientImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: patient.patientImage.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60.sp,
                        color: Colors.grey.shade600,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24.h),

            // Name
            Text(
              patient.patientName,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (patient.age > 0) ...[
              SizedBox(height: 8.h),
              Text(
                '${patient.age} Years Old',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
            SizedBox(height: 32.h),

            // General Details Card
            _buildSectionCard(
              title: 'General Information',
              children: [
                _buildDetailRow(
                  icon: Icons.personal_injury_outlined,
                  label: 'Patient ID',
                  value: patient.id.isNotEmpty
                      ? patient.id.substring(0, 8)
                      : 'N/A',
                ),
                if (patient.about.isNotEmpty) ...[
                  Divider(height: 32.h, color: Colors.grey.shade200),
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: 'About',
                    value: patient.about,
                  ),
                ],
                if (patient.weight > 0) ...[
                  Divider(height: 32.h, color: Colors.grey.shade200),
                  _buildDetailRow(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: '${patient.weight} kg',
                  ),
                ],
                if (!isPendingRequest && patient.address.isNotEmpty) ...[
                  Divider(height: 32.h, color: Colors.grey.shade200),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: patient.address,
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),

            if (!isPendingRequest) ...[
              // ── AI Diagnosis Section ──────────────────────────────────────
              _buildSectionCard(
                title: 'AI Diagnosis',
                children: [
                  _buildOptionTile(
                    context: context,
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'AI Results (History)',
                    subtitle: 'View previous prediction history',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiResultsScreen(
                            patientId: patient.id,
                            preloadedChecks: patient.checks,
                            preloadedMris: patient.mriResults,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 24.h, color: Colors.grey.shade100),
                  _buildOptionTile(
                    context: context,
                    icon: Icons.analytics_rounded,
                    title: 'Patient Report (Analytics)',
                    subtitle: 'Detailed analytics and charts over time',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnalyticsDashboardScreen(
                            patientId: patient.id,
                            preloadedChecks: patient.checks,
                            preloadedMris: patient.mriResults,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],

            // Contact & Caregiver Card
            _buildSectionCard(
              title: 'Contact & Caregiver',
              children: [
                if (!isPendingRequest && patient.patientPhone.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.phone_android,
                    label: 'Patient Phone',
                    value: patient.patientPhone,
                  ),
                  Divider(height: 32.h, color: Colors.grey.shade200),
                ],
                if (!isPendingRequest && patient.email.isNotEmpty) ...[
                  _buildDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: patient.email,
                  ),
                  Divider(height: 32.h, color: Colors.grey.shade200),
                ],
                _buildDetailRow(
                  icon: Icons.family_restroom_outlined,
                  label: 'Caregiver Name',
                  value: patient.caregiverName.isNotEmpty
                      ? patient.caregiverName
                      : 'Not specified',
                ),
                Divider(height: 32.h, color: Colors.grey.shade200),
                _buildDetailRow(
                  icon: Icons.people_outline,
                  label: 'Relationship',
                  value: patient.relationship.isNotEmpty
                      ? patient.relationship
                      : 'Not specified',
                ),
                if (!isPendingRequest && patient.caregiverPhone.isNotEmpty) ...[
                  Divider(height: 32.h, color: Colors.grey.shade200),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Caregiver Phone',
                    value: patient.caregiverPhone,
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),

            // Medical Details Card
            if (!isPendingRequest && (patient.diseaseHistory.isNotEmpty ||
                patient.allergies.isNotEmpty ||
                patient.memoryProblem.isNotEmpty))
              _buildSectionCard(
                title: 'Medical Summary',
                children: [
                  if (patient.diseaseHistory.isNotEmpty) ...[
                    _buildTagsRow(
                      icon: Icons.medical_services_outlined,
                      label: 'Disease History',
                      tags: patient.diseaseHistory,
                    ),
                  ],
                  if (patient.allergies.isNotEmpty) ...[
                    if (patient.diseaseHistory.isNotEmpty)
                      Divider(height: 32.h, color: Colors.grey.shade200),
                    _buildTagsRow(
                      icon: Icons.warning_amber_rounded,
                      label: 'Allergies',
                      tags: patient.allergies,
                    ),
                  ],
                  if (patient.memoryProblem.isNotEmpty) ...[
                    if (patient.diseaseHistory.isNotEmpty ||
                        patient.allergies.isNotEmpty)
                      Divider(height: 32.h, color: Colors.grey.shade200),
                    _buildDetailRow(
                      icon: Icons.psychology_outlined,
                      label: 'Memory Problem',
                      value: patient.memoryProblem,
                    ),
                  ],
                ],
              ),

            SizedBox(height: 40.h),

            // Start Chat Button or Pending Notice
            if (isPendingRequest)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Accept request to view diagnosis and start chat.',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (fromChat) {
                      Navigator.pop(context);
                      return;
                    }
                    final activeDoctor = doctor ?? await AuthStorage.getProfile();
                    if (activeDoctor == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error: Could not retrieve active doctor session.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    if (context.mounted) {
                      Navigator.pushNamed(
                        context,
                        '/chatScreen',
                        arguments: {
                          'currentUserId': activeDoctor.id,
                          'receiverId': patient.id,
                          'receiverName': patient.caregiverName.isNotEmpty
                              ? patient.caregiverName
                              : patient.patientName,
                          'receiverImage': patient.patientImage,
                          'receiverSpecialization':
                              'Caregiver of ${patient.patientName}',
                          'doctorId': activeDoctor.id,
                          'patientId': patient.id,
                          'senderRole': 'doctor',
                          'patientModel': patient,
                          'doctorModel': activeDoctor,
                        },
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Start Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF993299),
            ),
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow({
    required IconData icon,
    required String label,
    required List<String> tags,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
