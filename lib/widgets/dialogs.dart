import 'package:flutter/material.dart';

Future<void> showSuccessDialog(BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.check_circle,
  Color iconColor = Colors.green,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK", style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
