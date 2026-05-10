import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import '../../logic/path_finder_cubit.dart';
import '../../logic/path_finder_state.dart';
import '../../data/models/path_finder_model.dart';
import '../widgets/path_node_widget.dart';

class PathFinderGameScreen extends StatelessWidget {
  const PathFinderGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PathFinderCubit()..startGame(),
      child: const PathFinderView(),
    );
  }
}

class PathFinderView extends StatelessWidget {
  const PathFinderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Matching number_memory_screen
      body: SafeArea(
        child: BlocConsumer<PathFinderCubit, PathFinderState>(
          listener: (context, state) {
            if (state is PathFinderSuccess) {
              _showSuccessDialog(context, state.level);
            } else if (state is PathFinderFailure) {
              _showFailureDialog(context);
            }
          },
          builder: (context, state) {
            int gridSize = 4;
            if (state is PathFinderShowingPath) {
              gridSize = state.gridSize;
            } else if (state is PathFinderPlaying) {
              gridSize = state.gridSize;
            }

            return Column(
              children: [
                _Header(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderInfo(state),
                          const SizedBox(height: 32),
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: gridSize,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: gridSize * gridSize,
                                itemBuilder: (context, index) {
                                  final int x = index % gridSize;
                                  final int y = index ~/ gridSize;
                                  final node = PathNode(x, y);

                                  return PathNodeWidget(
                                    node: node,
                                    gameState: state,
                                    onTap: () {
                                      context
                                          .read<PathFinderCubit>()
                                          .onNodeSelected(node);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
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

  Widget _buildHeaderInfo(PathFinderState state) {
    String message = "Memorize the Path!";
    Color titleColor = AppColors.primary;

    if (state is PathFinderShowingPath) {
      message = "Memorize! Starts in: ${state.timerTick}";
    } else if (state is PathFinderPlaying) {
      message = "Tap the numbers in order! (1, 2, 3...)";
    } else if (state is PathFinderSuccess) {
      message = "Great Job!";
    } else if (state is PathFinderFailure) {
      message = "Oops! Wrong path.";
      titleColor = const Color(0xFFE53935);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        key: ValueKey<String>(message),
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, int currentLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Level Cleared!',
            style: GoogleFonts.playfairDisplay(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        content: Text(
          'Excellent! You memorized the path perfectly.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<PathFinderCubit>().nextLevel();
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

  void _showFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Wrong Path',
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        content: Text(
          'You tapped the wrong sequence. Don\'t worry, you can try again!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<PathFinderCubit>().resetGame();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Try Again',
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
              'Spatial Path',
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
