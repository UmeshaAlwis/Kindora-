import 'package:flutter/material.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/notification_icon.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: NotificationIcon(count: 3),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationCard(
            title: "New Donation",
            message: "Someone donated \$50 to Clean Water Campaign",
            time: "2m ago",
          ),
          NotificationCard(
            title: "Campaign Update",
            message: "School Supply Campaign reached 80%",
            time: "10m ago",
          ),
        ],
      ),
      
    );
  }
}