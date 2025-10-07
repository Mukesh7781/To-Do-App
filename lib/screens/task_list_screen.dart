import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/screens/task_detail_screen.dart';
import 'package:task_manager_app/widgets/add_edit_task_modal.dart';
import 'package:task_manager_app/widgets/dialogs.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
  backgroundColor: theme.colorScheme.surface,
  elevation: 6, // was 1
  shadowColor: Colors.black.withOpacity(0.15),
  surfaceTintColor: Colors.transparent,
  toolbarHeight: 64,
  centerTitle: false,
  title: const Text(
    "To-do List",
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  ),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(20),
    ),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Filter Bar
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
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    )
                                  ]
                                : [],
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
            const SizedBox(height: 16),

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
                          Icon(Icons.inbox_outlined,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No tasks yet",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap the + button below to add your first task",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

      // 🔹 Floating Action Button
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Task",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: const AddEditTaskModal(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 🔹 Single Task Card
class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);
    final done = task.isCompleted;

   return Card(
  elevation: 6, 
  color: Colors.white,
  shadowColor: Colors.black.withOpacity(0.40), 
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(23),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
   
leading: Checkbox(
          value: done,
          activeColor: Colors.black,
          onChanged: (_) async {
            final newStatus = !task.isCompleted;

            await showSuccessDialog(
              context,
              title: newStatus ? "Task Completed" : "Task Pending",
              message: newStatus
                  ? "Task has been marked as completed."
                  : "Task has been marked as pending.",
              icon: newStatus ? Icons.check_circle : Icons.undo,
              iconColor:
                  newStatus ? Colors.green : Colors.orange,
            );

            await provider.toggleCompletion(task);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: done ? Colors.grey : Colors.black,
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.dueDate != null
            ? Text(
                "Due: ${DateFormat('MMM d').format(task.dueDate!)}",
                style: TextStyle(
                  color: done ? Colors.grey : Colors.black54,
                ),
              )
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: task),
          ),
        ),
      ),
    );
  }
}
