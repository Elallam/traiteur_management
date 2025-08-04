// core/widgets/admin/occasion/add_edit_occasion/basic_info_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicInfoTab extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onDateSelected;
  final VoidCallback onTimeSelected;

  const BasicInfoTab({
    super.key,
    required this.controllers,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: controllers['title'],
            decoration: const InputDecoration(labelText: 'Event Title'),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          // ... other fields similar to original

          // Date and Time
          Row(
            children: [
              Expanded(child: _buildDateField()),
              const SizedBox(width: 16),
              Expanded(child: _buildTimeField(context)),
            ],
          ),
          // ... rest of the basic info fields
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Date'),
        InkWell(
          onTap: onDateSelected,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Time'),
        InkWell(
          onTap: onTimeSelected,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(selectedTime.format(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}