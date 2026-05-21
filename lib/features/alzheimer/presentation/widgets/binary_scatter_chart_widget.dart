import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  BinaryScatterChartWidget
//
//  A clean scatter chart representing a single binary feature (Yes/No).
//  Mimics the MRI Progression chart styling and logic.
//
//  Layout:
//    - Y-axis: Exactly two rows: "Yes" (1.0) and "No" (0.0).
//    - X-axis: Check sequence 1–7.
//    - Scatter points:
//        ● Crimson Red   (#D32F2F)  →  Yes / Risk Present  / 1.0
//        ● Emerald Green  (#388E3C)  →  No  / Normal / 0.0
// ─────────────────────────────────────────────────────────────────────────────

class BinaryScatterChartWidget extends StatelessWidget {
  final List<double> values;
  final List<DateTime> dates;
  final String title;
  final String? subtitle;

  const BinaryScatterChartWidget({
    super.key,
    required this.values,
    required this.dates,
    required this.title,
    this.subtitle,
  });

  // ── Theme colour constants ────────────────────────────────────────────────
  static const Color _riskRed = Color(0xFFD32F2F);   // Crimson Red
  static const Color _safeGreen = Color(0xFF388E3C);  // Emerald Green

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return _buildEmptyState();
    }

    final limit = values.length.clamp(0, 7);
    final scatterSpots = List.generate(
      limit,
      (index) {
        final val = values[index];
        final isYes = val >= 0.5;
        final yVal = isYes ? 1.0 : 0.0;
        return ScatterSpot(
          (index + 1).toDouble(),
          yVal,
          dotPainter: FlDotCirclePainter(
            radius: 8.r,
            color: isYes ? _riskRed : _safeGreen,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        );
      },
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (Title & Latest Status Badge) ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (values.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Latest: ${values.last >= 0.5 ? 'Yes' : 'No'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: AppColors.black.withValues(alpha: 0.45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: 24.h),

          // ── Chart ──────────────────────────────────────────────────────────
          SizedBox(
            height: 220.h,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: scatterSpots,
                minX: 0.4,
                maxX: 7.6,
                minY: -0.5,
                maxY: 1.5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        'Check Sequence',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    axisNameSize: 24.h,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Check if value is a whole integer (prevent duplicates from decimals like 7.6 rounding down)
                        if ((value - value.round()).abs() > 0.01) {
                          return const SizedBox.shrink();
                        }
                        final idx = value.round();
                        if (idx < 1 || idx > 7) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            idx.toString(),
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 55.w,
                      getTitlesWidget: (value, meta) {
                        final diffToZero = (value - 0.0).abs();
                        final diffToOne = (value - 1.0).abs();
                        if (diffToZero > 0.01 && diffToOne > 0.01) {
                          return const SizedBox.shrink();
                        }
                        final label = diffToOne <= 0.01 ? 'Yes' : 'No';
                        return Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              color: AppColors.black.withValues(alpha: 0.75),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipColor: (ScatterSpot spot) =>
                        Colors.black.withValues(alpha: 0.85),
                    getTooltipItems: (ScatterSpot touchedSpot) {
                      final checkIdx = (touchedSpot.x - 1).toInt();
                      if (checkIdx < 0 || checkIdx >= values.length) {
                        return null;
                      }

                      final isYes = values[checkIdx] >= 0.5;

                      String dateStr = '';
                      if (checkIdx < dates.length) {
                        dateStr = DateFormat('MMM dd, yyyy').format(dates[checkIdx]);
                      }

                      final statusLabel = isYes
                          ? '🔴  Risk Present (Yes)'
                          : '🟢  Normal (No)';

                      return ScatterTooltipItem(
                        'Check #${checkIdx + 1}${dateStr.isNotEmpty ? '\n$dateStr' : ''}'
                        '\n$title\n$statusLabel',
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),
          Divider(color: AppColors.grey.withValues(alpha: 0.15)),
          SizedBox(height: 12.h),

          // ── Legend ─────────────────────────────────────────────────────────
          Center(
            child: Wrap(
              spacing: 24.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendDot(_riskRed, 'Risk Present (Yes)'),
                _buildLegendDot(_safeGreen, 'Normal (No)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty-state placeholder ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      height: 220.h,
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scatter_plot_outlined,
              size: 48.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No binary feature data available yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete a diagnostic check to see your scatter plot.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Legend dot helper ───────────────────────────────────────────────────
  Widget _buildLegendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppColors.black.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
