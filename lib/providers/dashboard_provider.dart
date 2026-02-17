import 'dart:async';
import 'package:flutter/material.dart';
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
    _listenToFirebase();
  }

  void _listenToFirebase() {
    isLoading = true;

    _workersSub = _apiService.getWorkers().listen((data) {
      _checkWorkerAlerts(data);
      if (!notificationsEnabled) return;
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
      if (!notificationsEnabled) return;
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

  void _checkWorkerAlerts(List<Worker> newWorkers) {
    for (final worker in newWorkers) {
      final prevStatus = _previousWorkerStatuses[worker.id];

      if (prevStatus != null &&
          prevStatus != 'Incident' &&
          worker.status == 'Incident') {
        _notificationService.showAlert(
          title: '🚨 Incident Alert',
          body: '${worker.name} has an active incident!',
          color: Colors.red.shade700,
        );
      }

      _previousWorkerStatuses[worker.id] = worker.status;
    }
  }

  void _checkHelmetAlerts(List<Helmet> newHelmets) {
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
    notifyListeners();
  }


  void toggleNotifications(bool value) {
    notificationsEnabled = value;
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