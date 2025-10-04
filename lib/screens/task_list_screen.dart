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
    Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          "To-do List",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),

        child: Column(
          children: [
            const SizedBox(height: 16), // This adds a 16px gap below the AppBar
            // 🔹
            Consumer<TaskProvider>(
              builder: (context, provider, _) {
                final filters = {
                  TaskFilter.all: "All",
                  TaskFilter.completed: "Completed",
                  TaskFilter.pending: "Pending",
                };

                return SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = filters.keys.elementAt(index);
                      final label = filters[filter]!;
                      final isSelected = provider.currentFilter == filter;

                      return GestureDetector(
                        onTap: () => provider.setFilter(filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.indigo
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
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
                          Icon(Icons.inbox, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No tasks yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap the + button below to add your first task",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
    final Color chipColor = done
        ? Colors.green.shade100
        : Colors.orange.shade100;
    final Color textColor = done
        ? Colors.green.shade800
        : Colors.orange.shade800;
    final String statusText = done ? 'Completed' : 'Pending';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Checkbox(
          value: done,
          onChanged: (_) async {
            // 1️⃣ Determine the new status first
            final newStatus = !task.isCompleted;

            // 2️⃣ Show dialog BEFORE changing the task
            await showSuccessDialog(
              context,
              title: newStatus ? "Task Completed" : "Task Pending",
              message: newStatus
                  ? "Task has been marked as completed."
                  : "Task has been marked as pending.",
              icon: newStatus ? Icons.check_circle : Icons.undo,
              iconColor: newStatus ? Colors.green : Colors.orange,
            );

            // 3️⃣ Now update the task state
            await provider.toggleCompletion(task);
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
        ),
      ),
    );
  }
}
