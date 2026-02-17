// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/worker_model.dart';
//
// class WorkerService {
//   final String baseUrl = 'http://10.0.2.2:3000';
//
//   Future<List<Worker>> getWorkers() async {
//     final response = await http.get(Uri.parse('$baseUrl/workers'));
//     if (response.statusCode == 200) {
//       List data = jsonDecode(response.body);
//       return data.map((e) => Worker.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load workers');
//     }
//   }
// }
