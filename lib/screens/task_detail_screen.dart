// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/screens/add_edit_task_screen.dart';
import 'package:task_manager_app/widgets/dialogs.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isDeleting = false; // 🔹 To show loader and disable delete button

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // 🔹 Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit Task",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: widget.task),
                ),
              );
            },
          ),

          // 🔹 Delete button with loader
          IconButton(
            tooltip: "Delete Task",
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting
                ? null
                : () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Task"),
                        content: const Text(
                          "Are you sure you want to delete this task?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      setState(() => _isDeleting = true);

                      await provider.deleteTask(widget.task.id);
                      await showSuccessDialog(
                        context,
                        title: "Task Deleted",
                        message: "The task has been removed successfully.",
                        icon: Icons.delete,
                        iconColor: Colors.red,
                      );

                      setState(() => _isDeleting = false);
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      ),

      // 🔹 Task details content
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.task.dueDate != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Due Date: ${DateFormat('MMMM d, y').format(widget.task.dueDate!)}",
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                    const Row(
                      children: [
                        Icon(Icons.flag, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Priority: High"), // static for now
                      ],
                    ),
                    const Divider(),
                    if (widget.task.description != null &&
                        widget.task.description!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notes,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.task.description!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const Text(
                        "No description added.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
