import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/helmet_model.dart';
import '../services/weather_service.dart';

class HelmetDetailsScreen extends StatefulWidget {
  final Helmet helmet;

  const HelmetDetailsScreen({super.key, required this.helmet});

  @override
  State<HelmetDetailsScreen> createState() => _HelmetDetailsScreenState();
}

class _HelmetDetailsScreenState extends State<HelmetDetailsScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final data = await _weatherService.getCurrentWeather();
    setState(() {
      _weatherData = data;
      _loadingWeather = false;
    });
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _batteryColor(int? battery) {
    if (battery == null) return Colors.grey;
    if (battery <= 20) return Colors.red;
    if (battery <= 50) return Colors.orange;
    return Colors.green;
  }

  Color _temperatureColor(double? helmetTemp, double? compareTemp) {
    if (helmetTemp == null || compareTemp == null || helmetTemp == 0) {
      return Colors.grey;
    }
    double diff = helmetTemp - compareTemp;
    if (diff > 15) return Colors.red;
    if (diff > 10) return Colors.orange;
    return Colors.green;
  }

  String _temperatureStatus(double? helmetTemp, double? compareTemp) {
    if (helmetTemp == null || compareTemp == null || helmetTemp == 0) {
      return 'common.na'.tr();
    }
    double diff = helmetTemp - compareTemp;
    if (diff > 15) return '🔥 Overheating';
    if (diff > 10) return '⚠️ Hot';
    if (diff > 5) return '✅ Warm';
    return '✅ Normal';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 600 ? 12.0 : 16.0;
    final iconSize = screenWidth < 600 ? 28.0 : 36.0;
    final weatherTemp = _weatherService.getTemperature(_weatherData);

    return Scaffold(
      appBar: AppBar(title: Text('helmet_details.title'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Profile Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: iconSize,
                        backgroundColor:
                        _statusColor(widget.helmet.status).withOpacity(0.15),
                        child: Icon(Icons.engineering,
                            size: iconSize,
                            color: _statusColor(widget.helmet.status)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.helmet.id.isNotEmpty
                                  ? 'helmet_details.helmet_id'.tr(namedArgs: {'id': widget.helmet.id})
                                  : 'helmet_details.unknown_id'.tr(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                'helmet_details.assigned_to'.tr(namedArgs: {
                                  'name': widget.helmet.workerName ?? 'helmet_details.unassigned'.tr()
                                }),
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status & Battery Row
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'helmet_details.status'.tr(),
                      value: widget.helmet.status,
                      color: _statusColor(widget.helmet.status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'helmet_details.battery'.tr(),
                      value: widget.helmet.battery != null
                          ? '${widget.helmet.battery}%'
                          : 'common.na'.tr(),
                      color: _batteryColor(widget.helmet.battery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather Card
              if (_loadingWeather)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (weatherTemp != null)
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.orange, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'helmet_details.current_weather'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${weatherTemp.toStringAsFixed(1)}°C - ${_weatherService.getWeatherDescription(_weatherData)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Temperature Sensor Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'helmet_details.temperature_analysis'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TemperatureCard(
                            icon: Icons.engineering,
                            label: 'helmet_details.helmet_label'.tr(),
                            value: widget.helmet.helmetTemperature != null &&
                                widget.helmet.helmetTemperature! > 0
                                ? '${widget.helmet.helmetTemperature!.toStringAsFixed(1)}°C'
                                : 'common.na'.tr(),
                            color: widget.helmet.helmetTemperature != null &&
                                widget.helmet.helmetTemperature! > 0
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          _TemperatureCard(
                            icon: Icons.thermostat,
                            label: 'helmet_details.ambient'.tr(),
                            value: widget.helmet.ambientTemperature != null &&
                                widget.helmet.ambientTemperature! > 0
                                ? '${widget.helmet.ambientTemperature!.toStringAsFixed(1)}°C'
                                : 'common.na'.tr(),
                            color: widget.helmet.ambientTemperature != null &&
                                widget.helmet.ambientTemperature! > 0
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          _TemperatureCard(
                            icon: Icons.wb_sunny,
                            label: 'helmet_details.outside'.tr(),
                            value: weatherTemp != null
                                ? '${weatherTemp.toStringAsFixed(1)}°C'
                                : 'common.na'.tr(),
                            color:
                            weatherTemp != null ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _temperatureColor(
                              widget.helmet.helmetTemperature, weatherTemp)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _temperatureColor(
                                widget.helmet.helmetTemperature, weatherTemp),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: _temperatureColor(
                                  widget.helmet.helmetTemperature, weatherTemp),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'helmet_details.safety_status'.tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _weatherService.compareTemperatures(
                                      helmetTemp:
                                      widget.helmet.helmetTemperature ?? 0,
                                      weatherTemp: weatherTemp,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: _temperatureColor(
                                          widget.helmet.helmetTemperature,
                                          weatherTemp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Details Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailRow(
                          'helmet_details.last_update'.tr(),
                          widget.helmet.lastUpdate ?? 'helmet_details.unknown'.tr()),
                      const Divider(),
                      _DetailRow(
                          'helmet_details.location'.tr(),
                          widget.helmet.location ?? 'helmet_details.unknown'.tr()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TemperatureCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}