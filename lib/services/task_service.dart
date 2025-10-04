import 'dart:math';
import 'package:task_manager_app/models/task.dart';

class TaskService {
  List<Task> _tasks = [];

  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_tasks);
  }

  Future<Task> addTask(Task task) async {
    await Future.delayed(const Duration(seconds: 1));
    final newTask = Task(
      id: Random().nextInt(1000).toString(),
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
    );
    _tasks.add(newTask);
    return newTask;
  }

  Future<void> updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _tasks.removeWhere((t) => t.id == id);
  }

  Future<void> loadDummyData() async {
    _tasks = [
      Task(id: '1', title: 'Buy groceries', description: 'Milk and eggs', dueDate: DateTime.now().add(const Duration(days: 2))),
      Task(id: '2', title: 'Finish report', isCompleted: true),
    ];
  }
}
