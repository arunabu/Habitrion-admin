import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/day_model.dart';
import 'dart:math';

class ChartsPanel extends StatelessWidget {
  final List<Task> tasks;

  const ChartsPanel({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No task data for this day. Add some tasks to see the charts!',
            style: TextStyle(color: Colors.white54, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final categoryData = _preparePieData(
        tasks.map((t) => t.category).toSet(), tasks, (task) => task.category);
    final subCategoryData = _preparePieData(
        tasks.map((t) => t.subcategory).toSet(),
        tasks,
        (task) => task.subcategory);

    // Use LayoutBuilder to create a responsive grid
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 24.0;
        final double availableWidth = constraints.maxWidth - (spacing * 2); // Subtract padding
        final double pieChartWidth = (availableWidth - spacing) / 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(spacing),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _buildChartCard(
                title: 'Category Breakdown',
                chart: PieChart(_buildPieChartData(categoryData)),
                legend: _buildLegend(categoryData),
                width: pieChartWidth,
              ),
              _buildChartCard(
                title: 'Subcategory Breakdown',
                chart: PieChart(_buildPieChartData(subCategoryData)),
                legend: _buildLegend(subCategoryData),
                width: pieChartWidth,
              ),
              _buildChartCard(
                title: 'Activity Progress',
                chart: BarChart(_buildActivityBarChart()),
                legend: _buildBarChartLegend(),
                width: availableWidth,
                chartHeight: 250,
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _preparePieData(
      Set<String> keys, List<Task> tasks, String Function(Task) getKey) {
    Map<String, double> data = {};
    for (var key in keys) {
      data[key] = tasks
          .where((task) => getKey(task) == key)
          .fold(0.0, (sum, task) => sum + task.actual);
    }
    return data;
  }

  Widget _buildChartCard({
    required String title,
    required Widget chart,
    required Widget legend,
    required double width,
    double chartHeight = 200,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(height: chartHeight, child: chart),
          const SizedBox(height: 24),
          legend,
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    return PieChartData(
      pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
      sections: data.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        return PieChartSectionData(
          color: _getColorForString(entry.key),
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList(),
      centerSpaceRadius: 0,
      sectionsSpace: 3,
    );
  }

  Widget _buildLegend(Map<String, double> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _getColorForString(entry.key),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${entry.key} (${entry.value.toStringAsFixed(1)}h)',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  BarChartData _buildActivityBarChart() {
    return BarChartData(
      barGroups: tasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: task.planned,
              color: Colors.blueAccent.withOpacity(0.7),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: task.actual,
              color: Colors.greenAccent,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true, reservedSize: 40, getTitlesWidget: _leftTitleWidgets)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < tasks.length) {
                return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(tasks[index].activity,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)));
              }
              return Container();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.white.withOpacity(0.1),
          strokeWidth: 1,
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => const Color(0xFF333333),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final task = tasks[group.x.toInt()];
            final rodName = rodIndex == 0 ? 'Planned' : 'Actual';
            return BarTooltipItem(
              '${task.activity}\n',
              const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              children: [
                TextSpan(
                    text: '$rodName: ${rod.toY.toStringAsFixed(1)}h',
                    style: TextStyle(
                        color: rod.color, fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 2 != 0 && value > 0) {
      return Container();
    }
    return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text('${value.toInt()}h',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.left));
  }

  Widget _buildBarChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.blueAccent.withOpacity(0.7), 'Planned'),
        const SizedBox(width: 24),
        _legendItem(Colors.greenAccent, 'Actual'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Color _getColorForString(String input) {
    final hash = input.hashCode;
    final random = Random(hash);
    return Color.fromRGBO(
      random.nextInt(128) + 100,
      random.nextInt(128) + 100,
      random.nextInt(128) + 100,
      1,
    );
  }
}
