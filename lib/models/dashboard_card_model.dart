import 'package:flutter/material.dart';

class DashboardCardModel {
  final String title;
  final String? metric;
  final IconData icon;
  final Color color;

  const DashboardCardModel({
    required this.title,
    this.metric,
    required this.icon,
    required this.color,
  });
}


//   // We usually don’t send IconData or Color via API, so only metric and title maybe
//   factory DashboardCardModel.fromJson(Map<String, dynamic> json) {
//     return DashboardCardModel(
//       title: json['title'],
//       icon: Icons.dashboard, // placeholder, cannot send IconData from API
//       color: Colors.blue, // placeholder, cannot send Color from API
//       metric: json['metric'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'title': title,
//     'metric': metric,
//   };
// }
