import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';

import '../../data/models/multiple_stimuli_model.dart';
import '../../logic/multiple_stimuli_cubit.dart';
import '../../logic/multiple_stimuli_state.dart';

class MultipleStimuliScreen extends StatelessWidget {
  const MultipleStimuliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultipleStimuliCubit()..startGame(),
      child: const MultipleStimuliView(),
    );
  }
}

class MultipleStimuliView extends StatelessWidget {
  const MultipleStimuliView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Calming light purple
      body: SafeArea(
        child: BlocConsumer<MultipleStimuliCubit, MultipleStimuliState>(
          listener: (context, state) {
            if (state is MultipleStimuliSuccess) {
              _showSuccessDialog(context, state.level);
            } else if (state is MultipleStimuliFailure) {
              _showFailureDialog(context, state.level, state.score);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _Header(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildTopInfo(state),
                        const SizedBox(height: 24),
                        Expanded(child: _buildPlayArea(context, state)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopInfo(MultipleStimuliState state) {
    if (state is MultipleStimuliInstructions) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Level ${state.level}",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Find and tap ONLY these:",
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: state.targets.map((t) => _buildTargetBadge(t)).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Starting soon...",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    } else if (state is MultipleStimuliPlaying) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Time remaining
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Time",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${state.timeRemaining}s",
                  style: GoogleFonts.robotoMono(
                    color: state.timeRemaining <= 5
                        ? Colors.red
                        : AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Targets
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: state.targets
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            t.shape.icon,
                            color: t.color.color,
                            size: 28,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Found",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${state.targetsFound}/${state.totalTargets}",
                  style: GoogleFonts.robotoMono(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTargetBadge(TargetDefinition target) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: target.color.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: target.color.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(target.shape.icon, color: target.color.color, size: 28),
          const SizedBox(width: 8),
          Text(
            target.color.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: target.color.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayArea(BuildContext context, MultipleStimuliState state) {
    if (state is MultipleStimuliPlaying) {
      int crossAxisCount = state.items.length <= 16 ? 4 : 5;
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _StimulusCard(
            item: item,
            onTap: () {
              context.read<MultipleStimuliCubit>().onStimulusTapped(item.id);
            },
          );
        },
      );
    } else if (state is MultipleStimuliInstructions) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return const SizedBox.shrink();
  }

  void _showSuccessDialog(BuildContext context, int level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Level $level Cleared!',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        content: Text(
          'Great observation skills!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<MultipleStimuliCubit>().nextLevel();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Next Level',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(BuildContext context, int level, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Time\'s Up!',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        content: Text(
          'You reached Level $level.\nFinal Score: $score\nKeep practicing!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<MultipleStimuliCubit>().restartGame();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Play Again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StimulusCard extends StatelessWidget {
  final StimulusItem item;
  final VoidCallback onTap;

  const _StimulusCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.white;
    Color borderColor = Colors.transparent;

    if (item.isTapped && !item.isWrongTap) {
      cardColor = const Color(0xFFE8F5E9); // Soft green success
      borderColor = const Color(0xFF4CAF50);
    } else if (item.isWrongTap) {
      cardColor = const Color(0xFFFFEBEE); // Soft red fail
      borderColor = const Color(0xFFE53935);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: item.isTapped ? 3 : 0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(item.shape.icon, color: item.color.color, size: 40),
            if (item.isTapped && !item.isWrongTap)
              const Positioned(
                right: 4,
                bottom: 4,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 16,
                ),
              ),
            if (item.isWrongTap)
              const Positioned(
                right: 4,
                bottom: 4,
                child: Icon(Icons.cancel, color: Color(0xFFE53935), size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              'Multiple Stimuli',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
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
