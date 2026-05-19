// ─────────────────────────────────────────────────────────────────────────────
//  patient_home_screen.dart  –  Memomate
//  Patient home screen with bottom navigation (Profile, Reminders, Family, Games).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/services/auth_storage.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/user_models.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproj/features/user/logic/medicines_cubit.dart';
import 'package:gradproj/features/user/logic/family_tree_cubit.dart';
import 'package:gradproj/features/user/logic/family_tree_state.dart';
import 'package:gradproj/features/user/presentation/screens/patient_reminders_tab.dart';
import 'package:gradproj/core/services/location_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gradproj/core/services/notification_service.dart';
import 'package:gradproj/features/user/logic/call_cubit.dart';
import 'package:gradproj/features/user/logic/call_state.dart';

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
  StreamSubscription<String>? _notificationSubscription;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _initializeLocationTracking() async {
    // Await permission dialogs and silent update FIRST
    await LocationService.updateLocationSilently(widget.token);
    // THEN start the background tracking service safely
    FlutterBackgroundService().startService();
  }

  @override
  void initState() {
    super.initState();
    // Persist that the user last opened the patient view
    AuthStorage.saveLastRole('patient');
    // Start polling for medicines to keep local notifications synced
    context.read<MedicinesCubit>().startPolling(widget.token);
    
    // Start polling for calls
    context.read<CallCubit>().startPolling(widget.token);
    
    _pages = [
      _PatientHomeTab(profile: widget.profile, token: widget.token),
      PatientRemindersTab(token: widget.token),
      _PatientFamilyTab(token: widget.token),
      _PatientGamesTab(),
      _PatientProfileTab(
        profile: widget.profile,
        token: widget.token,
        onSwitchToCaregiver: () async {
          await AuthStorage.saveLastRole('caregiver');
          if (!mounted) return;
          try {
            await NotificationService().showExploreNotification();
          } catch (e) {
            debugPrint('⚠️ Error triggering switch notification: $e');
          }
          Navigator.pushReplacementNamed(
            context,
            '/userHomeScreen',
            arguments: {'profile': widget.profile, 'token': widget.token},
          );
        },
      ),
    ];

    // ── Check if there is a pending notification action on start ──────────────
    if (NotificationService.initialAction != null) {
      final action = NotificationService.initialAction;
      NotificationService.initialAction = null;
      if (action == 'open_games_screen') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/gamesHomeScreen');
        });
      } else if (action == 'open_call_screen') {
        _currentIndex = 0;
      }
    }

    // ── Listen for notification taps broadcast from NotificationService ──────
    _notificationSubscription =
        NotificationService.notificationActions.listen((action) {
      if (!mounted) return;
      if (action == 'open_games_screen') {
        Navigator.pushNamed(context, '/gamesHomeScreen');
        debugPrint('🧩 [PatientHomeScreen] Navigated to GamesHomeScreen via notification.');
      } else if (action == 'open_call_screen') {
        setState(() => _currentIndex = 0);
        debugPrint('📞 [PatientHomeScreen] Switched to Home tab via call notification.');
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listener: (context, state) {
        if (state is CallIncoming) {
          _showIncomingCallDialog(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
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
              label: 'Medicines',
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
              '${state.callerName} is calling you...',
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
              _makePhoneCall(widget.profile.caregiverPhone, context);
            },
            child: Text('Accept', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Patient Home Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PatientHomeTab extends StatelessWidget {
  final UserProfile profile;
  final String token;
  const _PatientHomeTab({required this.profile, required this.token});

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
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          profile.patientName,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Patient',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'How are you feeling today?',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: profile.patientImage.isNotEmpty
                        ? NetworkImage(profile.patientImage)
                        : null,
                    child: profile.patientImage.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Interactive Grid ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Menu',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await AuthStorage.saveLastRole('caregiver');
                      try {
                        await NotificationService().showExploreNotification();
                      } catch (e) {
                        debugPrint('⚠️ Error triggering switch notification: $e');
                      }
                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(
                        context,
                        '/userHomeScreen',
                        arguments: {
                          'profile': profile,
                          'token': token,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFF673AB7).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: const Color(0xFF673AB7),
                            size: 16.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Caregiver Mode',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF673AB7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
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
                  _PatientDashCard(
                    icon: Icons.notifications_active_outlined,
                    label: 'Medicines',
                    color: const Color(0xFF5C6BC0),
                    onTap: () => context
                        .findAncestorStateOfType<_PatientHomeScreenState>()
                        ?.changeTab(1),
                  ),
                  _PatientDashCard(
                    icon: Icons.family_restroom_rounded,
                    label: 'My Family',
                    color: const Color(0xFF66BB6A),
                    onTap: () => context
                        .findAncestorStateOfType<_PatientHomeScreenState>()
                        ?.changeTab(2),
                  ),
                  _PatientDashCard(
                    icon: Icons.sports_esports_rounded,
                    label: 'Games',
                    color: const Color(0xFFFFA726),
                    onTap: () => context
                        .findAncestorStateOfType<_PatientHomeScreenState>()
                        ?.changeTab(3),
                  ),
                  _PatientDashCard(
                    icon: Icons.person_outline_rounded,
                    label: 'My Profile',
                    color: const Color(0xFF26C6DA),
                    onTap: () => context
                        .findAncestorStateOfType<_PatientHomeScreenState>()
                        ?.changeTab(4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ── Call Me Card ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () => _makePhoneCall(profile.caregiverPhone, context),
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
                              'Call My Caregiver',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            Text(
                              'Tap to speak with Me',
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

class _PatientDashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PatientDashCard({
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
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32.r, color: color),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
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
                    backgroundImage: profile.patientImage.isNotEmpty
                        ? NetworkImage(profile.patientImage)
                        : null,
                    child: profile.patientImage.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 52.r,
                            color: AppColors.primary,
                          )
                        : null,
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
//  Family Tab  (patient view – read-only, user-friendly grid)
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  Family Tab  (patient view – read-only, premium list)
// ─────────────────────────────────────────────────────────────────────────────
class _PatientFamilyTab extends StatefulWidget {
  final String token;
  const _PatientFamilyTab({required this.token});

  @override
  State<_PatientFamilyTab> createState() => _PatientFamilyTabState();
}

class _PatientFamilyTabState extends State<_PatientFamilyTab> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyTreeCubit>().fetchFamilyTree(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FamilyTreeCubit, FamilyTreeState>(
      builder: (context, state) {
        final cubit = context.read<FamilyTreeCubit>();
        final members = cubit.currentMembers;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Family',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'People who care for you and love you',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              if (state is FamilyTreeLoading && members.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (members.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(32.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 64.r,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Your family circle is empty',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Your caregiver will add family members soon',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await cubit.fetchFamilyTree(widget.token);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return _PatientFamilyHorizontalCard(member: member);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Patient Family Horizontal Card (Large, Clear, Beautiful)
// ─────────────────────────────────────────────────────────────────────────────
class _PatientFamilyHorizontalCard extends StatelessWidget {
  final FamilyMemberModel member;
  const _PatientFamilyHorizontalCard({required this.member});

  IconData _icon(String rel) {
    switch (rel.toLowerCase()) {
      case 'father':
      case 'dad':
        return Icons.man_rounded;
      case 'mother':
      case 'mom':
        return Icons.woman_rounded;
      case 'brother':
        return Icons.boy_rounded;
      case 'sister':
        return Icons.girl_rounded;
      case 'son':
        return Icons.child_care_rounded;
      case 'daughter':
        return Icons.child_friendly_rounded;
      case 'wife':
      case 'husband':
      case 'spouse':
        return Icons.favorite_rounded;
      case 'grandfather':
      case 'grandmother':
        return Icons.elderly_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _color(String rel) {
    switch (rel.toLowerCase()) {
      case 'father':
      case 'dad':
      case 'brother':
      case 'son':
      case 'grandfather':
      case 'husband':
        return const Color(0xFF1E88E5);
      case 'mother':
      case 'mom':
      case 'sister':
      case 'daughter':
      case 'grandmother':
      case 'wife':
        return const Color(0xFFD81B60);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(member.relationshipToPatient);
    final icon = _icon(member.relationshipToPatient);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 110.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Soft background decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Large Avatar with Border
                  Container(
                    width: 76.r,
                    height: 76.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                        width: 3,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: member.familyMemberImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(38.r),
                              child: Image.network(
                                member.familyMemberImage,
                                width: 76.r,
                                height: 76.r,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(icon, size: 38.r, color: color),
                              ),
                            )
                          : Icon(icon, size: 38.r, color: color),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  // Info Column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.familyMemberName,
                          style: GoogleFonts.poppins(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                size: 12.r,
                                color: color.withValues(alpha: 0.8),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                member.relationshipToPatient,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: color.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Simple clean heart decoration on the side
                  Icon(
                    Icons.favorite_rounded,
                    color: color.withValues(alpha: 0.1),
                    size: 28.r,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Games Tab
// ─────────────────────────────────────────────────────────────────────────────
class _PatientGamesTab extends StatefulWidget {
  const _PatientGamesTab();

  @override
  State<_PatientGamesTab> createState() => _PatientGamesTabState();
}

class _PatientGamesTabState extends State<_PatientGamesTab> {
  bool _remindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadReminderPreference();
  }

  Future<void> _loadReminderPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('game_reminders_enabled') ?? false;
    });
  }

  Future<void> _toggleReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('game_reminders_enabled', value);
    setState(() {
      _remindersEnabled = value;
    });

    if (value) {
      await NotificationService().scheduleDailyGameReminders();
    } else {
      await NotificationService().cancelGameReminders();
    }
  }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Memory Games',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
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
            SizedBox(height: 16.h),
            
            // Reminder Toggle Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_active_outlined, 
                      size: 20.r, color: AppColors.primary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reminders',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Get notified to play games daily',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _remindersEnabled,
                    onChanged: _toggleReminders,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
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
                    icon: Icons.alt_route_rounded,
                    label: 'Spatial Path',
                    color: const Color(0xFF6C4AB6),
                    onTap: () =>
                        Navigator.pushNamed(context, '/pathFinderGameScreen'),
                  ),
                  _GameCard(
                    icon: Icons.dashboard_customize_rounded,
                    label: 'Multiple Stimuli',
                    color: const Color(0xFF8E24AA), // Purple icon theme
                    onTap: () =>
                        Navigator.pushNamed(context, '/multipleStimuliScreen'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 22.w,
                height: MediaQuery.of(context).size.width / 2 - 22.w,
                child: _GameCard(
                  icon: Icons.extension_rounded,
                  label: 'Block Puzzle',
                  color: const Color(0xFF9C27B0),
                  onTap: () => Navigator.pushNamed(context, '/blockPuzzleScreen'),
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
