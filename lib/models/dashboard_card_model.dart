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
