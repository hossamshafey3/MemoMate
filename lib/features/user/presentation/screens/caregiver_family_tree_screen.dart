// ─────────────────────────────────────────────────────────────────────────────
//  caregiver_family_tree_screen.dart  –  Memomate
//  Caregiver can view, add, and delete family members for the patient.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/data/models/family_member_model.dart';
import 'package:gradproj/features/user/logic/family_tree_cubit.dart';
import 'package:gradproj/features/user/logic/family_tree_state.dart';

class CaregiverFamilyTreeScreen extends StatefulWidget {
  final String token;
  const CaregiverFamilyTreeScreen({super.key, required this.token});

  @override
  State<CaregiverFamilyTreeScreen> createState() =>
      _CaregiverFamilyTreeScreenState();
}

class _CaregiverFamilyTreeScreenState
    extends State<CaregiverFamilyTreeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FamilyTreeCubit>().fetchFamilyTree(widget.token);
  }

  void _showAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFamilyMemberSheet(token: widget.token),
    );
  }

  void _confirmDelete(BuildContext context, FamilyMemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Remove Member',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Remove "${member.familyMemberName}" from the family tree?',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<FamilyTreeCubit>()
                  .deleteFamilyMember(widget.token, member.id);
            },
            child: Text('Remove', style: GoogleFonts.poppins(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyTreeCubit, FamilyTreeState>(
      listener: (context, state) {
        if (state is FamilyTreeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is FamilyTreeActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<FamilyTreeCubit>();
        final members = cubit.currentMembers;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // ── Header ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Family Tree',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${members.length} member${members.length == 1 ? '' : 's'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () => _showAddMemberSheet(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded,
                                  color: Colors.white, size: 18.r),
                              SizedBox(width: 6.w),
                              Text(
                                'Add',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ── Body ────────────────────────────────────────
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
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.family_restroom_rounded,
                            size: 64.r,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'No family members yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap "+ Add" to add a family member',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: AppColors.grey.withValues(alpha: 0.7),
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
                        return _FamilyMemberCard(
                          member: member,
                          isCaregiver: true,
                          onDelete: () => _confirmDelete(context, member),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Family Member Card – shared widget
// ─────────────────────────────────────────────────────────────────────────────
class _FamilyMemberCard extends StatelessWidget {
  final FamilyMemberModel member;
  final bool isCaregiver;
  final VoidCallback? onDelete;

  const _FamilyMemberCard({
    required this.member,
    this.isCaregiver = false,
    this.onDelete,
  });

  IconData _relationshipIcon(String rel) {
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

  Color _relationshipColor(String rel) {
    switch (rel.toLowerCase()) {
      case 'father':
      case 'dad':
      case 'brother':
      case 'son':
      case 'grandfather':
      case 'husband':
        return const Color(0xFF1976D2);
      case 'mother':
      case 'mom':
      case 'sister':
      case 'daughter':
      case 'grandmother':
      case 'wife':
        return const Color(0xFFC2185B);
      case 'spouse':
        return const Color(0xFFE91E63);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _relationshipColor(member.relationshipToPatient);
    final icon = _relationshipIcon(member.relationshipToPatient);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: member.familyMemberImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.network(
                        member.familyMemberImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(icon, size: 28.r, color: color),
                      ),
                    )
                  : Icon(icon, size: 28.r, color: color),
            ),
            SizedBox(width: 14.w),

            // Name + Relationship
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.familyMemberName,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      member.relationshipToPatient,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete button (caregiver only)
            if (isCaregiver && onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error.withValues(alpha: 0.7),
                  size: 22.r,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Add Family Member Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AddFamilyMemberSheet extends StatefulWidget {
  final String token;
  const _AddFamilyMemberSheet({required this.token});

  @override
  State<_AddFamilyMemberSheet> createState() => _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends State<_AddFamilyMemberSheet> {
  final _nameCtrl = TextEditingController();
  String? _selectedRelationship;

  static const _relationships = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Son',
    'Daughter',
    'Husband',
    'Wife',
    'Grandfather',
    'Grandmother',
    'Uncle',
    'Aunt',
    'Cousin',
    'Friend',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a name and select a relationship',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<FamilyTreeCubit>().addFamilyMember(
          widget.token,
          _nameCtrl.text.trim(),
          _selectedRelationship!.toLowerCase(),
        );
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
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Add Family Member',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Add someone to the patient\'s family tree',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),

            // Name field
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.poppins(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 13.sp,
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Relationship dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedRelationship,
              decoration: InputDecoration(
                hintText: 'Relationship',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 13.sp,
                ),
                prefixIcon: Icon(
                  Icons.family_restroom_rounded,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.h,
                  horizontal: 12.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.black,
              ),
              items: _relationships
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedRelationship = v),
            ),
            SizedBox(height: 28.h),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.white),
                label: Text(
                  'Add Member',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
