import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeEmptyStateWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onAddEmployee;

  const EmployeeEmptyStateWidget({
    Key? key,
    required this.searchQuery,
    this.onAddEmployee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty
                ? l10n.noEmployeesFoundSearch(searchQuery)
                : l10n.noEmployeesFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? l10n.adjustSearchFilters
                : l10n.addFirstEmployeeHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (searchQuery.isEmpty && onAddEmployee != null)
            ElevatedButton.icon(
              onPressed: onAddEmployee,
              icon: const Icon(Icons.add),
              label: Text(l10n.addEmployee),
            ),
        ],
      ),
    );
  }
}