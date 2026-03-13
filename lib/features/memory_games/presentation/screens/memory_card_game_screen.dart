// ─────────────────────────────────────────────────────────────────────────────
//  memory_card_game_screen.dart  –  Memomate  (Memory Games logic in patient)
//  Full Memory Card matching game screen for dementia patients.
//  Inspired by: https://www.solitairebliss.com/memory
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/memory_games/data/models/memory_card_model.dart';
import 'package:gradproj/features/memory_games/logic/memory_game_cubit.dart';
import 'package:gradproj/features/memory_games/logic/memory_game_state.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────
class MemoryCardGameScreen extends StatelessWidget {
  const MemoryCardGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemoryGameCubit(),
      child: const _MemoryCardGameView(),
    );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────
class _MemoryCardGameView extends StatelessWidget {
  const _MemoryCardGameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: BlocBuilder<MemoryGameCubit, MemoryGameState>(
        builder: (context, state) {
          if (state is MemoryGameInitial) {
            return _DifficultySelectionPage(
              onStart: (pairs) =>
                  context.read<MemoryGameCubit>().startGame(pairsCount: pairs),
            );
          }
          if (state is MemoryGamePlaying) {
            return _GamePlayPage(state: state);
          }
          if (state is MemoryGameComplete) {
            return _GameCompletePage(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  1) DIFFICULTY SELECTION
// ─────────────────────────────────────────────────────────────────────────────
class _DifficultySelectionPage extends StatelessWidget {
  final void Function(int pairs) onStart;

  const _DifficultySelectionPage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero icon
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
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
                        Icons.grid_view_rounded,
                        size: 52.r,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Memory Cards',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Flip cards to find matching pairs.\nTrain your memory and have fun!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 36.h),
                    Text(
                      'Choose difficulty',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _DifficultyCard(
                      label: 'Easy',
                      subtitle: '6 pairs · 3 × 4 grid',
                      emoji: '😊',
                      color: const Color(0xFF4CAF50),
                      onTap: () => onStart(6),
                    ),
                    SizedBox(height: 12.h),
                    _DifficultyCard(
                      label: 'Medium',
                      subtitle: '8 pairs · 4 × 4 grid',
                      emoji: '🧠',
                      color: const Color(0xFF7B1FA2),
                      onTap: () => onStart(8),
                    ),
                    SizedBox(height: 12.h),
                    _DifficultyCard(
                      label: 'Hard',
                      subtitle: '10 pairs · 4 × 5 grid',
                      emoji: '🔥',
                      color: const Color(0xFFE53935),
                      onTap: () => onStart(10),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.r, color: color),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  2) GAMEPLAY
// ─────────────────────────────────────────────────────────────────────────────
class _GamePlayPage extends StatelessWidget {
  final MemoryGamePlaying state;

  const _GamePlayPage({required this.state});

  int _crossAxisCount() {
    if (state.totalPairs <= 6) return 3; // 12 cards → 3 cols
    return 4; // 16–20 cards → 4 cols
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = state.elapsed;
    final mm = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(context),

          // ── Stats bar ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.touch_app_rounded,
                  value: '${state.moves}',
                  label: 'Moves',
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  icon: Icons.timer_rounded,
                  value: '$mm:$ss',
                  label: 'Time',
                  color: const Color(0xFF1976D2),
                ),
                SizedBox(width: 8.w),
                _StatChip(
                  icon: Icons.favorite_rounded,
                  value: '${state.matchesFound}/${state.totalPairs}',
                  label: 'Pairs',
                  color: const Color(0xFFE53935),
                ),
              ],
            ),
          ),

          // ── Progress bar ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: state.matchesFound / state.totalPairs,
                minHeight: 6.h,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // ── Card grid ───────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount(),
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.82,
                ),
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  return _MemoryCardWidget(
                    card: state.cards[index],
                    onTap: state.isChecking
                        ? null
                        : () => context.read<MemoryGameCubit>().flipCard(
                            state.cards[index].id,
                          ),
                  );
                },
              ),
            ),
          ),

          // ── Restart button ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: OutlinedButton.icon(
              onPressed: () => context.read<MemoryGameCubit>().startGame(
                pairsCount: state.totalPairs,
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.r),
              label: Text(
                'Restart',
                style: GoogleFonts.poppins(fontSize: 13.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                minimumSize: Size(double.infinity, 44.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Memory Card Widget ───────────────────────────────────────────────
class _MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback? onTap;

  const _MemoryCardWidget({required this.card, this.onTap});

  @override
  State<_MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<_MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _showFront = widget.card.isFaceUp || widget.card.isMatched;
    if (_showFront) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldShow = widget.card.isFaceUp || widget.card.isMatched;
    if (shouldShow != _showFront) {
      _showFront = shouldShow;
      if (_showFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * 3.14159;
          final isFront = _flipAnimation.value >= 0.5;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isFront ? angle - 3.14159 : angle),
            alignment: Alignment.center,
            child: isFront ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          color: Colors.white54,
          size: 28.r,
        ),
      ),
    );
  }

  Widget _buildFront() {
    final isMatched = widget.card.isMatched;
    return Container(
      decoration: BoxDecoration(
        color: isMatched ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isMatched ? const Color(0xFF4CAF50) : AppColors.secondary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                : AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.card.value, style: TextStyle(fontSize: 32.sp)),
            if (isMatched) ...[
              SizedBox(height: 4.h),
              Icon(
                Icons.check_circle_rounded,
                size: 16.r,
                color: const Color(0xFF4CAF50),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Stat chip ───────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14.r, color: color),
                SizedBox(width: 4.w),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  3) GAME COMPLETE
// ─────────────────────────────────────────────────────────────────────────────
class _GameCompletePage extends StatelessWidget {
  final MemoryGameComplete state;

  const _GameCompletePage({required this.state});

  String _formatTime(Duration d) {
    final mm = (d.inMinutes % 60).toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String _getRating(int moves, Duration elapsed) {
    if (moves <= 14 && elapsed.inSeconds <= 60) return '⭐⭐⭐';
    if (moves <= 20 && elapsed.inSeconds <= 120) return '⭐⭐';
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    final rating = _getRating(state.moves, state.elapsed);
    return SafeArea(
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
                    colors: [Color(0xFFF9A825), Color(0xFFFFD54F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF9A825).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 60.r,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'You Did It! 🎉',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Amazing job matching all the cards!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 28.h),

              // Stats
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(rating, style: TextStyle(fontSize: 36.sp)),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultStat(
                          icon: Icons.touch_app_rounded,
                          value: '${state.moves}',
                          label: 'Moves',
                          color: AppColors.primary,
                        ),
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Colors.grey[200],
                        ),
                        _ResultStat(
                          icon: Icons.timer_rounded,
                          value: _formatTime(state.elapsed),
                          label: 'Time',
                          color: const Color(0xFF1976D2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              // Play again
              ElevatedButton.icon(
                onPressed: () => context.read<MemoryGameCubit>().resetGame(),
                icon: Icon(Icons.replay_rounded, size: 18.r),
                label: Text(
                  'Play Again',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
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
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22.r),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ─── Shared: Header bar with back button ─────────────────────────────────────
Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.r,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            'Memory Cards',
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
