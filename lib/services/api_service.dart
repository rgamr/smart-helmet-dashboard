import 'package:firebase_database/firebase_database.dart';

import '../models/worker_model.dart';
import '../models/incident_model.dart';
import '../models/helmet_model.dart';

class ApiService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ================= Workers =================
  Stream<List<Worker>> getWorkers() {
    return _db.child('workers').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      final Map<dynamic, dynamic> map = data as Map;
      return map.entries.map((entry) {
        final workerData = Map<String, dynamic>.from(entry.value);
        workerData['id'] = entry.key;
        return Worker.fromJson(workerData);
      }).toList();
    });
  }

  // ================= Helmets =================
  Stream<List<Helmet>> getHelmets() {
    return _db.child('helmets').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      final Map<dynamic, dynamic> map = data as Map;
      return map.entries.map((entry) {
        final helmetData = Map<String, dynamic>.from(entry.value);
        helmetData['id'] = entry.key;
        return Helmet.fromJson(helmetData);
      }).toList();
    });
  }

  // ================= Incidents =================
  Stream<List<Incident>> getIncidents({String? workerName}) {
    return _db.child('incidents').onValue.map((event) {
      final data = event.snapshot.value;

      if (data == null) return [];

      final Map<dynamic, dynamic> map = data as Map;

      final list = map.entries.map((entry) {
        final incidentData = Map<String, dynamic>.from(entry.value);
        incidentData['id'] = entry.key;
        return Incident.fromJson(incidentData);
      }).toList();

      if (workerName != null) {
        return list
            .where((incident) => incident.workerName == workerName)
            .toList();
      }

      return list;
    });
  }
}
