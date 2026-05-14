import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/dashboard_provider.dart';
import '../services/api_service.dart';
import '../models/sensor_reading_model.dart';

class ChartsScreen extends StatefulWidget {
  final String? preselectedWorkerId;
  const ChartsScreen({super.key, this.preselectedWorkerId});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedWorkerId;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _selectedWorkerId = widget.preselectedWorkerId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final workers = dashboard.workers;

    return Scaffold(
      appBar: AppBar(
        title: Text('charts.title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'charts.heart_rate'.tr()),
            Tab(text: 'charts.oxygen'.tr()),
            Tab(text: 'charts.body_temp'.tr()),
            Tab(text: 'charts.gas_levels'.tr()),
            Tab(text: 'charts.surrounding_o2'.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          // Worker Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedWorkerId,
              decoration: InputDecoration(
                labelText: 'charts.select_worker'.tr(),
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: workers
                  .map((w) => DropdownMenuItem(
                        value: w.id,
                        child: Text(w.name),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedWorkerId = val),
            ),
          ),

          // Charts
          Expanded(
            child: _selectedWorkerId == null
                ? _EmptyState(message: 'charts.select_worker'.tr())
                : StreamBuilder<List<SensorReading>>(
                    stream: _apiService.getSensorHistory(_selectedWorkerId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // ── Error state ─────────────────────────────────────
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 56, color: Colors.red.shade300),
                              const SizedBox(height: 12),
                              Text('common.error'.tr(),
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() {}), // re-triggers build
                                icon: const Icon(Icons.refresh),
                                label: Text('common.retry'.tr()),
                              ),
                            ],
                          ),
                        );
                      }
                      final readings = snapshot.data ?? [];
                      if (readings.isEmpty) {
                        return _EmptyState(
                            message: 'charts.no_history'.tr());
                      }
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _SensorChart(
                            readings: readings,
                            label: 'charts.heart_rate'.tr(),
                            unit: 'charts.bpm'.tr(),
                            color: Colors.red,
                            getValue: (r) => r.heartRate?.toDouble(),
                            minY: 40,
                            maxY: 180,
                            dangerLine: dashboard.heartRateMax.toDouble(),
                          ),
                          _SensorChart(
                            readings: readings,
                            label: 'charts.oxygen'.tr(),
                            unit: 'charts.percent'.tr(),
                            color: Colors.blue,
                            getValue: (r) => r.oxygenLevel?.toDouble(),
                            minY: 70,
                            maxY: 100,
                            dangerLine: dashboard.oxygenMin.toDouble(),
                            dangerBelow: true,
                          ),
                          _SensorChart(
                            readings: readings,
                            label: 'charts.body_temp'.tr(),
                            unit: 'charts.celsius'.tr(),
                            color: Colors.orange,
                            getValue: (r) => r.bodyTemperature,
                            minY: 35,
                            maxY: 42,
                            dangerLine: dashboard.bodyTempMax,
                          ),
                          _GasChart(
                            readings: readings,
                            coMax: dashboard.coMax,
                            co2Max: dashboard.co2Max,
                          ),
                          // ── 5th tab: Surrounding O₂ ─────────────────────
                          _SensorChart(
                            readings: readings,
                            label: 'charts.surrounding_o2'.tr(),
                            unit: 'charts.percent'.tr(),
                            color: Colors.indigo,
                            getValue: (r) => r.surroundingO2,
                            minY: 15,
                            maxY: 25,
                            dangerLine: dashboard.surroundingO2Min,
                            dangerBelow: true,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Sensor Line Chart ─────────────────────────────────────────────────
class _SensorChart extends StatelessWidget {
  final List<SensorReading> readings;
  final String label;
  final String unit;
  final Color color;
  final double? Function(SensorReading) getValue;
  final double minY;
  final double maxY;
  final double? dangerLine;
  final bool dangerBelow;

  const _SensorChart({
    required this.readings,
    required this.label,
    required this.unit,
    required this.color,
    required this.getValue,
    required this.minY,
    required this.maxY,
    this.dangerLine,
    this.dangerBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      final val = getValue(readings[i]);
      if (val != null) spots.add(FlSpot(i.toDouble(), val));
    }

    if (spots.isEmpty) {
      return _EmptyState(message: 'charts.no_history'.tr());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          if (dangerLine != null)
            Row(
              children: [
                Container(
                    width: 16, height: 2, color: Colors.red.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  dangerBelow
                      ? 'Min threshold: $dangerLine $unit'
                      : 'Max threshold: $dangerLine $unit',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.4)),
                    left: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (spots.length / 4).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < readings.length) {
                          final ts = DateTime.fromMillisecondsSinceEpoch(
                              readings[idx].timestamp);
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                extraLinesData: dangerLine != null
                    ? ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: dangerLine!,
                          color: Colors.red.withOpacity(0.6),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(show: false),
                        ),
                      ])
                    : null,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.08),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) =>
                        touchedSpots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} $unit',
                        TextStyle(
                            color: color, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gas Levels Chart (CO + CO2) ─────────────────────────────────────────────
class _GasChart extends StatelessWidget {
  final List<SensorReading> readings;
  final double coMax;
  final double co2Max;

  const _GasChart({
    required this.readings,
    required this.coMax,
    required this.co2Max,
  });

  @override
  Widget build(BuildContext context) {
    final coSpots = <FlSpot>[];
    final co2Spots = <FlSpot>[];

    for (int i = 0; i < readings.length; i++) {
      if (readings[i].coLevel != null) {
        coSpots.add(FlSpot(i.toDouble(), readings[i].coLevel!));
      }
      if (readings[i].co2Level != null) {
        // Scale CO2 down for shared axis (divide by 10 for display)
        co2Spots.add(FlSpot(i.toDouble(), readings[i].co2Level! / 10));
      }
    }

    if (coSpots.isEmpty && co2Spots.isEmpty) {
      return _EmptyState(message: 'charts.no_history'.tr());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'charts.gas_levels'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: Colors.purple, label: 'CO (ppm)'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.teal, label: 'CO₂ (ppm ÷10)'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.4)),
                    left: BorderSide(color: Colors.grey.withOpacity(0.4)),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: coMax,
                    color: Colors.purple.withOpacity(0.5),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                  HorizontalLine(
                    y: co2Max / 10,
                    color: Colors.teal.withOpacity(0.5),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                ]),
                lineBarsData: [
                  if (coSpots.isNotEmpty)
                    LineChartBarData(
                      spots: coSpots,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withOpacity(0.07)),
                    ),
                  if (co2Spots.isNotEmpty)
                    LineChartBarData(
                      spots: co2Spots,
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color: Colors.teal.withOpacity(0.07)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
