// lib/core/widgets/optimized_future_builder.dart
import 'package:flutter/material.dart';

class OptimizedFutureBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Duration cacheDuration;

  const OptimizedFutureBuilder({
    Key? key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.cacheDuration = const Duration(minutes: 5),
  }) : super(key: key);

  @override
  State<OptimizedFutureBuilder<T>> createState() => _OptimizedFutureBuilderState<T>();
}

class _OptimizedFutureBuilderState<T> extends State<OptimizedFutureBuilder<T>> {
  static final Map<String, _CachedData> _cache = {};
  late final String _cacheKey;
  Future<T>? _currentFuture;

  @override
  void initState() {
    super.initState();
    _cacheKey = widget.future.toString();
    _initializeFuture();
  }

  void _initializeFuture() {
    final cached = _cache[_cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < widget.cacheDuration) {
      _currentFuture = Future.value(cached.data as T);
    } else {
      _currentFuture = widget.future.then((data) {
        _cache[_cacheKey] = _CachedData(data, DateTime.now());
        return data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _currentFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data!);
        }

        return widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _CachedData {
  final dynamic data;
  final DateTime timestamp;

  _CachedData(this.data, this.timestamp);
}