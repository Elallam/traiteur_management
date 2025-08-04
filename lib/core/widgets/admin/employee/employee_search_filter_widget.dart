import 'package:flutter/material.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

import '../../../constants/app_colors.dart';

class EmployeeSearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String filterStatus;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback? onClearSearch;

  const EmployeeSearchFilterWidget({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onFilterChanged,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: l10n.searchEmployeeHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClearSearch,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            children: [
              _buildFilterChip(l10n.allGood.split(' ')[1], 'all'),
              const SizedBox(width: 8),
              _buildFilterChip(l10n.active, 'active'),
              const SizedBox(width: 8),
              _buildFilterChip(l10n.inactive, 'inactive'),
              const Spacer(),
              // Sort options
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: AppColors.primary),
                onSelected: (value) {
                  // TODO: Implement sorting callback
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'name', child: Text(l10n.sortByName)),
                  PopupMenuItem(value: 'date', child: Text(l10n.sortByDate)),
                  PopupMenuItem(value: 'checkouts', child: Text(l10n.sortByCheckouts)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onFilterChanged(value),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}