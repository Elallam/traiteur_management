import 'package:flutter/material.dart';

// lib/core/widgets/optimized_tab_bar.dart
class OptimizedTabBarView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  final bool keepAlive;

  const OptimizedTabBarView({
    Key? key,
    required this.controller,
    required this.children,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  State<OptimizedTabBarView> createState() => _OptimizedTabBarViewState();
}

class _OptimizedTabBarViewState extends State<OptimizedTabBarView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.controller,
      children: widget.children.map((child) {
        return widget.keepAlive
            ? _KeepAliveWrapper(child: child)
            : child;
      }).toList(),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _CachedTabWidget extends StatefulWidget {
  final Widget child;

  const _CachedTabWidget({required this.child});

  @override
  State<_CachedTabWidget> createState() => _CachedTabWidgetState();
}

class _CachedTabWidgetState extends State<_CachedTabWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}