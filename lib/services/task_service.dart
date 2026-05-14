import 'package:firebase_database/firebase_database.dart';
import '../models/task_model.dart';

class TaskService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref('tasks');

  Stream<List<Task>> getTasks() {
    return _db.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final map = data as Map<dynamic, dynamic>;
      return map.entries.map((entry) {
        final taskData = Map<String, dynamic>.from(entry.value as Map);
        taskData['id'] = entry.key;
        return Task.fromJson(taskData);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> addTask(Task task) async {
    final ref = _db.push();
    await ref.set(task.toJson());
  }

  Future<void> updateTask(String taskId, Task task) async {
    await _db.child(taskId).update(task.toJson());
  }

  Future<void> updateStatus(String taskId, String status) async {
    await _db.child(taskId).update({'status': status});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.child(taskId).remove();
  }
}
