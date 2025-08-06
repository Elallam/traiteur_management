// lib/services/enhanced_notification_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:io';

class EnhancedNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _notificationsCollection = 'notifications';
  static const String _userTokensCollection = 'user_tokens';

  // Replace with your Firebase project ID
  static const String _projectId = 'traiteurmanagement-bdd43';

  // Service account credentials - you can load this from assets or environment
  static const Map<String, dynamic> _serviceAccountJson = {
    "type": "service_account",
    "project_id": "traiteurmanagement-bdd43",
    "private_key_id": "08332ad9830119b93ea4b681f6afda2380293da1",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDb3IzUX9iFgqod\nY30BFlDOA2bT7VN1nKIcjsfgAsfct1J/UMUg6xfGlradWz2lnpqNWWNkBh9j0z+k\n4SvvwRsnZmTNTZszR2MSN4LU0lGlP7WXpyDn7zExoWU5bW5Czs+9h/U+Sjg5fPe2\nu26IGvzdWkH4WB2y0+0KI9T5EfZp2i3EtD5MLZDcrtBQbTcDqg3dnrvfXi29hTP7\n4asNsPOZLlin7KwRQeHNjBKVzwsdUncHLeq/4NUl0I2u17h+3PVHWhKQUnGnEePL\nvCEkDpLWHSMU7hxfQi+Zi1rKaR3VNHy6ix1rvT2X5lH4zt+ohMejxO+7CDiNGrxw\n8S4oKe/9AgMBAAECggEAJLKkgxJYdrh/opYnmFXcOPbSZA9Z/eieGnwumpJ8P7gN\nuhiGPt9ewZQIeS1wlcNqcqt37osjFCt/lQrMpaEq4iGyM55/iEijHbhMSy+r1xRS\nQDTyRiRjprAU0EgWvmn8vNsDsVj8F4RnaIXShj9S87OMDWLP2jiLeUTP2J8J7VLh\nMMqd/gNVqgZZq8VFBtDy78dNAPEGuzvpoWTM3kzBFVVQR6OtBip/RlGqPH+LOHbN\n58rLus+Iud5EFs/oK/kTLxiDR0e38m8wyjPpmAU1VAnuQyoslqV2LQHK9Omki0Nl\nhR+RHsPhdeVp3sdenYncelW6gdHyGSlqUjNJSNkXdQKBgQD9Mzor7vjlXs6TuqXt\nBiZQ28o8KbHq9ReweNhZScyYyccoVVzVJDd8hMvbxr7MZsWXaf6XGR9c2t9ZlxBE\nNhSoARuNIGBzQtx4+tGorxBlOsoY44D1NQxzSvc87uOyatQUaRTyYiFhtsaADdYM\nIdMkVW3dKhYkAZmqyKoSV6/eBwKBgQDeSvI5qmEqZSOenYat8LzGp8WMvTswCAtL\n7Hpe6kHusES51jO2NoMkaq+V17RBnWRa6GhSs3sECwe3uusGw23e83QItO+Z8b5p\nBz116F8yYAQwkimAixJa6wxoBuU4AJ8/j/G6RshvdfeYt7cCW1FiDiRo6JnO04xo\na17H19EA2wKBgBgPyjNqnlSN0evQDPydXP7KJEnbXIELkZi/oy+5B6xtYHPAyPWo\nX22B4S2dkXwzOAvPktYhGQ3l7tvAs1cIHKZqlIewz/mkHPeSPmJdYJ1+HL6IwDSN\nOgWq1hwAR7so08asxcTS9oEmsW5x4il8/WeyhqJB4aDCViwYrbDYjGn5AoGAVFXa\n0EXz10HH4cWh8xwCgtvj9yFT80UaBBQT2S7HFOeLK3Y46EiGOKrBMvhDSyGLkXHb\nIoU1hrMommwv/sDmTk/PFf6PaLhupSo6ByHB/DqxXDwXws0Aib3jVxRGopiZ0mOq\nMiHoqWD4LtiEdkBu/+Sdq6+TqwRXoMYbj3YxtUECgYAa36PtTbIBa1hsAPWAMEKQ\nVq1woOVQ+g9TlQKfjzmcGnY9olBxxd58KYU03ToyKbWODfT8FEXjDcDuSMpF3No/\njORw3/MS+OaynJuDOf44jhZzKFvB+A5W8MgEqUrQmiQ1anUllP6Ri0Nc1nz5PG4L\nOrZ7IMfsCVNbpI4KlMM4JQ==\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@traiteurmanagement-bdd43.iam.gserviceaccount.com",
    "client_id": "112638135415720211729",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40traiteurmanagement-bdd43.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  // Cache for access token
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;
  Timer? _tokenVerificationTimer;

  // Initialize the notification service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  void startTokenVerification(String userId) {
    _tokenVerificationTimer?.cancel();
    _tokenVerificationTimer = Timer.periodic(Duration(hours: 12), (_) async {
      await _verifyAndUpdateToken(userId);
    });
  }

  Future<void> _verifyAndUpdateToken(String userId) async {
    try {
      final doc = await _firestore.collection(_userTokensCollection).doc(userId).get();
      if (doc.exists) {
        final token = doc.get('token');
        if (token != null) {
          await saveUserToken(userId); // Refresh invalid token
        }
      }
    } catch (e) {
      print('Error verifying token: $e');
    }
  }

