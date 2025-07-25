import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomErrorWidget({
    Key? key,
    this.title,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (iconColor ?? AppColors.error).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.error).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: iconColor ?? AppColors.error,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Action Button
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: actionText!,
              onPressed: onAction,
              backgroundColor: iconColor ?? AppColors.error,
              width: 120,
              height: 40,
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      actionText: 'Retry',
      onAction: onRetry,
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? itemName;
  final VoidCallback? onAction;
  final String? actionText;

  const NotFoundErrorWidget({
    Key? key,
    this.itemName,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Not Found',
      message: itemName != null
          ? 'No $itemName found.'
          : 'The requested item was not found.',
      icon: Icons.search_off,
      iconColor: AppColors.info,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title,
      message: message,
      icon: icon ?? Icons.inbox_outlined,
      iconColor: AppColors.textSecondary,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final String? permissionName;
  final VoidCallback? onGrantPermission;

  const PermissionErrorWidget({
    Key? key,
    this.permissionName,
    this.onGrantPermission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Permission Required',
      message: permissionName != null
          ? 'This feature requires $permissionName permission to work properly.'
          : 'This feature requires additional permissions to work properly.',
      icon: Icons.lock_outline,
      iconColor: AppColors.warning,
      actionText: 'Grant Permission',
      onAction: onGrantPermission,
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const LoadingErrorWidget({
    Key? key,
    this.title,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title ?? 'Loading Failed',
      message: message ?? 'Failed to load data. Please try again.',
      icon: Icons.refresh,
      iconColor: AppColors.error,
      actionText: 'Retry',
      onAction: onRetry,
    );
  }
}

// Compact error widget for inline use
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: AppColors.error,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Success widget for positive feedback
class SuccessWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const SuccessWidget({
    Key? key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title,
      message: message,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

// Warning widget
class WarningWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const WarningWidget({
    Key? key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title,
      message: message,
      icon: Icons.warning_outlined,
      iconColor: AppColors.warning,
      actionText: actionText,
      onAction: onAction,
    );
  }
}

// Info widget
class InfoWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const InfoWidget({
    Key? key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: title,
      message: message,
      icon: Icons.info_outline,
      iconColor: AppColors.info,
      actionText: actionText,
      onAction: onAction,
    );
  }
}