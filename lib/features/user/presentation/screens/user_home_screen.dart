// ─────────────────────────────────────────────────────────────────────────────
//  user_home_screen.dart  –  Memomate
//  Caregiver home screen with bottom navigation and 4-card dashboard.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/logic/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/features/user/presentation/screens/doctors_main_screen.dart';
import 'package:gradproj/features/user/presentation/screens/user_profile_screen.dart';
import 'package:gradproj/features/user/presentation/screens/caregiver_reminders_screen.dart';
import 'package:gradproj/features/user/presentation/screens/caregiver_family_tree_screen.dart';
import 'package:gradproj/features/alzheimer/presentation/screens/alzheimer_hub_screen.dart';
import 'package:gradproj/features/alzheimer/presentation/screens/alzheimer_learn_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gradproj/features/user/logic/call_cubit.dart';
import 'package:gradproj/features/user/logic/call_state.dart';
import 'package:gradproj/features/chat/data/repositories/chat_service.dart';

Future<void> _makePhoneCall(String? phoneNumber, BuildContext context) async {
  if (phoneNumber == null || phoneNumber.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number not found for this contact'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }
  final Uri launchUri = Uri.parse('tel:${phoneNumber.trim()}');
  try {
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch the phone dialer'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error launching dialer: $e'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}


class UserHomeScreen extends StatefulWidget {
  final UserProfile profile;
  final String token;

  const UserHomeScreen({super.key, required this.profile, required this.token});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  late UserProfile _profile;

  late List<Widget> _pages;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _buildPages();
    // Persist that the user last opened the caregiver view
    AuthStorage.saveLastRole('caregiver');
    
    // Connect global socket for caregiver notifications and badges
    ChatService().connectGlobal(userId: widget.profile.id);
    
    // Start polling for calls
    context.read<CallCubit>().startPolling(widget.token);
  }

  void _buildPages() {
    _pages = [
      _HomeTab(profile: _profile, token: widget.token),
      CaregiverRemindersScreen(token: widget.token),
      CaregiverFamilyTreeScreen(token: widget.token),
      DoctorsMainScreen(token: widget.token, userId: _profile.id),
      UserProfileScreen(profile: _profile, token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserUpdateSuccess) {
              setState(() {
                _profile = state.profile;
                _buildPages();
              });
            }
          },
        ),
        BlocListener<CallCubit, CallState>(
          listener: (context, state) {
            if (state is CallIncoming) {
              _showIncomingCallDialog(context, state);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: null,
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
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              label: 'Medicine',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom_rounded),
              label: 'Family',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              label: 'Doctor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomingCallDialog(BuildContext context, CallIncoming state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Incoming Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 40.r, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Patient is calling you...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CallCubit>().endCallSignal(widget.token);
              Navigator.pop(context);
            },
            child: Text('Decline', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(_profile.patientPhone, context);
            },
            child: Text('Accept', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Home Tab
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final UserProfile profile;
  final String token;
  const _HomeTab({required this.profile, required this.token});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ───────────────────────────────
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 34.r,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome  ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: profile.caregiverName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Caregiver',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'What do you need?',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            


            // ── Grid ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.05,
                children: [
                  _DashCard(
                    icon: Icons.notifications_active_outlined,
                    label: 'Medicines',
                    onTap: () => context.findAncestorStateOfType<_UserHomeScreenState>()?.changeTab(1),
                  ),
                  _DashCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'Family Tree',
                    onTap: () => context.findAncestorStateOfType<_UserHomeScreenState>()?.changeTab(2),
                  ),
                  _DashCard(
                    icon: Icons.medical_services_outlined,
                    label: 'Doctor',
                    onTap: () => context.findAncestorStateOfType<_UserHomeScreenState>()?.changeTab(3),
                  ),
                  _DashCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/caregiverLocationScreen',
                        arguments: token,
                      );
                    },
                  ),
                   _DashCard(
                    icon: Icons.psychology_rounded,
                    label: 'AI Diagnosis',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/alzheimerHub'),
                          builder: (_) => const AlzheimerHubScreen(),
                        ),
                      );
                    },
                  ),
                  _DashCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Learn About',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlzheimerLearnScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── Call Patient Card ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () => _makePhoneCall(profile.patientPhone, context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF43A047).withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_in_talk_rounded,
                          color: const Color(0xFF43A047),
                          size: 32.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Call Patient',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            Text(
                              'Tap to speak with Patient',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                        size: 16.r,
                      ),
                    ],
                  ),
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
//  Dashboard card
// ─────────────────────────────────────────────────────────────────────────────
class _DashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashCard({required this.icon, required this.label, required this.onTap});

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
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44.r, color: AppColors.primary),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

