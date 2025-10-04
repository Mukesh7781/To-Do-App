import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/services/task_service.dart';

enum TaskFilter { all, completed, pending }

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;

  /// Expose filtered tasks based on current filter
  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.completed:
        return _tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.pending:
        return _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.all:
      return _tasks;
    }
  }

  TaskFilter get currentFilter => _currentFilter;

  TaskProvider() {
    _service.loadDummyData(); // load some starter tasks
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    _tasks = await _service.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _service.addTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _service.updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
    await fetchTasks();
  }

  Future<void> toggleCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}
