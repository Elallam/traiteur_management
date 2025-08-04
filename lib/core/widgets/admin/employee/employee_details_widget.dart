import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/employee_provider.dart';
import '../../../constants/app_colors.dart';
import 'add_edit_employee_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeDetailsWidget extends StatelessWidget {
  final UserModel employee;
  final EmployeeProvider employeeProvider;

  const EmployeeDetailsWidget({
    Key? key,
    required this.employee,
    required this.employeeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final performance = employeeProvider.getEmployeePerformance(employee.id);
    final activeCheckouts = employeeProvider.getEmployeeActiveCheckouts(
        employee.id);
    final overdueCheckouts = employeeProvider.getEmployeeOverdueCheckouts(
        employee.id);

    return AlertDialog(
      title: Text(employee.fullName),
      content: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.6,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Info
              _buildEmployeeInfoSection(l10n),
              const SizedBox(height: 16),

              // Performance Stats
              _buildPerformanceSection(l10n, performance),
              const SizedBox(height: 16),

              // Current Checkouts
              if (activeCheckouts.isNotEmpty) ...[
                _buildCurrentCheckoutsSection(l10n, activeCheckouts),
                const SizedBox(height: 16),
              ],

              // Overdue Items
              if (overdueCheckouts.isNotEmpty)
                _buildOverdueItemsSection(l10n, overdueCheckouts),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
        ElevatedButton(
          onPressed: () => _editEmployee(context),
          child: Text(l10n.editEmployee),
        ),
      ],
    );
  }

  Widget _buildEmployeeInfoSection(AppLocalizations l10n) {
    return _buildInfoSection(
      l10n.employeeInformation,
      [
        _buildInfoRow(l10n.email, employee.email),
        _buildInfoRow(l10n.employeePhone, employee.phone),
        _buildInfoRow(l10n.address, employee.address),
        _buildInfoRow(l10n.employeeRole, employee.role.toUpperCase()),
        _buildInfoRow(l10n.employeeStatus,
            employee.isActive ? l10n.active : l10n.inactive),
        _buildInfoRow(l10n.joined, _formatDate(employee.createdAt)),
      ],
    );
  }

  Widget _buildPerformanceSection(AppLocalizations l10n, Map performance) {
    return _buildInfoSection(
      l10n.performanceStatistics,
      [
        _buildInfoRow(
            l10n.totalCheckouts, performance['totalCheckouts'].toString()),
        _buildInfoRow(
            l10n.activeCheckouts, performance['activeCheckouts'].toString()),
        _buildInfoRow(l10n.completedCheckouts,
            performance['completedCheckouts'].toString()),
        _buildInfoRow(
            l10n.overdueItems, performance['overdueCheckouts'].toString()),
        _buildInfoRow(l10n.reliabilityScore,
            '${performance['reliabilityScore'].toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildCurrentCheckoutsSection(AppLocalizations l10n,
      List activeCheckouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.currentCheckouts),
        const SizedBox(height: 8),
        ...activeCheckouts.map((checkout) =>
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory, color: AppColors.info),
                title: Text('${l10n.equipmentId}: ${checkout.equipmentId}'),
                subtitle: Text('${l10n.quantity}: ${checkout.quantity} • ${l10n
                    .checkedOut}: ${_formatDate(checkout.checkoutDate)}'),
                trailing: checkout.isOverdue
                    ? const Icon(Icons.warning, color: AppColors.error)
                    : null,
              ),
            )),
      ],
    );
  }

  Widget _buildOverdueItemsSection(AppLocalizations l10n,
      List overdueCheckouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('⚠️ ${l10n.overdueItems}'),
        const SizedBox(height: 8),
        ...overdueCheckouts.map((checkout) =>
            Card(
              color: AppColors.error.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.warning, color: AppColors.error),
                title: Text('${l10n.equipmentId}: ${checkout.equipmentId}'),
                subtitle: Text(
                    l10n.overdueByDays(DateTime
                        .now()
                        .difference(checkout.checkoutDate)
                        .inDays)
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editEmployee(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AddEditEmployeeWidget(employee: employee),
    ).then((result) async {
      if (result == true) {
        final employeeProvider = Provider.of<EmployeeProvider>(
            context, listen: false);
        await employeeProvider.loadAllEmployeeData();
      }
    });
  }
}