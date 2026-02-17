// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../models/helmet_model.dart';
// import '../services/helmet_service.dart';
//
// class HelmetProvider extends ChangeNotifier {
//   List<Helmet> _helmets = [];
//   bool isLoading = false;
//   bool hasError = false;
//
//   Timer? _timer;
//
//   List<Helmet> get helmets => _helmets;
//
//   HelmetProvider() {
//     fetchHelmets(initial: true);
//     startPolling();
//   }
//
//   Future<void> fetchHelmets({bool initial = false}) async {
//     if (initial) isLoading = true;
//     hasError = false;
//
//     try {
//       final newHelmets = await HelmetService().getHelmets();
//
//       // Only notify if the data actually changed
//       if (!_listEquals(_helmets, newHelmets)) {
//         _helmets = newHelmets;
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint("Error fetching helmets: $e");
//       hasError = true;
//       notifyListeners();
//     } finally {
//       if (initial) {
//         isLoading = false;
//         notifyListeners();
//       }
//     }
//   }
//
//   void startPolling() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchHelmets());
//   }
//
//   void stopPolling() {
//     _timer?.cancel();
//   }
//
//   bool _listEquals(List<Helmet> a, List<Helmet> b) {
//     if (a.length != b.length) return false;
//     for (int i = 0; i < a.length; i++) {
//       if (a[i] != b[i]) return false;
//     }
//     return true;
//   }
//
//   @override
//   void dispose() {
//     stopPolling();
//     super.dispose();
//   }
// }
