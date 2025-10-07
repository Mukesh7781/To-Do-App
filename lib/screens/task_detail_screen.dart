// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/widgets/dialogs.dart';
import 'package:task_manager_app/widgets/add_edit_task_modal.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 6, // was 1
        shadowColor: Colors.black.withOpacity(0.40),
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
        actions: [
          // ✏️ Edit button
          IconButton(
            tooltip: "Edit Task",
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                clipBehavior: Clip.antiAlias,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) {
                  final bottom = MediaQuery.of(ctx).viewInsets.bottom;
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.7,
                      minChildSize: 0.45,
                      maxChildSize: 0.95,
                      builder: (_, scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: AddEditTaskModal(task: widget.task),
                        );
                      },
                    ),
                  );
                },
              );

              // Refresh after editing
              final updatedTask = provider.filteredTasks.firstWhere(
                (t) => t.id == widget.task.id,
                orElse: () => widget.task,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(task: updatedTask),
                ),
              );
            },
          ),

          // 🗑 Delete button
          IconButton(
            tooltip: "Delete Task",
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: _isDeleting
                ? null
                : () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          "Delete Task?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this task? This action cannot be undone.",
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
                              style: TextStyle(color: Colors.redAccent),
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
                        icon: Icons.delete_outline,
                        iconColor: Colors.redAccent,
                      );

                      setState(() => _isDeleting = false);
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      ),

      // 📄 Task details content (UPDATED: scroll-enabled)
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Task title
                    Text(
                      widget.task.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Card with details
                    Card(
                      color: Colors.white,
                      shadowColor: Colors.black.withOpacity(0.40),
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.task.dueDate != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 20, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Due: ${DateFormat('MMM d, y').format(widget.task.dueDate!)}",
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              const Divider(height: 24, color: Colors.grey),
                            ],

                            // 🔹 Priority (placeholder for now)
                            const Row(
                              children: [
                                Icon(Icons.flag_outlined,
                                    size: 20, color: Colors.black54),
                                SizedBox(width: 8),
                                Text("Priority: High",
                                    style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                            const Divider(height: 24, color: Colors.grey),

                            // 🔹 Description
                            if (widget.task.description != null &&
                                widget.task.description!.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.notes_outlined,
                                      size: 20, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.task.description!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              const Text(
                                "No description added.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
