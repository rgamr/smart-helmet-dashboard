import 'package:firebase_database/firebase_database.dart';

import '../models/worker_model.dart';
import '../models/incident_model.dart';
import '../models/helmet_model.dart';
import '../models/sensor_reading_model.dart';

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

  Future<void> updateIncidentStatus(String incidentId, String status) async {
    await _db.child('incidents').child(incidentId).update({'status': status});
  }

  // ================= Sensor History =================
  Stream<List<SensorReading>> getSensorHistory(String workerId) {
    return _db
        .child('sensorHistory')
        .child(workerId)
        .orderByChild('timestamp')
        .limitToLast(24)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final Map<dynamic, dynamic> map = data as Map;
      final readings = map.entries.map((entry) {
        final readingData = Map<String, dynamic>.from(entry.value);
        return SensorReading.fromJson(readingData);
      }).toList();
      readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return readings;
    });
  }

  // ================= User Data =================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _db.child('users').child(uid).get();
    if (snapshot.value == null) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _db.child('users').child(uid).onValue.map((event) {
      if (event.snapshot.value == null) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  Future<String?> getUserRole(String uid) async {
    final snapshot = await _db.child('users').child(uid).child('role').get();
    return snapshot.value as String?;
  }

  Future<void> setUserRole(String uid, String role) async {
    await _db.child('users').child(uid).update({'role': role});
  }

  // ================= Users List (for Role Management) =================
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _db.child('users').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final Map<dynamic, dynamic> map = data as Map;
      return map.entries.map((entry) {
        final userData = Map<String, dynamic>.from(entry.value);
        userData['uid'] = entry.key;
        return userData;
      }).toList();
    });
  }

  Future<void> upsertUserRecord(String uid, String email, String role) async {
    await _db.child('users').child(uid).update({'email': email, 'role': role});
  }
}
