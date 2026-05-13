import 'package:flutter/material.dart';
import '../../data/models/path_finder_model.dart';
import '../../logic/path_finder_state.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PathNodeWidget extends StatelessWidget {
  final PathNode node;
  final PathFinderState gameState;
  final VoidCallback onTap;

  const PathNodeWidget({
    super.key,
    required this.node,
    required this.gameState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isTarget = false;
    bool isSelected = false;
    bool isWrong = false;
    int pathNumber = -1;

    if (gameState is PathFinderShowingPath) {
      final state = gameState as PathFinderShowingPath;
      final index = state.path.indexOf(node);
      if (index != -1) {
        isTarget = true;
        pathNumber = index + 1;
      }
    } else if (gameState is PathFinderPlaying) {
      final state = gameState as PathFinderPlaying;
      final index = state.userPath.indexOf(node);
      if (index != -1) {
        isSelected = true;
        pathNumber = index + 1;
      }
    } else if (gameState is PathFinderFailure) {
      final state = gameState as PathFinderFailure;
      final targetIndex = state.targetPath.indexOf(node);
      final userIndex = state.userPath.indexOf(node);

      if (userIndex != -1 &&
          userIndex == state.userPath.length - 1 &&
          targetIndex == -1) {
        isWrong = true; // User tapped outside the path
      } else if (userIndex != -1) {
        isSelected = true;
        pathNumber = userIndex + 1;
      }

      if (targetIndex != -1) {
        isTarget = true;
        pathNumber = targetIndex + 1;
      }
    } else if (gameState is PathFinderSuccess) {
      // In success, let's also show all nodes checked or numbered
      // The state doesn't have the path directly, but if we had it we could show it.
      // However, typical behavior is just to show a dialog on success state change.
    }

    Color bgColor = Colors.white;
    Color borderColor = AppColors.primary.withValues(alpha: 0.1);
    Color textColor = AppColors.primary;

    if (isWrong) {
      bgColor = const Color(0xFFFFEBEE); // Light red
      borderColor = const Color(0xFFE53935); // Deep red
      textColor = const Color(0xFFE53935);
    } else if (isTarget && gameState is! PathFinderPlaying) {
      bgColor = AppColors.primary;
      borderColor = AppColors.primary.withValues(alpha: 0.5);
      textColor = Colors.white;
    } else if (isSelected) {
      bgColor = AppColors.primary.withValues(alpha: 0.2);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: gameState is PathFinderPlaying ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            if (isTarget || isSelected || isWrong)
              BoxShadow(
                color: borderColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: isWrong
              ? Icon(Icons.close, color: textColor, size: 28)
              : (pathNumber != -1)
              ? Text(
                  pathNumber.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
