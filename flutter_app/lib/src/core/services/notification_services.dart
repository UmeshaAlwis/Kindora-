import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

///Handles Firebase Cloud Messaging for the Kindora platform
/// Covers foreground, background, and terminated app states
class NotificationServices {
  static final NotificationServices _instance = NotificationServices._();
  factory NotificationServices() => _instance;
  NotificationServices._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // Initialisation
  // --------------------------------------------------------------------------- 

  Future <void> init (BuildContext context) async {
    // 1. Request permission (iOS + Android 13+)
    await _requestPermission();

    // 2. Initialise local notification channels
    await _initLocalNotifications();

    // 3. Get FCM token and send to backend
    final token = await _fcm.getToken();
    debugPrint('[FCM] Device token: $token');
    // TODO: POST token to your backend → /users/fcm-token

    // 4. Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      //TODO: update backend
    });

    // 5. Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. Background/terminated – message opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 7. App opened from terminated state via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
     final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Auth status: ${settings.authorizationStatus}');
  }

  // ---------------------------------------------------------------------------
  // Local Notifications
  // ---------------------------------------------------------------------------

  Future<void> _initLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null, //use app icon
      [
        NotificationChannel(
          channelGroupKey: 'kindora_messages',
          channelKey: 'messages_channel',
          channelName: 'Messages',
          channelDescription: 'Donor–Charity chat messages',
          defaultColor: const Color(0xFF1A7F6E),
          ledColor: const Color(0xFF1A7F6E),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),

        NotificationChannel(
          channelGroupKey: 'kindora_events',
          channelKey: 'events_channel',
          channelName: 'Events Alerts',
          channelDescription: 'Charity events and campaign updates',
          defaultColor: const Color(0xFFFF6B4A),
          ledColor: const Color(0xFFFF6B4A),
          importance: NotificationImportance.Default,
          channelShowBadge: false,
        ),

         NotificationChannel(
          channelGroupKey: 'kindora_donations',
          channelKey: 'donations_channel',
          channelName: 'Donation Updates',
          channelDescription: 'Donation confirmations and impact reports',
          defaultColor: const Color(0xFF1A7F6E),
          importance: NotificationImportance.Default,
         ),
      ],

      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'kindora_messages',
          channelGroupName: 'Messages',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'kindora_events',
          channelGroupName: 'Events Alerts',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'kindora_donations',
          channelGroupName: 'Donation Updates',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Foreground Handlers
  // ---------------------------------------------------------------------------

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.messageId}');
    final data = message.data;
    final type = data['type'] ?? 'general';

    String channelKey;
    switch (type) {
      case 'new message':
        channelKey = 'messages_channel';
        break;
      case 'event_alert':
        channelKey = 'events_channel';
        break;
      case 'donation_update':
        channelKey = 'donations_channel';
        break;
      default:
        channelKey = 'messages_channel';
    }

    _showLocalNotification(
      title:message.notification?.title ?? 'Kindora',
      body: message.notification?.body ?? '',
      channelKey: channelKey,
      payload:data.map((key, value) => MapEntry(key, value.toString())), 
    );
  }

  // ---------------------------------------------------------------------------
  // Notification opened Handlers
  // ---------------------------------------------------------------------------

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Notification opened app: ${message.data}');
    // TODO: Navigate to the correct screen based on message.data['type']
    // e.g. if type == 'new_message', push ConversationsScreen or ChatScreen
  }

  // ---------------------------------------------------------------------------
  // Local Notification Display
  // ---------------------------------------------------------------------------

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String channelKey,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
        channelKey: channelKey,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //Utility: subscribe / unsubscribe topics
  // ---------------------------------------------------------------------------

  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) => _fcm.unsubscribeFromTopic(topic);
      
}

//---------------------------------------------------------------------------
//Background message handler (must be top-level)
//---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised when this runs
  debugPrint('[FCM] Background message: ${message.messageId}');
}