import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'interfaces/notification_service_interface.dart';
import 'models/notification_models.dart';

/// Top-level function for handling background messages
/// Must be top-level function for Firebase to call it
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // You can add additional background processing here if needed
  // Note: UI operations are not allowed in background handlers
}

/// Concrete implementation of notification service
/// Follows Single Responsibility Principle - handles only notification logic
class NotificationService implements INotificationService {
  // Private constructor for singleton pattern
  NotificationService._();

  static NotificationService? _instance;

  /// Factory constructor for dependency injection
  factory NotificationService() {
    _instance ??= NotificationService._();
    return _instance!;
  }

  // Dependencies
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Stream controllers for reactive programming
  final StreamController<String> _onTokenRefreshController =
  StreamController<String>.broadcast();
  final StreamController<NotificationPayload> _onForegroundMessageController =
  StreamController<NotificationPayload>.broadcast();
  final StreamController<NotificationPayload> _onMessageTapController =
  StreamController<NotificationPayload>.broadcast();

  // Private state
  bool _isInitialized = false;
  String? _currentToken;

  // Public streams - following Open/Closed Principle
  @override
  Stream<String> get onTokenRefresh => _onTokenRefreshController.stream;

  @override
  Stream<NotificationPayload> get onForegroundMessage =>
      _onForegroundMessageController.stream;

  @override
  Stream<NotificationPayload> get onMessageTap =>
      _onMessageTapController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await requestPermissions();

      // Get initial token
      _currentToken = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $_currentToken");

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _currentToken = token;
        _onTokenRefreshController.add(token);
        debugPrint("FCM Token refreshed: $token");
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle messages when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      // Handle initial message if app was terminated and opened via notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint("NotificationService initialized successfully");

    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
      rethrow;
    }
  }

  /// Initialize local notifications with platform-specific settings
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel highImportanceChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel defaultChannel =
    AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'This channel is used for default notifications.',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint("Received foreground message: ${message.messageId}");

    final payload = NotificationPayload.fromRemoteMessage(message);

    // Show local notification for foreground messages
    showLocalNotification(payload);

    // Emit to stream for UI updates
    _onForegroundMessageController.add(payload);
  }

  /// Handle message tap events
  void _handleMessageTap(RemoteMessage message) {
    debugPrint("Message tapped: ${message.messageId}");

    final payload = NotificationPayload.fromRemoteMessage(message);
    _onMessageTapController.add(payload);
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint("Local notification tapped: ${response.id}");

    if (response.payload != null) {
      try {
        final payloadData = jsonDecode(response.payload!);
        final payload = NotificationPayload.fromJson(payloadData);
        _onMessageTapController.add(payload);
      } catch (e) {
        debugPrint("Error parsing notification payload: $e");
      }
    }
  }

  @override
  Future<String?> getToken() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _currentToken ?? await _firebaseMessaging.getToken();
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final NotificationSettings settings =
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final bool isAuthorized = settings.authorizationStatus ==
          AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint("Notification permission status: ${settings.authorizationStatus}");
      return isAuthorized;

    } catch (e) {
      debugPrint("Error requesting notification permissions: $e");
      return false;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint("Subscribed to topic: $topic");
    } catch (e) {
      debugPrint("Error subscribing to topic $topic: $e");
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint("Unsubscribed from topic: $topic");
    } catch (e) {
      debugPrint("Error unsubscribing from topic $topic: $e");
      rethrow;
    }
  }

  @override
  Future<void> showLocalNotification(NotificationPayload payload) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        channelDescription: 'This channel is used for default notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        payload.title,
        payload.body,
        platformDetails,
        payload: jsonEncode(payload.toJson()),
      );

    } catch (e) {
      debugPrint("Error showing local notification: $e");
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint("All notifications cleared");
    } catch (e) {
      debugPrint("Error clearing notifications: $e");
    }
  }

  @override
  void dispose() {
    _onTokenRefreshController.close();
    _onForegroundMessageController.close();
    _onMessageTapController.close();
    _isInitialized = false;
    debugPrint("NotificationService disposed");
  }
}