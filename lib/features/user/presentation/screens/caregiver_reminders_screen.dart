import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/reminder_model.dart';
import 'package:gradproj/features/user/logic/medicines_cubit.dart';
import 'package:gradproj/features/user/logic/medicines_state.dart';

class CaregiverRemindersScreen extends StatefulWidget {
  final String token;
  const CaregiverRemindersScreen({super.key, required this.token});

  @override
  State<CaregiverRemindersScreen> createState() =>
      _CaregiverRemindersScreenState();
}

class _CaregiverRemindersScreenState extends State<CaregiverRemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial medicines
    context.read<MedicinesCubit>().fetchMedicines(widget.token);
  }

  void _showAddMedicineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedicineBottomSheet(token: widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicinesCubit, MedicinesState>(
      listener: (context, state) {
        if (state is MedicineActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is MedicineActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<MedicinesCubit>();
        final medicines = cubit.currentMedicines;

        return SafeArea(
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
                      'Medicines',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary),
                      iconSize: 32.r,
                      onPressed: () => _showAddMedicineSheet(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              if (state is MedicinesLoading && medicines.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (medicines.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_information_outlined,
                          size: 72.r,
                          color: AppColors.secondary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No medicines added',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
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
                      await cubit.fetchMedicines(widget.token);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      itemCount: medicines.length,
                      itemBuilder: (context, index) {
                        final med = medicines[index];
                        return _MedicineCard(
                          medicine: med,
                          onDelete: () {
                            cubit.deleteMedicine(widget.token, med.id);
                          },
                        );
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

class _MedicineCard extends StatelessWidget {
  final ReminderModel medicine;
  final VoidCallback onDelete;

  const _MedicineCard({required this.medicine, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.medication_outlined, color: AppColors.primary),
        ),
        title: Text(
          medicine.name,
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              'Dose: ${medicine.dose}',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: AppColors.grey),
                SizedBox(width: 4.w),
                Text(
                  medicine.time,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.calendar_today_outlined, size: 14.sp, color: AppColors.grey),
                SizedBox(width: 4.w),
                Text(
                  medicine.date.split('T').first,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _AddMedicineBottomSheet extends StatefulWidget {
  final String token;
  const _AddMedicineBottomSheet({required this.token});

  @override
  State<_AddMedicineBottomSheet> createState() => _AddMedicineBottomSheetState();
}

class _AddMedicineBottomSheetState extends State<_AddMedicineBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _timesCtrl = TextEditingController(text: '1');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _timesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _doseCtrl.text.trim().isEmpty) {
      return;
    }
    final times = int.tryParse(_timesCtrl.text) ?? 1;

    // Format time strictly to "hh:mm a" in English regardless of phone language
    final dummyDate = DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute);
    final formattedTime = DateFormat('hh:mm a', 'en_US').format(dummyDate);

    // Format date to ISO
    final isoDate = _selectedDate.toIso8601String();

    final med = ReminderModel(
      id: '', // Empty for create
      name: _nameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      date: isoDate,
      time: formattedTime,
      times: times,
    );

    context.read<MedicinesCubit>().addMedicine(widget.token, med);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Medicine',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 20.h),
            _buildField('Medicine Name', _nameCtrl, Icons.medication_outlined),
            SizedBox(height: 16.h),
            _buildField('Dose (e.g. 500mg)', _doseCtrl, Icons.science_outlined),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18.r, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 18.r, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.poppins(fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildField('Times per day', _timesCtrl, Icons.repeat, keyboardType: TextInputType.number),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save Medicine',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 13.sp),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20.r),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
