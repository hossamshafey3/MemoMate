import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gradproj/features/user/logic/call_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioCallScreen extends StatefulWidget {
  final String remoteName;
  final String? remoteImage;
  final String role; // 'patient' or 'caregiver'
  final String channelId;
  final String? token; // Token to clear signal on end

  const AudioCallScreen({
    super.key,
    required this.remoteName,
    required this.role,
    required this.channelId,
    this.remoteImage,
    this.token,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  static const String _appId = "34df38a3ff68448d9618b47acaeab03d";
  
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 1. Request permissions
    await [Permission.microphone].request();

    // 2. Create engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // 3. Register event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          if (mounted) {
            setState(() {
              _remoteUid = remoteUid;
            });
            _startTimer();
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left");
          if (mounted) {
            setState(() {
              _remoteUid = null;
            });
            _timer?.cancel();
            _seconds = 0;
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("Local user left channel");
        },
      ),
    );

    // 4. Set audio profile
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();
    await _engine!.setEnableSpeakerphone(_isSpeakerOn);

    // 5. Join channel
    // UID 1 for Patient, UID 2 for Caregiver
    int myUid = widget.role == 'patient' ? 1 : 2;
    
    await _engine!.joinChannel(
      token: '', // Use empty string if no token required (testing)
      channelId: widget.channelId,
      uid: myUid,
      options: const ChannelMediaOptions(),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _engine?.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleSpeaker() async {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    await _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  Future<void> _endCall() async {
    if (widget.token != null) {
      context.read<CallCubit>().endCallSignal(widget.token!);
    }
    await _engine?.leaveChannel();
    await _engine?.release();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    if (widget.token != null) {
      context.read<CallCubit>().endCallSignal(widget.token!);
    }
    _timer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60.h),
            // Profile Area
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140.r,
                    height: 140.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70.r),
                      child: widget.remoteImage != null && widget.remoteImage!.isNotEmpty
                          ? Image.network(widget.remoteImage!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              child: Icon(Icons.person, size: 80.r, color: Colors.white),
                            ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    widget.remoteName,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _remoteUid != null 
                        ? 'Connected • ${_formatDuration(_seconds)}' 
                        : 'Waiting for other party...',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: _remoteUid != null ? Colors.greenAccent : AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Control Buttons
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: 'Mute',
                        isActive: _isMuted,
                        onTap: _toggleMute,
                      ),
                      _buildControlButton(
                        icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        label: 'Speaker',
                        isActive: _isSpeakerOn,
                        onTap: _toggleSpeaker,
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  // End Call Button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 70.r,
                      height: 70.r,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 15,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Icon(Icons.call_end_rounded, color: Colors.white, size: 34.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'End Call',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 12.sp,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 28.r,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white60,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
