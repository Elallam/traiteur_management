// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _notificationsCollection = 'notifications';

  /// Send a notification to a specific user
  Future<String> sendNotification(Map<String, dynamic> notification) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_notificationsCollection)
          .add(notification);
      return docRef.id;
    } catch (e) {
      throw 'Failed to send notification: $e';
    }
  }

  /// Get notifications for a specific user
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

  /// Get unread notifications count for a user
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

  /// Mark notification as read
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

  /// Mark all notifications as read for a user
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

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  /// Stream notifications for real-time updates
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

  /// Stream unread count for real-time updates
  Stream<int> streamUnreadCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Send notification to multiple users
  Future<void> sendBulkNotification(
      List<String> userIds,
      String title,
      String message,
      String type, {
        String priority = 'medium',
        Map<String, dynamic>? data,
      }) async {
    try {
      WriteBatch batch = _firestore.batch();
      DateTime now = DateTime.now();

      for (String userId in userIds) {
        DocumentReference docRef = _firestore
            .collection(_notificationsCollection)
            .doc();

        batch.set(docRef, {
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'priority': priority,
          'isRead': false,
          'createdAt': now,
          'data': data ?? {},
        });
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to send bulk notification: $e';
    }
  }

  /// Clean up old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    try {
      DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      QuerySnapshot snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('createdAt', isLessThan: thirtyDaysAgo)
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to cleanup old notifications: $e';
    }
  }
}