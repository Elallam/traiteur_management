import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/employee_provider.dart';
import '../../../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeCardWidget extends StatelessWidget {
  final UserModel employee;
  final EmployeeProvider employeeProvider;
  final Function(String, UserModel) onActionSelected;
  final VoidCallback? onTap;

  const EmployeeCardWidget({
    Key? key,
    required this.employee,
    required this.employeeProvider,
    required this.onActionSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeCheckouts = employeeProvider.getEmployeeActiveCheckouts(employee.id);
    final overdueCheckouts = employeeProvider.getEmployeeOverdueCheckouts(employee.id);
    final performance = employeeProvider.getEmployeePerformance(employee.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: employee.isActive
                        ? AppColors.primary
                        : AppColors.grey,
                    child: Text(
                      employee.fullName.isNotEmpty
                          ? employee.fullName[0].toUpperCase()
                          : 'E',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Employee Info
                  Expanded(
                    child: _buildEmployeeInfo(context, l10n),
                  ),
                  // Actions Menu
                  _buildActionsMenu(context, l10n),
                ],
              ),
              const SizedBox(height: 12),
              // Quick Stats Row
              _buildQuickStats(context, l10n, activeCheckouts, overdueCheckouts, performance),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                employee.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: employee.isActive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                employee.isActive ? l10n.active : l10n.inactive,
                style: TextStyle(
                  color: employee.isActive
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          employee.email,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          employee.phone,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      onSelected: (value) => onActionSelected(value, employee),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 18),
              const SizedBox(width: 8),
              Text(l10n.viewDetails),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit, size: 18),
              const SizedBox(width: 8),
              Text(l10n.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'checkouts',
          child: Row(
            children: [
              const Icon(Icons.inventory, size: 18),
              const SizedBox(width: 8),
              Text(l10n.viewCheckouts),
            ],
          ),
        ),
        PopupMenuItem(
          value: employee.isActive ? 'deactivate' : 'activate',
          child: Row(
            children: [
              Icon(
                employee.isActive ? Icons.block : Icons.check_circle,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(employee.isActive ? l10n.deactivate : l10n.activate),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, size: 18, color: AppColors.error),
              const SizedBox(width: 8),
              Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
      BuildContext context,
      AppLocalizations l10n,
      List activeCheckouts,
      List overdueCheckouts,
      Map performance,
      ) {
    return Row(
      children: [
        _buildQuickStat(
          l10n.activeCheckouts,
          activeCheckouts.length.toString(),
          activeCheckouts.isNotEmpty ? AppColors.info : AppColors.textSecondary,
        ),
        const SizedBox(width: 16),
        _buildQuickStat(
          l10n.overdue,
          overdueCheckouts.length.toString(),
          overdueCheckouts.isNotEmpty ? AppColors.error : AppColors.textSecondary,
        ),
        const SizedBox(width: 16),
        _buildQuickStat(
          l10n.totalCheckouts,
          performance['totalCheckouts'].toString(),
          AppColors.textSecondary,
        ),
        const Spacer(),
        if (overdueCheckouts.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, color: AppColors.error, size: 14),
                const SizedBox(width: 4),
                Text(
                  l10n.needsAttention,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}