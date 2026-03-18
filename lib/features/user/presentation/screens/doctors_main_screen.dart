// ─────────────────────────────────────────────────────────────────────────────
//  doctors_main_screen.dart  –  Memomate
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/logic/doctors_list_cubit.dart';
import 'package:gradproj/features/user/presentation/screens/doctors_list_screen.dart';

class DoctorsMainScreen extends StatefulWidget {
  final String token;
  final String userId;

  const DoctorsMainScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<DoctorsMainScreen> createState() => _DoctorsMainScreenState();
}

class _DoctorsMainScreenState extends State<DoctorsMainScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all doctors for the "Find Doctors" tab
    context.read<DoctorsListCubit>().fetchDoctors(widget.token);
    // Fetch this patient's accepted doctor IDs for the "My Doctors" tab
    context.read<DoctorsListCubit>().fetchMyDoctors(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ── Header & TabBar ──────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: 24.h + MediaQuery.paddingOf(context).top,
              left: 16.w,
              right: 16.w,
            ),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctors',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.primary,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                    tabs: const [
                      Tab(text: "My Doctors"),
                      Tab(text: "Find Doctors"),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // ── Tab Views ────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                DoctorsListTabContent(
                  userId: widget.userId,
                  token: widget.token,
                  isAcceptedOnly: true,
                ),
                DoctorsListTabContent(
                  userId: widget.userId,
                  token: widget.token,
                  isAcceptedOnly: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
