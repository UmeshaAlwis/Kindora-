import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindora/config/themes/app_colors.dart';
import '../services/notification_service.dart';

/// AppBar-style bell with unread badge; opens `/notifications` and refreshes count on return.
class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  final NotificationService _notificationService = NotificationService();
  int _unreadNotifications = 0;
  bool _loadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _fetchUnreadNotifications();
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final unread = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotifications = unread;
          _loadingNotifications = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 28,
          ),
          if (!_loadingNotifications && _unreadNotifications > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _unreadNotifications > 99
                        ? '99+'
                        : _unreadNotifications.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () async {
        await context.push('/notifications');
        _fetchUnreadNotifications();
      },
    );
  }
}
