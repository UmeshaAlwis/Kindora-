import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(Icons.notifications, color: Colors.indigo),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}