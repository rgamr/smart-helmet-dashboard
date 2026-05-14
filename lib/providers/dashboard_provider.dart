import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/worker_model.dart';
import '../models/helmet_model.dart';
import '../models/incident_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:collection/collection.dart';

class DashboardProvider with ChangeNotifier {
  List<Worker> workers = [];
  List<Helmet> helmets = [];
  List<Incident> incidents = [];

  bool isLoading = true;
  bool hasError = false;
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  Worker? selectedWorker;
  String selectedIncidentFilter = 'All';

  // ─── Configurable Alert Thresholds ───────────────────────────────────────
  int heartRateMax = 120;
  int oxygenMin = 90;
  double bodyTempMax = 38.5;
  double coMax = 35.0;      // ppm — OSHA permissible limit
  double co2Max = 1000.0;   // ppm — indoor air quality threshold
  double surroundingO2Min = 19.5; // % — safe oxygen level floor

  // ─── SharedPreferences Keys ──────────────────────────────────────────────
  static const _kHeartRateMax = 'threshold_heartRateMax';
  static const _kOxygenMin = 'threshold_oxygenMin';
  static const _kBodyTempMax = 'threshold_bodyTempMax';
  static const _kCoMax = 'threshold_coMax';
  static const _kCo2Max = 'threshold_co2Max';
  static const _kSurroundingO2Min = 'threshold_surroundingO2Min';
  static const _kDarkMode = 'setting_darkMode';
  static const _kNotifications = 'setting_notifications';

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    heartRateMax = prefs.getInt(_kHeartRateMax) ?? 120;
    oxygenMin = prefs.getInt(_kOxygenMin) ?? 90;
    bodyTempMax = prefs.getDouble(_kBodyTempMax) ?? 38.5;
    coMax = prefs.getDouble(_kCoMax) ?? 35.0;
    co2Max = prefs.getDouble(_kCo2Max) ?? 1000.0;
    surroundingO2Min = prefs.getDouble(_kSurroundingO2Min) ?? 19.5;
    isDarkMode = prefs.getBool(_kDarkMode) ?? false;
    notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
    notifyListeners();
  }

  Future<void> _saveThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHeartRateMax, heartRateMax);
    await prefs.setInt(_kOxygenMin, oxygenMin);
    await prefs.setDouble(_kBodyTempMax, bodyTempMax);
    await prefs.setDouble(_kCoMax, coMax);
    await prefs.setDouble(_kCo2Max, co2Max);
    await prefs.setDouble(_kSurroundingO2Min, surroundingO2Min);
  }

  void updateThresholds({
    int? heartRateMax,
    int? oxygenMin,
    double? bodyTempMax,
    double? coMax,
    double? co2Max,
    double? surroundingO2Min,
  }) {
    if (heartRateMax != null) this.heartRateMax = heartRateMax;
    if (oxygenMin != null) this.oxygenMin = oxygenMin;
    if (bodyTempMax != null) this.bodyTempMax = bodyTempMax;
    if (coMax != null) this.coMax = coMax;
    if (co2Max != null) this.co2Max = co2Max;
    if (surroundingO2Min != null) this.surroundingO2Min = surroundingO2Min;
    _saveThresholds();
    notifyListeners();
  }

  final _listEquality = const ListEquality();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  final Map<String, String> _previousWorkerStatuses = {};
  final Map<String, String> _previousHelmetStatuses = {};
  final Map<String, int> _previousHelmetBatteries = {};

  StreamSubscription? _workersSub;
  StreamSubscription? _helmetsSub;
  StreamSubscription? _incidentsSub;

  DashboardProvider() {
    loadPreferences().then((_) => _listenToFirebase());
  }

  void _listenToFirebase() {
    isLoading = true;

    _workersSub = _apiService.getWorkers().listen((data) {
      _checkWorkerAlerts(data);
      if (!_listEquality.equals(workers, data)) {
        workers = data;
        isLoading = false;
        hasError = false;
        notifyListeners();
      }
    }, onError: (_) {
      hasError = true;
      isLoading = false;
      notifyListeners();
    });

    _helmetsSub = _apiService.getHelmets().listen((data) {
      _checkHelmetAlerts(data);
      if (!_listEquality.equals(helmets, data)) {
        helmets = data;
        notifyListeners();
      }
    });

    _incidentsSub = _apiService.getIncidents().listen((data) {
      if (!_listEquality.equals(incidents, data)) {
        incidents = data;
        notifyListeners();
      }
    });
  }

  void retry() {
    hasError = false;
    isLoading = true;
    notifyListeners();
    _workersSub?.cancel();
    _helmetsSub?.cancel();
    _incidentsSub?.cancel();
    _listenToFirebase();
  }

  void _checkWorkerAlerts(List<Worker> newWorkers) {
    if (!notificationsEnabled) return;

    for (final worker in newWorkers) {
      final prevStatus = _previousWorkerStatuses[worker.id];

      // Incident status change
      if (prevStatus != null &&
          prevStatus != 'Incident' &&
          worker.status == 'Incident') {
        _notificationService.showAlert(
          title: '🚨 Incident Alert',
          body: '${worker.name} has an active incident!',
          color: Colors.red.shade700,
        );
      }

      // Heart rate threshold
      if (worker.heartRate != null && worker.heartRate! > heartRateMax) {
        _notificationService.showAlert(
          title: '❤️ High Heart Rate',
          body:
              '${worker.name}: ${worker.heartRate} bpm (limit: $heartRateMax)',
          color: Colors.red.shade700,
        );
      }

      // Blood oxygen threshold
      if (worker.oxygenLevel != null && worker.oxygenLevel! < oxygenMin) {
        _notificationService.showAlert(
          title: '💨 Low Blood Oxygen',
          body: '${worker.name}: ${worker.oxygenLevel}% (min: $oxygenMin%)',
          color: Colors.orange.shade700,
        );
      }

      // Body temperature threshold
      if (worker.bodyTemperature != null &&
          worker.bodyTemperature! > bodyTempMax) {
        _notificationService.showAlert(
          title: '🌡️ High Body Temperature',
          body:
              '${worker.name}: ${worker.bodyTemperature!.toStringAsFixed(1)}°C (max: ${bodyTempMax}°C)',
          color: Colors.orange.shade700,
        );
      }

      // CO level threshold
      if (worker.coLevel != null && worker.coLevel! > coMax) {
        _notificationService.showAlert(
          title: '☠️ Dangerous CO Level',
          body:
              '${worker.name}: ${worker.coLevel!.toStringAsFixed(1)} ppm CO (max: ${coMax} ppm)',
          color: Colors.red.shade900,
        );
      }

      // CO2 level threshold
      if (worker.co2Level != null && worker.co2Level! > co2Max) {
        _notificationService.showAlert(
          title: '⚠️ High CO₂ Level',
          body:
              '${worker.name}: ${worker.co2Level!.toStringAsFixed(0)} ppm CO₂ (max: ${co2Max.toStringAsFixed(0)} ppm)',
          color: Colors.orange.shade700,
        );
      }

      // Surrounding O2 threshold
      if (worker.surroundingO2 != null &&
          worker.surroundingO2! < surroundingO2Min) {
        _notificationService.showAlert(
          title: '🫁 Low Surrounding Oxygen',
          body:
              '${worker.name}: ${worker.surroundingO2!.toStringAsFixed(1)}% O₂ (min: ${surroundingO2Min}%)',
          color: Colors.red.shade700,
        );
      }

      // Fall detected
      if (worker.fallDetected == true) {
        _notificationService.showAlert(
          title: '🆘 Fall Detected!',
          body: '${worker.name} may have fallen. Check immediately!',
          color: Colors.red.shade900,
        );
      }

      // Helmet not worn
      if (worker.isHelmetWorn == false &&
          worker.status.toLowerCase() == 'online') {
        _notificationService.showAlert(
          title: '⛑️ Helmet Not Worn',
          body: '${worker.name} is not wearing their helmet!',
          color: Colors.orange.shade700,
        );
      }

      _previousWorkerStatuses[worker.id] = worker.status;
    }
  }

  void _checkHelmetAlerts(List<Helmet> newHelmets) {
    if (!notificationsEnabled) return;

    for (final helmet in newHelmets) {
      final prevStatus = _previousHelmetStatuses[helmet.id];
      final prevBattery = _previousHelmetBatteries[helmet.id];

      if (prevStatus != null &&
          prevStatus != 'Offline' &&
          helmet.status == 'Offline') {
        _notificationService.showAlert(
          title: '⚠️ Helmet Disconnected',
          body: 'Helmet ${helmet.id} has disconnected!',
          color: Colors.orange.shade700,
        );
      }

      if (prevBattery != null &&
          prevBattery >= 20 &&
          helmet.battery != null &&
          helmet.battery! < 20) {
        _notificationService.showAlert(
          title: '🔋 Low Battery',
          body: 'Helmet ${helmet.id} battery is at ${helmet.battery}%!',
          color: Colors.orange.shade700,
        );
      }

      _previousHelmetStatuses[helmet.id] = helmet.status;
      if (helmet.battery != null) {
        _previousHelmetBatteries[helmet.id] = helmet.battery!;
      }
    }
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_kDarkMode, isDarkMode));
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_kNotifications, notificationsEnabled));
    notifyListeners();
  }

  void selectWorker(String workerId) {
    selectedWorker = workers.firstWhereOrNull((w) => w.id == workerId);
    notifyListeners();
  }

  void setIncidentFilter(String filter) {
    if (selectedIncidentFilter != filter) {
      selectedIncidentFilter = filter;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _workersSub?.cancel();
    _helmetsSub?.cancel();
    _incidentsSub?.cancel();
    super.dispose();
  }
}