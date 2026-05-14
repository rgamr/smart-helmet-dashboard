import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _filterStatus = 'all'; // 'all', 'pending', 'in_progress', 'completed'

  final TaskService _taskService = TaskService();
  StreamSubscription? _tasksSub;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get filterStatus => _filterStatus;

  List<Task> get filteredTasks {
    if (_filterStatus == 'all') return _tasks;
    return _tasks.where((t) => t.status == _filterStatus).toList();
  }

  TaskProvider() {
    _listenToTasks();
  }

  void _listenToTasks() {
    _isLoading = true;
    _hasError = false;
    _tasksSub?.cancel();
    _tasksSub = _taskService.getTasks().listen(
      (data) {
        _tasks = data;
        _isLoading = false;
        _hasError = false;
        notifyListeners();
      },
      onError: (_) {
        _hasError = true;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void retry() {
    _listenToTasks();
    notifyListeners();
  }

  void setFilter(String status) {
    if (_filterStatus != status) {
      _filterStatus = status;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
  }

  Future<void> updateTask(String taskId, Task task) async {
    await _taskService.updateTask(taskId, task);
  }

  Future<void> updateStatus(String taskId, String status) async {
    await _taskService.updateStatus(taskId, status);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}
