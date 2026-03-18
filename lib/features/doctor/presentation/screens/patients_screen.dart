import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/logic/doctor_cubit.dart';
import 'package:gradproj/features/doctor/presentation/screens/patient_details_screen.dart';

class PatientsScreen extends StatefulWidget {
  final DoctorProfile doctor;
  final String token;

  const PatientsScreen({
    super.key,
    required this.doctor,
    required this.token,
  });

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch patients when opening this tab
    context.read<DoctorCubit>().fetchPatients(widget.token);
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
          'My Patients',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF993299), // Purple from design
          ),
        ),
      ),
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state is DoctorPatientsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is DoctorPatientsLoading ||
            current is DoctorPatientsSuccess ||
            current is DoctorPatientsFailure,
        builder: (context, state) {
          if (state is DoctorPatientsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DoctorPatientsFailure) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: AppColors.error),
              ),
            );
          }
          if (state is DoctorPatientsSuccess) {
            final patients = state.patients;
            
            if (patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80.sp,
                      color: AppColors.secondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No patients yet',
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
              itemCount: patients.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildPatientCard(patient);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 35.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: patient.patientImage.isNotEmpty
                    ? NetworkImage(patient.patientImage)
                    : null,
                child: patient.patientImage.isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade600, size: 35.r)
                    : null,
              ),
              SizedBox(width: 16.w),
              // Name & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.patientName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      patient.about.isNotEmpty
                          ? patient.about
                          : (patient.diseaseHistory.isNotEmpty
                              ? 'Suffering from ${patient.diseaseHistory.join(', ')}'
                              : 'A ${patient.age} years old patient'),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: const Color(0xFF993299),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    // View & Chat Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // View Button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PatientDetailsScreen(patient: patient),
                              ),
                            );
                          },
                          child: Container(
                            height: 36.h,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC899C8), // Soft purple
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'View',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Chat Button
                        GestureDetector(
                          onTap: () {
                            // TODO: Open chat with patient/caregiver
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chat feature coming soon!'),
                              ),
                            );
                          },
                          child: Container(
                            height: 36.h,
                            width: 36.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

