// lib/core/error/error_handler.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_error.dart';

class AppErrorHandler {
  static AppError handleException(dynamic exception) {
    if (exception is AppError) {
      return exception;
    }

    // Firebase Auth errors
    if (exception is FirebaseAuthException) {
      return _handleFirebaseAuthError(exception);
    }

    // Firestore errors
    if (exception is FirebaseException) {
      return _handleFirebaseError(exception);
    }

    // Network errors
    if (exception.toString().contains('SocketException') ||
        exception.toString().contains('TimeoutException')) {
      return const NetworkError(
        'Network connection failed. Please check your internet connection.',
        code: 'NETWORK_ERROR',
      );
    }

    // Generic error
    return AppError(
      'An unexpected error occurred. Please try again.',
      code: 'UNKNOWN_ERROR',
      details: exception.toString(),
    );
  }

  static AuthenticationError _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthenticationError(
          'No user found with this email address.',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthenticationError(
          'Incorrect password. Please try again.',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const AuthenticationError(
          'An account already exists with this email address.',
          code: 'EMAIL_IN_USE',
        );
      case 'weak-password':
        return const AuthenticationError(
          'Password is too weak. Please choose a stronger password.',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return const AuthenticationError(
          'Please enter a valid email address.',
          code: 'INVALID_EMAIL',
        );
      case 'user-disabled':
        return const AuthenticationError(
          'This account has been disabled. Please contact support.',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthenticationError(
          'Too many failed attempts. Please try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      default:
        return AuthenticationError(
          'Authentication failed: ${e.message}',
          code: e.code.toUpperCase(),
        );
    }
  }

  static AppError _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const AuthenticationError(
          'You don\'t have permission to perform this action.',
          code: 'PERMISSION_DENIED',
        );
      case 'not-found':
        return const StorageError(
          'The requested resource was not found.',
          code: 'NOT_FOUND',
        );
      case 'already-exists':
        return const StorageError(
          'A resource with this identifier already exists.',
          code: 'ALREADY_EXISTS',
        );
      case 'unavailable':
        return const NetworkError(
          'Service is temporarily unavailable. Please try again.',
          code: 'SERVICE_UNAVAILABLE',
        );
      case 'deadline-exceeded':
        return const NetworkError(
          'Request timed out. Please try again.',
          code: 'TIMEOUT',
        );
      default:
        return StorageError(
          'Database error: ${e.message}',
          code: e.code.toUpperCase(),
        );
    }
  }
}