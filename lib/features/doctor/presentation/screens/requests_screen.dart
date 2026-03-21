// ─────────────────────────────────────────────
//  requests_screen.dart  –  Memomate
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/logic/doctor_cubit.dart';

class RequestsScreen extends StatefulWidget {
  final DoctorProfile doctor;
  final String token;

  const RequestsScreen({
    super.key,
    required this.doctor,
    required this.token,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Start polling when opening this tab
    context.read<DoctorCubit>().startPolling(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "View Patient's Request",
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF993299), // Purple from design
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state is DoctorRespondSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.status == 'accepted' ? Colors.green : Colors.red,
              ),
            );
          } else if (state is DoctorRespondFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is DoctorRequestsLoading ||
            current is DoctorRequestsSuccess ||
            current is DoctorRequestsFailure,
        builder: (context, state) {
          if (state is DoctorRequestsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DoctorRequestsFailure) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: AppColors.error),
              ),
            );
          }
          if (state is DoctorRequestsSuccess) {
            final requests = state.requests;
            
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mail_outline,
                      size: 80.sp,
                      color: AppColors.secondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No requests yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: requests.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final patient = requests[index];
                return _buildRequestCard(patient);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildRequestCard(dynamic patient) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: patient.patientImage.isNotEmpty
                    ? NetworkImage(patient.patientImage)
                    : null,
                child: patient.patientImage.isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade600, size: 30.r)
                    : null,
              ),
              SizedBox(width: 16.w),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.patientName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (patient.caregiverName.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Caregiver: ${patient.caregiverName}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Buttons
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'Accept',
                  onTap: () {
                    context.read<DoctorCubit>().respondToRequest(
                          widget.token,
                          patient.id,
                          'accepted',
                        );
                  },
                  isFilled: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildButton(
                  text: 'Decline',
                  onTap: () {
                    context.read<DoctorCubit>().respondToRequest(
                          widget.token,
                          patient.id,
                          'declined',
                        );
                  },
                  isFilled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required bool isFilled,
  }) {
    final color = const Color(0xFFC899C8); // Soft purple from design

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFilled ? color : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: isFilled ? null : Border.all(color: color, width: 1.5),
        ),
        child: Text(
          text,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isFilled ? Colors.white : const Color(0xFF6B1B54), // Darker purple text for outline
          ),
        ),
      ),
    );
  }
}
