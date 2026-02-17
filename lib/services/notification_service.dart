import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void showAlert({
    required String title,
    required String body,
    Color color = Colors.red,
  }) {
    showSimpleNotification(
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(body, style: const TextStyle(color: Colors.white)),
      background: color,
      duration: const Duration(seconds: 4),
    );
  }
}