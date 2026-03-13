// ─────────────────────────────────────────────────────────────────────────────
//  patient_home_screen.dart  –  Memomate
//  Patient home screen with bottom navigation (Profile, Reminders, Family, Games).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';

class PatientHomeScreen extends StatefulWidget {
  final UserProfile profile;
  final String token;

  const PatientHomeScreen({
    super.key,
    required this.profile,
    required this.token,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Persist that the user last opened the patient view
    AuthStorage.saveLastRole('patient');
    _pages = [
      _PatientRemindersTab(),
      _PatientFamilyTab(),
      _PatientGamesTab(),
      _PatientProfileTab(
        profile: widget.profile,
        token: widget.token,
        onSwitchToCaregiver: () async {
          await AuthStorage.saveLastRole('caregiver');
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/userHomeScreen',
            arguments: {'profile': widget.profile, 'token': widget.token},
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11.sp),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11.sp),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom_rounded),
            label: 'Family',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Patient Profile Tab (inside bottom nav)
// ─────────────────────────────────────────────────────────────────────────────
class _PatientProfileTab extends StatelessWidget {
  final UserProfile profile;
  final String token;
  final VoidCallback onSwitchToCaregiver;

  const _PatientProfileTab({
    required this.profile,
    required this.token,
    required this.onSwitchToCaregiver,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              'Profile',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 24.h),

            // Profile avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.person_rounded,
                      size: 52.r,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    profile.patientName,
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
                      'Patient',
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

            // Info card
            _infoCard([
              _row(Icons.person_rounded, 'Your Name', profile.patientName),
              _row(Icons.phone_outlined, 'Your Phone', profile.patientPhone),
              _row(Icons.email_outlined, 'Your Email', profile.email),
            ]),
            SizedBox(height: 12.h),
            _infoCard([
              _row(Icons.cake_outlined, 'Age', '${profile.age} years'),
              _row(
                Icons.monitor_weight_outlined,
                'Weight',
                '${profile.weight} kg',
              ),
              _row(Icons.location_on_outlined, 'Address', profile.address),
              _row(
                Icons.psychology_outlined,
                'Memory Problem',
                profile.memoryProblem,
              ),
            ]),

            SizedBox(height: 12.h),
            if (profile.diseaseHistory.isNotEmpty)
              _chipCard(
                icon: Icons.local_hospital_outlined,
                title: 'Disease History',
                items: profile.diseaseHistory,
              ),
            SizedBox(height: 12.h),
            if (profile.allergies.isNotEmpty)
              _chipCard(
                icon: Icons.warning_amber_outlined,
                title: 'Allergies',
                items: profile.allergies,
              ),

            SizedBox(height: 24.h),
            const Divider(thickness: 1.0),
            SizedBox(height: 24.h),

            // Switch to Caregiver
            OutlinedButton.icon(
              onPressed: onSwitchToCaregiver,
              icon: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
              ),
              label: Text(
                'Switch to Caregiver Account',
                style: GoogleFonts.poppins(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Logout
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reminders Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PatientRemindersTab extends StatelessWidget {
  const _PatientRemindersTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Reminders',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 72.r,
                    color: AppColors.secondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No reminders yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your caregiver can add reminders for you',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Family Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PatientFamilyTab extends StatelessWidget {
  const _PatientFamilyTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Family & Doctors',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom_rounded,
                    size: 72.r,
                    color: AppColors.secondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Family & Doctors',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your care team will appear here',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Games Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PatientGamesTab extends StatelessWidget {
  const _PatientGamesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Memory Games',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Train your memory with these fun activities',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.grey,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.0,
                children: [
                  _GameCard(
                    icon: Icons.grid_view_rounded,
                    label: 'Matching Game',
                    color: const Color(0xFF7B1FA2),
                    onTap: () =>
                        Navigator.pushNamed(context, '/memoryCardGameScreen'),
                  ),
                  _GameCard(
                    icon: Icons.pin_outlined,
                    label: 'Numbers Game',
                    color: const Color(0xFF6A1B9A),
                    onTap: () =>
                        Navigator.pushNamed(context, '/numberMemoryScreen'),
                  ),
                  _GameCard(
                    icon: Icons.quiz_rounded,
                    label: 'Word Quiz',
                    color: const Color(0xFF9C27B0),
                    onTap: () {},
                  ),
                  _GameCard(
                    icon: Icons.extension_rounded,
                    label: 'Puzzle',
                    color: const Color(0xFFAB47BC),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 30.r, color: color),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared helpers (scoped within this file)
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
