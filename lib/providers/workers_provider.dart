// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:collection/collection.dart';
// import '../models/worker_model.dart';
// import '../services/worker_service.dart';
//
// class WorkersProvider with ChangeNotifier {
//   final WorkerService _service = WorkerService();
//
//   List<Worker> _workers = [];
//   Worker? _selectedWorker;
//   bool _isLoading = false;
//   String? _error;
//
//   Timer? _pollingTimer;
//
//   final _listEquality = const ListEquality();
//
//   List<Worker> get workers => _workers;
//   Worker? get selectedWorker => _selectedWorker;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   WorkersProvider() {
//     fetchWorkers();
//     _startPolling();
//   }
//
//   Future<void> fetchWorkers() async {
//     try {
//       final newWorkers = await _service.getWorkers();
//
//       if (!_listEquality.equals(_workers, newWorkers)) {
//         _workers = newWorkers;
//         notifyListeners();
//       }
//     } catch (e) {
//       if (_error != e.toString()) {
//         _error = e.toString();
//         notifyListeners();
//       }
//     }
//     _isLoading = false;
//   }
//
//   void selectWorker(String id) {
//     _selectedWorker = _workers.firstWhereOrNull((w) => w.id == id);
//     notifyListeners();
//   }
//
//   void updateWorker(Worker updatedWorker) {
//     final index = _workers.indexWhere((w) => w.id == updatedWorker.id);
//     if (index != -1) {
//       _workers[index] = updatedWorker;
//       if (_selectedWorker?.id == updatedWorker.id) _selectedWorker = updatedWorker;
//       notifyListeners();
//     }
//   }
//
//   void _startPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetchWorkers());
//   }
//
//   void stopPolling() => _pollingTimer?.cancel();
//
//   @override
//   void dispose() {
//     stopPolling();
//     super.dispose();
//   }
// }
