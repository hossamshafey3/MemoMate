import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';

class GamesHomeScreen extends StatelessWidget {
  const GamesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Matching Game',
        'subtitle': 'Improve card matching & concentration',
        'icon': Icons.grid_view_rounded,
        'route': '/memoryCardGameScreen',
        'colors': [const Color(0xFF8E24AA), const Color(0xFF6A1B9A)],
      },
      {
        'title': 'Numbers Game',
        'subtitle': 'Test and build digit sequence span',
        'icon': Icons.pin_outlined,
        'route': '/numberMemoryScreen',
        'colors': [const Color(0xFF6C4AB6), const Color(0xFF512DA8)],
      },
      {
        'title': 'Spatial Path',
        'subtitle': 'Trace routes and boost spatial memory',
        'icon': Icons.alt_route_rounded,
        'route': '/pathFinderGameScreen',
        'colors': [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
      },
      {
        'title': 'Multiple Stimuli',
        'subtitle': 'Sharpen selective attention and focus',
        'icon': Icons.dashboard_customize_rounded,
        'route': '/multipleStimuliScreen',
        'colors': [const Color(0xFFD81B60), const Color(0xFFAD1457)],
      },
      {
        'title': 'Block Puzzle',
        'subtitle': 'Solve grid arrangements & shape logic',
        'icon': Icons.extension_rounded,
        'route': '/blockPuzzleScreen',
        'colors': [const Color(0xFF00ACC1), const Color(0xFF00838F)],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Soft ambient glows for premium aesthetic
          Positioned(
            top: -100.h,
            right: -100.w,
            child: Container(
              width: 300.r,
              height: 300.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: Container(
              width: 250.r,
              height: 250.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r, color: AppColors.black),
                          ),
                        ),
                        Text(
                          'Mind Training 🧠',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 40), // Balance back button spacer
                      ],
                    ),
                  ),
                ),

                // Greeting and Subtitle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keep Your Mind Sharp!',
                          style: GoogleFonts.poppins(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Select an exercise to challenge your cognitive skills and train your brain today.',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.grey,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // Games List
                SliverPadding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 24.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final game = games[index];
                        final colors = game['colors'] as List<Color>;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, game['route'] as String),
                            child: Container(
                              height: 110.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors[1].withValues(alpha: 0.35),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Ambient background design patterns
                                  Positioned(
                                    right: -30.w,
                                    bottom: -20.h,
                                    child: Icon(
                                      game['icon'] as IconData,
                                      size: 130.r,
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: Row(
                                      children: [
                                        // Premium Circular Icon Container
                                        Container(
                                          width: 60.r,
                                          height: 60.r,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.35),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            game['icon'] as IconData,
                                            size: 28.r,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        // Game Titles
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                game['title'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                game['subtitle'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color: Colors.white.withValues(alpha: 0.85),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Action Button
                                        Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.play_arrow_rounded,
                                            size: 20.r,
                                            color: colors[1],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: games.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
