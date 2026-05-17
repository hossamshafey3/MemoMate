import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class MriScatterChartWidget extends StatelessWidget {
  final List<double> values; // 0, 1, 2, or 3 representing patient MRI history
  final List<DateTime> dates;

  const MriScatterChartWidget({
    super.key,
    required this.values,
    required this.dates,
  });

  Color _getColorForLevel(int level) {
    switch (level) {
      case 0:
        return Colors.green; // No Impairment
      case 1:
        return Colors.yellow.shade700; // Very Mild
      case 2:
        return Colors.orange; // Mild
      case 3:
        return Colors.red; // Moderate
      default:
        return AppColors.grey;
    }
  }

  String _getLabelForLevel(int level) {
    switch (level) {
      case 0:
        return 'None';
      case 1:
        return 'Very Mild';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || dates.isEmpty) {
      return Container(
        height: 250.h,
        alignment: Alignment.center,
        child: Text(
          'No data available',
          style: GoogleFonts.poppins(color: AppColors.grey, fontSize: 14.sp),
        ),
      );
    }

    final limit = values.length.clamp(0, 7);
    final scatterSpots = List.generate(
      limit,
      (index) {
        final val = values[index];
        final level = val.toInt().clamp(0, 3);
        return ScatterSpot(
          (index + 1).toDouble(),
          val,
          dotPainter: FlDotCirclePainter(
            radius: 8.r,
            color: _getColorForLevel(level),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MRI Progression',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
                    'Latest: ${_getLabelForLevel(values.last.toInt().clamp(0, 3))}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 250.h,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: scatterSpots,
                minX: 1,
                maxX: 7,
                minY: -0.5,
                maxY: 3.5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.1),
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value < 1 || value > 7) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 12.sp,
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
                      reservedSize: 75,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > 3) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            _getLabelForLevel(value.toInt()),
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
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
                    getTooltipColor: (ScatterSpot spot) => Colors.black.withValues(alpha: 0.85),
                    getTooltipItems: (ScatterSpot touchedBarSpot) {
                      final int index = (touchedBarSpot.x - 1).toInt();
                      if (index < 0 || index >= dates.length) return null;
                      final date = dates[index];
                      final dateStr = DateFormat('MMM dd, yyyy').format(date);
                      final level = touchedBarSpot.y.toInt().clamp(0, 3);
                      return ScatterTooltipItem(
                        'Check #${index + 1}\n$dateStr\nResult: ${_getLabelForLevel(level)}',
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.sp,
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
          Center(
            child: Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendDot(Colors.green, 'None'),
                _buildLegendDot(Colors.yellow.shade700, 'Very Mild'),
                _buildLegendDot(Colors.orange, 'Mild'),
                _buildLegendDot(Colors.red, 'Moderate'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
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
