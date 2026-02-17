// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/helmet_model.dart';
//
// class HelmetService {
//   final String baseUrl = 'http://10.0.2.2:3000';
//
//   Future<List<Helmet>> getHelmets() async {
//     final response = await http.get(Uri.parse('$baseUrl/helmets'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Helmet.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load helmets');
//     }
//   }
// }
