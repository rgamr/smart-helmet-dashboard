// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/incident_model.dart';
//
// class IncidentService {
//   final String baseUrl = 'http://10.0.2.2:3000';
//
//   Future<List<Incident>> getIncidents({String? workerName}) async {
//     final response = await http.get(Uri.parse('$baseUrl/incidents'));
//
//     if (response.statusCode == 200) {
//       final List data = json.decode(response.body);
//
//       // Optional: filter by workerName if provided
//       final filteredData = workerName != null
//           ? data.where((item) => item['workerName'] == workerName).toList()
//           : data;
//
//       return filteredData.map((json) => Incident.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load incidents');
//     }
//   }
// }
