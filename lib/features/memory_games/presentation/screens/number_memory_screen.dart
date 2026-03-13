// ─────────────────────────────────────────────────────────────────────────────
//  number_memory_screen.dart  –  Memomate  (Memory Games logic in patient)
//  Number Memory game screen for dementia patients.
//  Inspired by: https://humanbenchmark.com/tests/number-memory
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/memory_games/logic/number_memory_cubit.dart';
import 'package:gradproj/features/memory_games/logic/number_memory_state.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────
class NumberMemoryScreen extends StatelessWidget {
  const NumberMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NumberMemoryCubit(),
      child: const _NumberMemoryView(),
    );
  }
}

// ─── Root scaffold ────────────────────────────────────────────────────────────
class _NumberMemoryView extends StatelessWidget {
  const _NumberMemoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: BlocBuilder<NumberMemoryCubit, NumberMemoryState>(
          builder: (context, state) {
            if (state is NumberMemoryInitial) {
              return _StartPage(
                onStart: () => context.read<NumberMemoryCubit>().startGame(),
              );
            }
            if (state is NumberMemoryShowing) {
              return _ShowingPage(state: state);
            }
            if (state is NumberMemoryAnswering) {
              return _AnsweringPage(state: state);
            }
            if (state is NumberMemoryResult) {
              return _ResultPage(state: state);
            }
            if (state is NumberMemoryGameOver) {
              return _GameOverPage(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  1) START PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _StartPage extends StatelessWidget {
  final VoidCallback onStart;
  const _StartPage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(onBack: () => Navigator.pop(context)),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero icon
                  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pin_outlined,
                      size: 52.r,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Number Memory',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'A number will appear on screen.\nMemorize it, then type it back.\nEach level adds one more digit!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // How-to steps
                  _HowToStep(step: '1', text: 'Look at the number carefully'),
                  SizedBox(height: 8.h),
                  _HowToStep(step: '2', text: 'Wait for the timer to run out'),
                  SizedBox(height: 8.h),
                  _HowToStep(step: '3', text: 'Type the number from memory'),
                  SizedBox(height: 36.h),
                  ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Start Game',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HowToStep extends StatelessWidget {
  final String step;
  final String text;
  const _HowToStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2) SHOWING PAGE - display the number with countdown progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _ShowingPage extends StatelessWidget {
  final NumberMemoryShowing state;
  const _ShowingPage({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(onBack: () => Navigator.pop(context)),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level badge
                  _LevelBadge(level: state.level),
                  SizedBox(height: 32.h),

                  // Instruction
                  Text(
                    'Memorize this number',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // The number display card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 32.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        state.number,
                        style: GoogleFonts.robotoMono(
                          fontSize: 56.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Countdown bar
                  Text(
                    'Disappears soon…',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 10.h,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        state.progress > 0.4
                            ? AppColors.primary
                            : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3) ANSWERING PAGE - player types the number
// ─────────────────────────────────────────────────────────────────────────────
class _AnsweringPage extends StatefulWidget {
  final NumberMemoryAnswering state;
  const _AnsweringPage({required this.state});

  @override
  State<_AnsweringPage> createState() => _AnsweringPageState();
}

class _AnsweringPageState extends State<_AnsweringPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    context.read<NumberMemoryCubit>().submitAnswer(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(onBack: () => Navigator.pop(context)),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LevelBadge(level: widget.state.level),
                  SizedBox(height: 32.h),
                  Text(
                    'What was the number?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Type the number you just saw',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 6,
                      ),
                      decoration: InputDecoration(
                        hintText: '_ _ _',
                        hintStyle: GoogleFonts.robotoMono(
                          fontSize: 36.sp,
                          color: Colors.grey[300],
                          letterSpacing: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 16.w,
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  4) RESULT PAGE - correct / wrong flash for 2 seconds
// ─────────────────────────────────────────────────────────────────────────────
class _ResultPage extends StatelessWidget {
  final NumberMemoryResult state;
  const _ResultPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final correct = state.isCorrect;
    final color = correct ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bgColor = correct ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final icon = correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final message = correct ? '✅ Correct!' : '❌ Wrong!';

    return Column(
      children: [
        _Header(onBack: () => Navigator.pop(context)),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Result icon
                  Container(
                    width: 90.r,
                    height: 90.r,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 52.r, color: color),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    message,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Comparison card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _CompareRow(
                          label: 'Correct answer',
                          value: state.correctNumber,
                          valueColor: const Color(0xFF2E7D32),
                        ),
                        if (!correct) ...[
                          Divider(height: 20.h, color: Colors.grey[200]),
                          _CompareRow(
                            label: 'Your answer',
                            value: state.playerAnswer.isEmpty
                                ? '(empty)'
                                : state.playerAnswer,
                            valueColor: const Color(0xFFC62828),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (correct)
                    Text(
                      'Level ${state.level + 1} coming up…',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    )
                  else
                    Text(
                      'Game over…',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _CompareRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  5) GAME OVER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _GameOverPage extends StatelessWidget {
  final NumberMemoryGameOver state;
  const _GameOverPage({required this.state});

  String _getRating(int level) {
    if (level >= 10) return '🧠 Genius!';
    if (level >= 7) return '⭐ Excellent!';
    if (level >= 5) return '👍 Good job!';
    if (level >= 3) return '😊 Keep practicing!';
    return '💪 Keep going!';
  }

  @override
  Widget build(BuildContext context) {
    final rating = _getRating(state.finalLevel);
    return Column(
      children: [
        _Header(onBack: () => Navigator.pop(context)),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy
                  Container(
                    width: 110.r,
                    height: 110.r,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 58.r,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Game Over!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    rating,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Score card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Level Reached',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.finalLevel}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 64.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${state.finalLevel}-digit number',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Try again
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<NumberMemoryCubit>().restartGame(),
                    icon: Icon(Icons.replay_rounded, size: 20.r),
                    label: Text(
                      'Try Again',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 54.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 4,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Games',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.r,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              'Number Memory',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 16.r,
            color: AppColors.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            'Level  $level  ·  $level digit${level == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

