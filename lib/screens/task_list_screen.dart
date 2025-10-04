// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/screens/add_edit_task_screen.dart';
import 'package:task_manager_app/screens/task_detail_screen.dart';
import 'package:task_manager_app/widgets/dialogs.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 245, 245, 248),
        foregroundColor: Colors.white,
        title: Text(
          provider.currentFilter == TaskFilter.all
              ? "All Tasks"
              : provider.currentFilter == TaskFilter.completed
                  ? "Completed Tasks"
                  : "Pending Tasks",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔹 Filter control
            Consumer<TaskProvider>(
              builder: (context, provider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<TaskFilter>(
                    segments: const [
                      ButtonSegment(value: TaskFilter.all, label: Text("All")),
                      ButtonSegment(
                        value: TaskFilter.completed,
                        label: Text("Completed"),
                      ),
                      ButtonSegment(
                        value: TaskFilter.pending,
                        label: Text("Pending"),
                      ),
                    ],
                    selected: {provider.currentFilter},
                    onSelectionChanged: (selection) {
                      provider.setFilter(selection.first);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 🔹 Task list or empty state
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, _) {
                  final tasks = provider.filteredTasks;
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No tasks yet",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap the + button below to add your first task",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(task: task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Task",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    final bool done = task.isCompleted;
    final Color chipColor = done ? Colors.green.shade100 : Colors.orange.shade100;
    final Color textColor = done ? Colors.green.shade800 : Colors.orange.shade800;
    final String statusText = done ? 'Completed' : 'Pending';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Checkbox(
          value: done,
          onChanged: (_) async {
            await provider.toggleCompletion(task);
            await showSuccessDialog(
              context,
              title: task.isCompleted ? "Task Completed" : "Task Pending",
              message: task.isCompleted
                  ? "Task has been marked as completed."
                  : "Task has been marked as pending.",
              icon: task.isCompleted ? Icons.undo : Icons.check_circle,
              iconColor: task.isCompleted ? Colors.orange : Colors.green,
            );
          },
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: task.dueDate != null
            ? Text("Due: ${DateFormat('MMM d').format(task.dueDate!)}")
            : null,
        trailing: Chip(
          label: Text(statusText, style: TextStyle(color: textColor)),
          backgroundColor: chipColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
        )
      ),
    );
  }
}