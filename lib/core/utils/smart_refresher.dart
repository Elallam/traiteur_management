// lib/core/widgets/smart_refresher.dart
import 'package:flutter/material.dart';

class SmartRefresher extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Duration minRefreshInterval;

  const SmartRefresher({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.minRefreshInterval = const Duration(seconds: 30),
  }) : super(key: key);

  @override
  State<SmartRefresher> createState() => _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  DateTime? _lastRefresh;
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    final now = DateTime.now();

    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < widget.minRefreshInterval) {
      return; // Too soon to refresh again
    }

    if (_isRefreshing) return; // Already refreshing

    setState(() => _isRefreshing = true);

    try {
      await widget.onRefresh();
      _lastRefresh = now;
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: widget.child,
    );
  }
}