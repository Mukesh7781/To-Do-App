import 'dart:convert';
import 'package:task_manager_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  static const String _storageKey = 'task_list';

  /// 🔹 Fetch all tasks from local storage
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Task.fromJson(e)).toList();
  }

  /// 🔹 Add new task and save
  Future<void> addTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();

    // Generate ID if missing
    final newTask = Task(
      id: task.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
    );

    tasks.add(newTask);
    await _saveTasks(prefs, tasks);
  }

  /// 🔹 Update existing task
  Future<void> updateTask(Task updatedTask) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(prefs, tasks);
    }
  }

  /// 🔹 Delete task
  Future<void> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await _saveTasks(prefs, tasks);
  }

  /// 🔹 Helper: Save tasks list as JSON
  Future<void> _saveTasks(SharedPreferences prefs, List<Task> tasks) async {
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