// Call this when user logs in
  void initializeForUser(String userId) {
    saveUserToken(userId);
    startTokenVerification(userId);
    // _setupTokenRefreshListener(userId);
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  // Create notification channels for different types
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel equipmentChannel = AndroidNotificationChannel(
      'equipment_checkout',
      'Equipment Checkout Requests',
      description: 'Notifications for equipment checkout requests',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(equipmentChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  // Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  // Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }

  // Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _getChannelId(message.data['type'] ?? 'general'),
            _getChannelName(message.data['type'] ?? 'general'),
            channelDescription: _getChannelDescription(message.data['type'] ?? 'general'),
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Get OAuth 2.0 access token using service account
  Future<String> _getAccessToken() async {
    // Check if we have a valid cached token
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return _cachedAccessToken!;
    }

    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccountJson);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = http.Client();
      try {
        final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
            accountCredentials,
            scopes,
            client
        );

        _cachedAccessToken = accessCredentials.accessToken.data;
        _tokenExpiry = accessCredentials.accessToken.expiry;

        return _cachedAccessToken!;
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error getting access token: $e');
      throw 'Failed to get access token: $e';
    }
  }

  // Get FCM token for current user
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Save user FCM token
  Future<void> saveUserToken(String userId) async {
    if (kIsWeb) return;
    try {
      // Get current token (may be null if permissions not granted)
      String? token = await _firebaseMessaging.getToken();

      if (token == null) {
        // Request permission if not granted (especially important for iOS)
        await _firebaseMessaging.requestPermission();
        token = await _firebaseMessaging.getToken();
      }

      if (token != null) {
        await _firestore.collection(_userTokensCollection).doc(userId).set({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'updatedAt': FieldValue.serverTimestamp(),
          'userId': userId, // Add userId for querying
        }, SetOptions(merge: true));

        print('Successfully saved FCM token for user $userId');
      } else if (token != null) {
        // Token is invalid, remove it
        await removeUserToken(userId);
      }
    } on FirebaseException catch (e) {
      print('Firestore error saving token: ${e.message}');
    } catch (e) {
      print('Unexpected error saving token: $e');
    }
  }

  // Remove user token (on logout)
  Future<void> removeUserToken(String userId) async {
    if(kIsWeb) return;
    try {
      await _firestore.collection(_userTokensCollection).doc(userId).delete();
    } catch (e) {
      print('Error removing user token: $e');
    }
  }

  // Send notification to specific user (both in-app and push)
  Future<String> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    Map<String, dynamic>? data,
    bool sendPush = true,
  }) async {
    try {
      // Create in-app notification
      print("sending notifications to $userId");
      Map<String, dynamic> notification = {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'priority': priority,
        'isRead': false,
        'createdAt': DateTime.now(),
        'data': data ?? {},
      };

      DocumentReference docRef = await _firestore
          .collection(_notificationsCollection)
          .add(notification);

      // Send push notification if requested
      if (sendPush) {
        await _sendPushNotification(
          userId: userId,
          title: title,
          body: message,
          data: {
            'notificationId': docRef.id,
            'type': type,
            ...?data,
          },
        );
      }

      return docRef.id;
    } catch (e) {
      throw 'Failed to send notification: $e';
    }
  }

  // Send equipment checkout request notification
  Future<void> sendEquipmentCheckoutNotification({
    required String employeeId,
    required String employeeName,
    required String requestId,
    required List<Map<String, dynamic>> equipmentList,
    String? occasionId,
    String? occasionTitle,
  }) async {
    try {
      // Get all admin users
      final admins = await _getAdminUsers();

      int totalItems = equipmentList.fold(0, (sum, item) => sum + (item['quantity'] as int));

      String title = 'Equipment Checkout Request';
      String message = '$employeeName requested ${equipmentList.length} equipment types ($totalItems items)';

      // Send notification to each admin
      for (final admin in admins) {
        await sendNotificationToUser(
          userId: admin['id'],
          title: title,
          message: message,
          type: 'equipment_checkout_request',
          priority: 'high',
          data: {
            'requestId': requestId,
            'employeeId': employeeId,
            'employeeName': employeeName,
            'occasionId': occasionId,
            'occasionTitle': occasionTitle,
            'itemCount': equipmentList.length,
            'totalQuantity': totalItems,
            'equipment': equipmentList,
            'action_required': true,
          },
          sendPush: true,
        );
      }
    } catch (e) {
      print('Error sending equipment checkout notification: $e');
      rethrow;
    }
  }

  // Send push notification to specific user
  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // First check if user exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('User $userId does not exist');
        return;
      }

      // Then get token
      DocumentSnapshot tokenDoc = await _firestore
          .collection(_userTokensCollection)
          .doc(userId)
          .get();

      if (!tokenDoc.exists || tokenDoc.get('token') == null) {
        print('No FCM token found for user: $userId - attempting to get fresh token');

        // Try to get fresh token
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.uid == userId) {
          await saveUserToken(userId);
          tokenDoc = await _firestore.collection(_userTokensCollection).doc(userId).get();
        }

        if (!tokenDoc.exists) {
          print('Still no token after refresh - skipping notification');
          return;
        }
      }

      String token = tokenDoc.get('token');
      print('Sending notification to user $userId with token $token');

      await _sendFCMMessage(
        token: token,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error in _sendPushNotification: $e');
    }
  }

  // Send FCM message using HTTP v1 API
  Future<void> _sendFCMMessage({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get OAuth 2.0 access token
      String accessToken = await _getAccessToken();

      // Build the message payload for HTTP v1 API
      Map<String, dynamic> message = {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data?.map((key, value) => MapEntry(key, value.toString())) ?? {},
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': _getChannelId(data?['type'] ?? 'general'),
            'icon': '@mipmap/ic_launcher',
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'alert': {
                'title': title,
                'body': body,
              },
              'badge': 1,
              'sound': 'default',
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
        final responseData = jsonDecode(response.body);
        print('Message ID: ${responseData['name']}');
      } else {
        print('Failed to send FCM message: ${response.statusCode}');
        print('Response: ${response.body}');

        // Handle specific error cases
        if (response.statusCode == 404) {
          print('Invalid registration token - user may have uninstalled the app');
        } else if (response.statusCode == 400) {
          print('Invalid message format or parameters');
        } else if (response.statusCode == 401) {
          print('Authentication error - access token may be invalid');
          // Clear cached token to force refresh
          _cachedAccessToken = null;
          _tokenExpiry = null;
        }
      }
    } catch (e) {
      print('Error sending FCM message: $e');
      rethrow;
    }
  }

  // Send notification to multiple users (batch)
  Future<void> sendBatchNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get access token once for all requests
      String accessToken = await _getAccessToken();

      // Get all user tokens
      QuerySnapshot tokensSnapshot = await _firestore
          .collection(_userTokensCollection)
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      List<String> tokens = tokensSnapshot.docs
          .map((doc) => doc.get('token') as String)
          .toList();

      if (tokens.isEmpty) {
        print('No valid tokens found for batch notification');
        return;
      }

      // Build multicast message
      Map<String, dynamic> message = {
        'tokens': tokens,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data?.map((key, value) => MapEntry(key, value.toString())) ?? {},
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': _getChannelId(type),
            'icon': '@mipmap/ic_launcher',
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'alert': {
                'title': title,
                'body': body,
              },
              'badge': 1,
              'sound': 'default',
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        print('Batch FCM message sent successfully');
        final responseData = jsonDecode(response.body);
        print('Batch response: $responseData');
      } else {
        print('Failed to send batch FCM message: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending batch FCM message: $e');
    }
  }

  // Get all admin users
  Future<List<Map<String, dynamic>>> _getAdminUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();
    } catch (e) {
      print('Error getting admin users: $e');
      return [];
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      Map<String, dynamic> data = jsonDecode(response.payload!);
      _handleNotificationTap(data);
    }
  }

  // Handle notification tap action
  void _handleNotificationTap(Map<String, dynamic> data) {
    String? type = data['type'];

    switch (type) {
      case 'equipment_checkout_request':
      // Navigate to equipment approval screen
      // You can implement navigation logic here
        print('Navigate to equipment approval: ${data['requestId']}');
        break;
      default:
        print('Handle general notification tap: $data');
    }
  }

  // Helper methods for channel management
  String _getChannelId(String type) {
    switch (type) {
      case 'equipment_checkout_request':
        return 'equipment_checkout';
      default:
        return 'general';
    }
  }

  String _getChannelName(String type) {
    switch (type) {
      case 'equipment_checkout_request':
        return 'Equipment Checkout Requests';
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(String type) {
    switch (type) {
      case 'equipment_checkout_request':
        return 'Notifications for equipment checkout requests';
      default:
        return 'General app notifications';
    }
  }

  // Existing methods from your original NotificationService
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();
    } catch (e) {
      throw 'Failed to get notifications: $e';
    }
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': DateTime.now(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> streamUserNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    })
        .toList());
  }

  Stream<int> streamUnreadCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}