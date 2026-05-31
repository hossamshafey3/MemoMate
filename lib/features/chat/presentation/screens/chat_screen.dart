// ─────────────────────────────────────────────
//  chat_screen.dart  –  Memomate
//  A premium, beautifully styled real-time chat interface
//  connecting Doctors and Caregivers.
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/chat/data/models/chat_message_model.dart';
import 'package:gradproj/features/chat/logic/chat_cubit.dart';
import 'package:gradproj/features/chat/logic/chat_state.dart';
import 'package:gradproj/features/chat/data/repositories/chat_service.dart';
import 'package:intl/intl.dart';
import 'package:gradproj/features/user/presentation/screens/doctor_details_screen.dart';
import 'package:gradproj/features/doctor/presentation/screens/patient_details_screen.dart';
import 'package:gradproj/features/doctor/data/models/doctor_model.dart';
import 'package:gradproj/features/doctor/data/models/patient_model.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ChatScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _DoctorPulseDot extends StatefulWidget {
  final bool isConnected;
  const _DoctorPulseDot({required this.isConnected});

  @override
  State<_DoctorPulseDot> createState() => _DoctorPulseDotState();
}

class _DoctorPulseDotState extends State<_DoctorPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isConnected) {
      return Container(
        width: 8.w,
        height: 8.h,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      );
    }

    return FadeTransition(
      opacity: _animCtrl,
      child: Container(
        width: 8.w,
        height: 8.h,
        decoration: const BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;
  late final String receiverId;
  late final String receiverName;
  late final String? receiverImage;
  late final String receiverSpecialization;
  late final String doctorId;
  late final String patientId;
  late final String senderRole; // 'doctor' or 'patient'
  late final DoctorProfile? doctorModel;
  late final PatientModel? patientModel;

  @override
  void initState() {
    super.initState();
    
    // Extract parameters from arguments
    currentUserId = widget.arguments['currentUserId'] as String? ?? '';
    receiverId = widget.arguments['receiverId'] as String? ?? '';
    receiverName = widget.arguments['receiverName'] as String? ?? 'Consultant';
    receiverImage = widget.arguments['receiverImage'] as String?;
    receiverSpecialization = widget.arguments['receiverSpecialization'] as String? ?? 'Medical Support';
    doctorId = widget.arguments['doctorId'] as String? ?? '';
    patientId = widget.arguments['patientId'] as String? ?? '';
    senderRole = widget.arguments['senderRole'] as String? ?? 'patient';
    doctorModel = widget.arguments['doctorModel'] as DoctorProfile?;
    patientModel = widget.arguments['patientModel'] as PatientModel?;

    // Track active chat receiver ID and clear unread flag
    ChatService.activeChatReceiverId = receiverId;
    ChatService.markAsRead(receiverId);

    // Initialize ChatCubit and load messages
    context.read<ChatCubit>().initChat(
      currentUserId: currentUserId,
      receiverId: receiverId,
    );
  }

  @override
  void dispose() {
    // Clear active chat receiver ID tracking
    ChatService.activeChatReceiverId = null;
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      });
    }
  }

  void _handleSend() {
    try {
      final text = _msgController.text.trim();
      debugPrint('MemoMate Chat: _handleSend triggered. Text: "$text"');
      if (text.isEmpty) {
        debugPrint('MemoMate Chat: Text is empty, returning.');
        return;
      }

      debugPrint('MemoMate Chat: Params are doctorId="$doctorId", patientId="$patientId", senderRole="$senderRole"');

      context.read<ChatCubit>().sendMessageText(
        text: text,
        doctorId: doctorId,
        patientId: patientId,
        sender: senderRole,
      );

      _msgController.clear();
      _scrollToBottom();
      debugPrint('MemoMate Chat: _handleSend completed successfully.');
    } catch (e, stackTrace) {
      debugPrint('MemoMate Chat ERROR in _handleSend: $e');
      debugPrint('$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FC), // Soft lavender background
      body: SafeArea(
        child: Column(
          children: [
            // ── Premium Gradient Custom App Bar ─────────────────────
            _buildAppBar(context),

            // ── Messages List ────────────────────────────────────────
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  debugPrint('MemoMate Chat UI: BlocConsumer Builder received state: $state');
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    final messages = state.messages;
                    debugPrint('MemoMate Chat UI: ChatLoaded state with ${messages.length} messages.');

                    if (messages.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[messages.length - 1 - index];
                        final isMe = msg.sender == senderRole;
                        return _buildMessageBubble(msg, isMe);
                      },
                    );
                  }

                  if (state is ChatError) {
                    return _buildErrorState(state.errorMessage);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Input Text Bar ───────────────────────────────────────
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withRed(150), // Subtle rich blend
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          // Tappable Header to view profile details
          GestureDetector(
            onTap: () {
              if (senderRole == 'patient' && doctorModel != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(
                      doctor: doctorModel!,
                      fromChat: true,
                    ),
                  ),
                );
              } else if (senderRole == 'doctor' && patientModel != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientDetailsScreen(
                      patient: patientModel!,
                      doctor: doctorModel,
                      fromChat: true,
                    ),
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar Image with Glass Border
                Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.secondary,
                    backgroundImage: (receiverImage != null && receiverImage!.startsWith('http'))
                        ? NetworkImage(receiverImage!)
                        : null,
                    child: (receiverImage == null || !receiverImage!.startsWith('http'))
                        ? Text(
                            receiverName.isNotEmpty ? receiverName[0].toUpperCase() : 'C',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),

                // Receiver Info & Live indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          receiverName,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 6.w),
                        
                        // Pulse Dot
                        BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            bool connected = true;
                            if (state is ChatLoaded) {
                              connected = state.isSocketConnected;
                            }
                            return _DoctorPulseDot(isConnected: connected);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      receiverSpecialization,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // App Bar action button (Info/Call placeholder)
          Container(
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final formattedTime = DateFormat('hh:mm a').format(msg.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 8.h,
              bottom: 2.h,
              left: isMe ? 48.w : 0,
              right: isMe ? 0 : 48.w,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: isMe ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              formattedTime,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 72.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Messages Yet',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'Start a private secure consultation with $receiverName right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.orange,
              size: 48,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to connect to history',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message input field with custom decoration
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3F7),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _msgController,
                style: GoogleFonts.poppins(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Gradient Send Button
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _handleSend,
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withRed(150),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Secure Medical Chat',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            'All medical messages and consultations between doctors and caregivers are encrypted end-to-end to preserve your patient privacy.\n\nConnected to Local Node server on port 5001.',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
