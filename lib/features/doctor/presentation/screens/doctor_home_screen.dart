// ─────────────────────────────────────────────
//  doctor_home_screen.dart  –  Memomate
//  Main shell for the doctor's section.
//  Hosts bottom nav: Patients | Requests | Profile
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/presentation/screens/doctor_profile_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/patients_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/requests_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  final DoctorProfile doctor;
  final String token;

  const DoctorHomeScreen({
    super.key,
    required this.doctor,
    required this.token,
  });

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PatientsScreen(doctor: widget.doctor, token: widget.token),
      RequestsScreen(doctor: widget.doctor, token: widget.token),
      DoctorProfileScreen(doctor: widget.doctor, token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        elevation: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 26.sp),
            activeIcon: Icon(Icons.people, size: 26.sp),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline, size: 26.sp),
            activeIcon: Icon(Icons.mail, size: 26.sp),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 26.sp),
            activeIcon: Icon(Icons.person, size: 26.sp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
