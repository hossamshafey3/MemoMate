import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/memory_games/logic/block_puzzle_cubit.dart';
import 'package:gradproj/features/memory_games/logic/block_puzzle_state.dart';

class BlockPuzzleScreen extends StatelessWidget {
  const BlockPuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlockPuzzleCubit(),
      child: const BlockPuzzleView(),
    );
  }
}

class BlockPuzzleView extends StatelessWidget {
  const BlockPuzzleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Block Puzzle',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<BlockPuzzleCubit, BlockPuzzleState>(
        builder: (context, state) {
          if (state is BlockPuzzleInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BlockPuzzlePlaying) {
            return _buildPlayingView(context, state);
          } else if (state is BlockPuzzleGameOver) {
            return _buildGameOverView(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPlayingView(BuildContext context, BlockPuzzlePlaying state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${state.level}/${BlockPuzzleCubit.totalLevels}',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Score: ${state.score}',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Find the missing part to complete the shape!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Puzzle Board
          Container(
            width: 220.r,
            height: 220.r,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ShapeVisualizer(
              shape: state.puzzleBoard,
              solidColor: const Color(0xFF9C27B0),
              emptyColor: Colors.grey.withValues(
                alpha: 0.2,
              ), // Distinct color for holes
              drawEmpty: true,
            ),
          ),

          if (state.isIncorrectTry)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Incorrect! Try again.',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          SizedBox(height: 20.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: state.animateTransition
                ? CircularProgressIndicator(color: const Color(0xFF9C27B0))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: state.options.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.6,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.read<BlockPuzzleCubit>().submitAnswer(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(
                                0xFF9C27B0,
                              ).withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ShapeVisualizer(
                              shape: state.options[index],
                              solidColor: const Color(
                                0xFFAB47BC,
                              ), // Lighter purple
                              drawEmpty: false,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildGameOverView(BuildContext context, BlockPuzzleGameOver state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 100.r, color: Colors.amber),
          SizedBox(height: 20.h),
          Text(
            'Puzzle Master!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9C27B0),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            'Final Score: ${state.score}',
            style: GoogleFonts.poppins(fontSize: 20.sp, color: AppColors.black),
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              'Back to Games',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShapeVisualizer extends StatelessWidget {
  final List<List<int>> shape;
  final Color solidColor;
  final Color? emptyColor;
  final bool drawEmpty;

  const ShapeVisualizer({
    super.key,
    required this.shape,
    required this.solidColor,
    this.emptyColor,
    this.drawEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Find maximum dimension needed for consistent blocks
        final double size =
            (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight) *
            0.8;
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: TetrisPainter(
              shape: shape,
              solidColor: solidColor,
              emptyColor: emptyColor ?? Colors.transparent,
              drawEmpty: drawEmpty,
            ),
          ),
        );
      },
    );
  }
}

class TetrisPainter extends CustomPainter {
  final List<List<int>> shape;
  final Color solidColor;
  final Color emptyColor;
  final bool drawEmpty;

  TetrisPainter({
    required this.shape,
    required this.solidColor,
    required this.emptyColor,
    required this.drawEmpty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int rows = shape.length;
    if (rows == 0) return;
    final int cols = shape[0].length;
    if (cols == 0) return;

    final double blockWidth = size.width / cols;
    final double blockHeight = size.height / rows;

    final Paint paintSolid = Paint()
      ..style = PaintingStyle.fill
      ..color = solidColor;

    final Paint paintEmpty = Paint()
      ..style = PaintingStyle.fill
      ..color = emptyColor;

    final Paint paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final Rect rect = Rect.fromLTWH(
          c * blockWidth,
          r * blockHeight,
          blockWidth,
          blockHeight,
        );

        if (shape[r][c] == 1) {
          canvas.drawRect(rect, paintSolid);
          canvas.drawRect(rect, paintBorder);
        } else if (drawEmpty) {
          canvas.drawRect(rect, paintEmpty);
          canvas.drawRect(rect, paintBorder);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
