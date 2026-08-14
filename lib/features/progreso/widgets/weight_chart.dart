import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/database/app_database.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.logs});

  final List<BodyWeightLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (logs.isEmpty) {
      return Center(
        child: Text(
          'Registra tu peso para comenzar a ver tu progreso.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));
    final minDay = sorted.first.date;
    final spots = [
      for (final log in sorted)
        FlSpot(log.date.difference(minDay).inDays.toDouble(), log.weightKg),
    ];
    final minY = sorted.map((l) => l.weightKg).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = sorted.map((l) => l.weightKg).reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppTheme.border, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem('${spot.y.toStringAsFixed(1)} kg', theme.textTheme.bodySmall!),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.accent,
            barWidth: 3,
            dotData: FlDotData(show: spots.length <= 30),
            belowBarData: BarAreaData(show: true, color: AppTheme.accent.withValues(alpha: 0.12)),
          ),
        ],
      ),
    );
  }
}
