// core/widgets/admin/occasion/add_edit_occasion/tabs_header.dart
import 'package:flutter/material.dart';

class TabsHeader extends StatelessWidget {
  final String title;
  final TabController tabController;
  final VoidCallback onClose;

  const TabsHeader({
    super.key,
    required this.title,
    required this.tabController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Meals'),
            Tab(text: 'Equipment'),
            Tab(text: 'Financial'),
          ],
        ),
      ],
    );
  }
}