// lib/core/utils/performance_utils.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceUtils {
  // Debounce utility for search and filtering
  static Timer? _debounceTimer;

  static void debounce(Duration delay, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Memory-efficient image loading
  static Widget buildOptimizedImage({
    required String? imageUrl,
    required double width,
    required double height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return errorWidget ?? Icon(Icons.image_not_supported, size: width);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: width.toInt(),
      cacheHeight: height.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? Icon(Icons.error, size: width);
      },
    );
  }

  // Efficient list building with pagination
  static Widget buildOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    int itemsPerPage = 20,
    ScrollController? controller,
    VoidCallback? onLoadMore,
  }) {
    return ListView.builder(
      controller: controller,
      itemCount: items.length + (onLoadMore != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length && onLoadMore != null) {
          // Load more indicator
          onLoadMore();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return itemBuilder(context, items[index], index);
      },
    );
  }
}


