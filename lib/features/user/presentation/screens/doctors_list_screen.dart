// ─────────────────────────────────────────────────────────────────────────────
//  doctors_list_screen.dart  –  Memomate
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/logic/doctors_list_cubit.dart';

class DoctorsListTabContent extends StatefulWidget {
  final String userId;
  final String token;
  final bool isAcceptedOnly;

  const DoctorsListTabContent({
    super.key,
    required this.userId,
    required this.token,
    required this.isAcceptedOnly,
  });

  @override
  State<DoctorsListTabContent> createState() => _DoctorsListTabContentState();
}

class _DoctorsListTabContentState extends State<DoctorsListTabContent> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorsListCubit, DoctorsListState>(
      listener: (context, state) {
        if (state is DoctorRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request sent successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          final cubit = context.read<DoctorsListCubit>();
          cubit.fetchDoctors(widget.token);
          cubit.fetchMyDoctors(widget.token);
        } else if (state is DoctorRequestFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            color: AppColors.background,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child:
                        Icon(Icons.search, color: AppColors.black, size: 24.r),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search a doctor',
                        hintStyle: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 4.h),
                      ),
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp, color: AppColors.black),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!widget.isAcceptedOnly) {
      return _FindDoctorsGrid(
        userId: widget.userId,
        token: widget.token,
        searchQuery: _searchCtrl.text.toLowerCase(),
      );
    }
    return _MyDoctorsList(
      userId: widget.userId,
      token: widget.token,
      searchQuery: _searchCtrl.text.toLowerCase(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Find Doctors tab – grid, excludes already-accepted doctors
// ─────────────────────────────────────────────────────────────────────────────

class _FindDoctorsGrid extends StatelessWidget {
  final String userId;
  final String token;
  final String searchQuery;

  const _FindDoctorsGrid({
    required this.userId,
    required this.token,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsListCubit, DoctorsListState>(
      buildWhen: (_, current) =>
          current is DoctorsListInitial ||
          current is DoctorsListLoading ||
          current is DoctorsListSuccess ||
          current is DoctorsListFailure,
      builder: (context, state) {
        if (state is DoctorsListInitial || state is DoctorsListLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is DoctorsListFailure) {
          return Center(
              child: Text(state.message,
                  style: GoogleFonts.poppins(color: AppColors.error)));
        }

        final cubit = context.read<DoctorsListCubit>();
        // Exclude doctors that are already accepted
        final doctors = cubit.allDoctors
            .where((d) =>
                !cubit.myDoctorIds.contains(d.id) &&
                d.name.toLowerCase().contains(searchQuery))
            .toList();

        if (doctors.isEmpty) {
          return Center(
              child: Text('No doctors found',
                  style: GoogleFonts.poppins(color: AppColors.grey)));
        }

        return GridView.builder(
          padding:
              EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w, top: 4.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.8,
          ),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final isPending = doctor.requests.contains(userId);
            return _FindDoctorCard(
              name: doctor.name,
              image: doctor.image,
              isPending: isPending,
              onTap: () => Navigator.pushNamed(context, '/doctorDetailsScreen',
                  arguments: doctor),
              onRequest: () =>
                  cubit.requestDoctor(doctor.id, token),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  My Doctors tab – premium list with chat icon
// ─────────────────────────────────────────────────────────────────────────────

class _MyDoctorsList extends StatelessWidget {
  final String userId;
  final String token;
  final String searchQuery;

  const _MyDoctorsList({
    required this.userId,
    required this.token,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsListCubit, DoctorsListState>(
      buildWhen: (_, current) =>
          current is MyDoctorsLoading ||
          current is MyDoctorsSuccess ||
          current is MyDoctorsFailure,
      builder: (context, myState) {
        if (myState is MyDoctorsLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (myState is MyDoctorsFailure) {
          return Center(
              child: Text(myState.message,
                  style: GoogleFonts.poppins(color: AppColors.error)));
        }

        return BlocBuilder<DoctorsListCubit, DoctorsListState>(
          buildWhen: (_, current) =>
              current is DoctorsListInitial ||
              current is DoctorsListLoading ||
              current is DoctorsListSuccess ||
              current is DoctorsListFailure,
          builder: (context, listState) {
            if (listState is DoctorsListInitial ||
                listState is DoctorsListLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (listState is DoctorsListFailure) {
              return Center(
                  child: Text(listState.message,
                      style: GoogleFonts.poppins(color: AppColors.error)));
            }

            final cubit = context.read<DoctorsListCubit>();
            final myDoctors = cubit.allDoctors
                .where((d) =>
                    cubit.myDoctorIds.contains(d.id) &&
                    d.name.toLowerCase().contains(searchQuery))
                .toList();

            if (myDoctors.isEmpty) {
              return Center(
                  child: Text('You have no accepted doctors yet',
                      style: GoogleFonts.poppins(color: AppColors.grey)));
            }

            return ListView.separated(
              padding:
                  EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 16.h),
              itemCount: myDoctors.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final doctor = myDoctors[index];
                return _MyDoctorCard(
                  name: doctor.name,
                  image: doctor.image,
                  specialization: doctor.specialization,
                  onTap: () => Navigator.pushNamed(
                      context, '/doctorDetailsScreen',
                      arguments: doctor),
                  onChat: () {
                    // TODO: navigate to chat screen
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Find Doctors card  (grid style – unchanged aesthetic)
// ─────────────────────────────────────────────────────────────────────────────

class _FindDoctorCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback onRequest;

  const _FindDoctorCard({
    required this.name,
    required this.image,
    required this.isPending,
    required this.onTap,
    required this.onRequest,
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.background,
                backgroundImage:
                    image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? Icon(Icons.person, size: 40.r, color: AppColors.primary)
                    : null,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            // ── Request button ───────────────────────────────
            BlocBuilder<DoctorsListCubit, DoctorsListState>(
              buildWhen: (_, current) =>
                  current is DoctorRequestLoading ||
                  current is DoctorRequestSuccess ||
                  current is DoctorRequestFailure,
              builder: (context, state) {
                final isLoading = state is DoctorRequestLoading;
                final showPending = isPending || isLoading;

                return GestureDetector(
                  onTap: showPending ? null : onRequest,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    decoration: BoxDecoration(
                      color: showPending
                          ? Colors.orange
                          : AppColors.primary.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    alignment: Alignment.center,
                    child: isLoading && !isPending
                        ? SizedBox(
                            height: 16.r,
                            width: 16.r,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            showPending ? 'Pending' : 'Request',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  My Doctor card  (list style – premium horizontal card with chat icon)
// ─────────────────────────────────────────────────────────────────────────────

class _MyDoctorCard extends StatelessWidget {
  final String name;
  final String image;
  final String specialization;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const _MyDoctorCard({
    required this.name,
    required this.image,
    required this.specialization,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.background,
                backgroundImage:
                    image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty
                    ? Icon(Icons.person, size: 30.r, color: AppColors.primary)
                    : null,
              ),
            ),
            SizedBox(width: 14.w),

            // ── Info ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.startsWith('Dr.') ? name : 'Dr. $name',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  if (specialization.isNotEmpty)
                    Text(
                      specialization,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.primary.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 6.h),
                  // ── Accepted badge ─────────────────────────
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 12.r, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                          'Your Doctor',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Chat icon button ──────────────────────────────
            GestureDetector(
              onTap: onChat,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.9),
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
