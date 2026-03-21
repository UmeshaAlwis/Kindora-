import 'package:kindora/config/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:kindora/l10n/app_localizations.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _service = NotificationService();

  late Future<List<AppNotification>> _notificationsFuture;
  bool _markingRead = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _service.getNotifications(page: 1, limit: 50);

    // Mark as read when the user opens the page.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _markingRead = true);
      try {
        await _service.markAllRead();
      } catch (_) {
        // Best-effort: don't block UI.
      } finally {
        if (mounted) setState(() => _markingRead = false);
        if (mounted) {
          setState(() {
            _notificationsFuture =
                _service.getNotifications(page: 1, limit: 50);
          });
        }
      }
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _notificationsFuture = _service.getNotifications(page: 1, limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_markingRead)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<AppNotification>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Failed to load notifications: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('No notifications yet')),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    leading: Icon(
                      n.isRead ? Icons.notifications_none : Icons.notifications,
                      color: n.isRead ? Colors.grey : const Color(0xFFFF751F),
                    ),
                    title: Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: (n.body == null || n.body!.isEmpty)
                        ? null
                        : Text(
                            n.body!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    trailing: Text(
                      _formatTime(n.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      // Best-effort: mark all as read and refresh.
                      if (n.isRead) return;
                      _service.markAllRead().then((_) => _refresh()).catchError((_) {});
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

