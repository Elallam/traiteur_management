// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/enhanced_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final EnhancedNotificationService _notificationService = EnhancedNotificationService();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription<List<Map<String, dynamic>>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasUnreadNotifications => _unreadCount > 0;

  // Initialize notification service and setup streams
  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize the notification service
      if (!kIsWeb) {
        await _notificationService.initialize();

        // Save user token for push notifications
        await _notificationService.saveUserToken(userId);
      }

      // Setup real-time streams
      _setupNotificationStreams(userId);

    } catch (e) {
      print('Error initializing notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup real-time streams for notifications
  void _setupNotificationStreams(String userId) {
    // Stream notifications
    _notificationsSubscription = _notificationService
        .streamUserNotifications(userId)
        .listen(
          (notifications) {
        _notifications = notifications;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming notifications: $error');
      },
    );

    // Stream unread count
    _unreadCountSubscription = _notificationService
        .streamUnreadCount(userId)
        .listen(
          (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        print('Error streaming unread count: $error');
      },
    );
  }

  // Load notifications manually
  Future<void> loadNotifications(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final notifications = await _notificationService.getUserNotifications(userId);
      final unreadCount = await _notificationService.getUnreadNotificationsCount(userId);

      _notifications = notifications;
      _unreadCount = unreadCount;
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state immediately for better UX
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1 && !_notifications[index]['isRead']) {
        _notifications[index]['isRead'] = true;
        _notifications[index]['readAt'] = DateTime.now();
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);

      // Update local state
      for (var notification in _notifications) {
        if (!notification['isRead']) {
          notification['isRead'] = true;
          notification['readAt'] = DateTime.now();
        }
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return _notifications.where((n) => n['type'] == type).toList();
  }

  // Get unread notifications
  List<Map<String, dynamic>> getUnreadNotifications() {
    return _notifications.where((n) => !n['isRead']).toList();
  }

  // Get equipment checkout request notifications
  List<Map<String, dynamic>> getEquipmentCheckoutRequests() {
    return getNotificationsByType('equipment_checkout_request');
  }

  // Get pending equipment requests count
  int getPendingEquipmentRequestsCount() {
    return getEquipmentCheckoutRequests()
        .where((n) => !n['isRead'] && (n['data']?['action_required'] ?? false))
        .length;
  }

  // Clear all notifications (admin only)
  Future<void> clearAllNotifications(String userId) async {
    try {
      // You might want to implement this in your service
      // For now, just mark all as read
      await markAllAsRead(userId);
    } catch (e) {
      print('Error clearing all notifications: $e');
    }
  }

  // Cleanup when user logs out
  Future<void> cleanup(String userId) async {
    try {
      // Cancel subscriptions
      await _notificationsSubscription?.cancel();
      await _unreadCountSubscription?.cancel();

      // Remove user token
      if (!kIsWeb) {
        await _notificationService.removeUserToken(userId);
      }

      // Clear local state
      _notifications.clear();
      _unreadCount = 0;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      print('Error during notification cleanup: $e');
    }
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}