// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../models/incident_model.dart';
// import '../services/incident_service.dart';
//
// class IncidentProvider extends ChangeNotifier {
//   final String? workerName;
//
//   List<Incident> _incidents = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   String selectedFilter = 'All';
//   Timer? _pollingTimer;
//
//   // ================= Getters =================
//   List<Incident> get incidents => _incidents;
//   bool get isLoading => _isLoading;
//   bool get hasError => _hasError;
//
//   IncidentProvider({this.workerName}) {
//     fetchIncidents();
//     _startPolling();
//   }
//
//   // ================= Fetch Incidents =================
//   Future<void> fetchIncidents() async {
//     try {
//       final newIncidents = await IncidentService().getIncidents(workerName: workerName);
//
//       // Only notify if data actually changed
//       if (_incidents != newIncidents) {
//         _incidents = newIncidents;
//         notifyListeners();
//       }
//
//       _hasError = false;
//     } catch (e) {
//       debugPrint("Error fetching incidents: $e");
//       _hasError = true;
//       notifyListeners();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // ================= Filter =================
//   void setFilter(String filter) {
//     if (selectedFilter != filter) {
//       selectedFilter = filter;
//       notifyListeners();
//     }
//   }
//
//   // ================= Polling =================
//   void _startPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetchIncidents());
//   }
//
//   void stopPolling() {
//     _pollingTimer?.cancel();
//   }
//
//   @override
//   void dispose() {
//     stopPolling();
//     super.dispose();
//   }
// }
