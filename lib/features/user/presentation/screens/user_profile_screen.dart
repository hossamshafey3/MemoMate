// ─────────────────────────────────────────────────────────────────────────────
//  user_profile_screen.dart  –  Memomate
//  Profile tab with a Caregiver ⟷ Patient toggle.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/core/services/notification_service.dart';
class UserProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final String token;

  const UserProfileScreen({
    super.key,
    required this.profile,
    required this.token,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _showPatient = false; // false = Caregiver, true = Patient

  @override
  Widget build(BuildContext context) {
    final displayName = _showPatient
        ? widget.profile.patientName
        : widget.profile.caregiverName;
    final roleLabel = _showPatient ? 'Patient' : 'Caregiver';

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // ── Title row with edit icon ──────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/userEditProfileScreen',
                      arguments: {
                        'profile': widget.profile,
                        'token': widget.token,
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Avatar + Name header ──────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                    backgroundImage: _showPatient &&
                            widget.profile.patientImage.isNotEmpty
                        ? NetworkImage(widget.profile.patientImage)
                        : null,
                    child: (!_showPatient ||
                            widget.profile.patientImage.isEmpty)
                        ? Icon(
                            Icons.person_rounded,
                            size: 52.r,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '${displayName.isEmpty ? '—' : displayName} ($roleLabel)',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      roleLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Caregiver / Patient toggle ──────────────────
            Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _toggleBtn('Caregiver', !_showPatient, () {
                    setState(() => _showPatient = false);
                  }),
                  _toggleBtn('Patient', _showPatient, () {
                    setState(() => _showPatient = true);
                  }),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── Content depends on toggle ───────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _showPatient
                  ? _PatientSection(profile: widget.profile)
                  : _CaregiverSection(profile: widget.profile),
            ),

            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthStorage.saveLastRole('patient');
                try {
                  await NotificationService().showExploreNotification();
                } catch (e) {
                  debugPrint('⚠️ Error triggering switch notification: $e');
                }
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  '/patientHomeScreen',
                  arguments: {
                    'profile': widget.profile,
                    'token': widget.token,
                  },
                );
              },
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
              label: Text(
                'Switch to Patient Account',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            const Divider(thickness: 1.0),
            SizedBox(height: 12.h),


            // ── Logout ───────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () async {
                await AuthStorage.clearUserSession();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/roleSelectionScreen',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Caregiver section
// ─────────────────────────────────────────────────────────────────────────────
class _CaregiverSection extends StatelessWidget {
  final UserProfile profile;
  const _CaregiverSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('caregiver'),
      children: [
        _infoCard([
          _row(Icons.person_rounded, 'Name', profile.caregiverName),
          _row(Icons.email_outlined, 'Email', profile.email),
          _row(Icons.phone_outlined, 'Phone', profile.caregiverPhone),
          _row(Icons.people_outline, 'Relationship', profile.relationship),
        ]),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Patient section
// ─────────────────────────────────────────────────────────────────────────────
class _PatientSection extends StatelessWidget {
  final UserProfile profile;
  const _PatientSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('patient'),
      children: [
        _infoCard([
          _row(Icons.person_rounded, 'Name', profile.patientName),
          _row(Icons.phone_outlined, 'Phone', profile.patientPhone),
          _row(Icons.cake_outlined, 'Age', '${profile.age} years'),
          _row(Icons.monitor_weight_outlined, 'Weight', '${profile.weight} kg'),
          _row(Icons.location_on_outlined, 'Address', profile.address),
          _row(
            Icons.psychology_outlined,
            'Memory problem',
            profile.memoryProblem,
          ),
          _row(Icons.info_outline_rounded, 'About', profile.about),
        ]),
        SizedBox(height: 12.h),
        _chipCard(
          icon: Icons.local_hospital_outlined,
          title: 'Disease History',
          items: profile.diseaseHistory,
        ),
        SizedBox(height: 12.h),
        _chipCard(
          icon: Icons.warning_amber_outlined,
          title: 'Allergies',
          items: profile.allergies,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _infoCard(List<Widget> rows) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: rows),
  );
}

Widget _row(IconData icon, String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 10.w),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: GoogleFonts.poppins(fontSize: 13.sp, color: AppColors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _chipCard({
  required IconData icon,
  required String title,
  required List<String> items,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (items.isEmpty)
          Text(
            'None',
            style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: items
                .map(
                  (e) => Chip(
                    label: Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    ),
  );
}
