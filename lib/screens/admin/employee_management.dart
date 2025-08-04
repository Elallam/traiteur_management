import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/admin/employee/add_edit_employee_widget.dart';
import '../../core/widgets/admin/employee/employee_analytics_widget.dart';
import '../../core/widgets/admin/employee/employee_card_widget.dart';
import '../../core/widgets/admin/employee/employee_details_widget.dart';
import '../../core/widgets/admin/employee/employee_empty_state_widget.dart';
import '../../core/widgets/admin/employee/employee_search_filter_widget.dart';
import '../../core/widgets/admin/employee/employee_statistics_widget.dart';
import '../../models/user_model.dart';
import '../../providers/employee_provider.dart';
import '../../core/widgets/loading_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  Future<void> _loadEmployees() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.loadAllEmployeeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.employeeManagement),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadEmployees,
          tooltip: l10n.refresh,
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showEmployeeAnalytics,
          tooltip: l10n.analytics,
        ),
      ],
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return LoadingWidget(message: '${l10n.loading} ${l10n.employees}...');
        }

        return Column(
          children: [
            // Search and Filter Widget
            EmployeeSearchFilterWidget(
              searchController: _searchController,
              searchQuery: _searchQuery,
              filterStatus: _filterStatus,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterChanged: (value) {
                setState(() {
                  _filterStatus = value;
                });
              },
              onClearSearch: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),

            // Statistics Widget
            EmployeeStatisticsWidget(employeeProvider: employeeProvider),

            // Employee List
            Expanded(
              child: _buildEmployeeList(employeeProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeList(EmployeeProvider employeeProvider) {
    List<UserModel> employees = _getFilteredEmployees(employeeProvider);

    if (employees.isEmpty) {
      return EmployeeEmptyStateWidget(
        searchQuery: _searchQuery,
        onAddEmployee: _showAddEmployeeDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return EmployeeCardWidget(
            employee: employees[index],
            employeeProvider: employeeProvider,
            onActionSelected: _handleEmployeeAction,
            onTap: () => _showEmployeeDetails(employees[index], employeeProvider),
          );
        },
      ),
    );
  }

  List<UserModel> _getFilteredEmployees(EmployeeProvider employeeProvider) {
    List<UserModel> employees = employeeProvider.employees;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      employees = employeeProvider.searchEmployees(_searchQuery);
    }

    // Apply status filter
    switch (_filterStatus) {
      case 'active':
        employees = employees.where((emp) => emp.isActive).toList();
        break;
      case 'inactive':
        employees = employees.where((emp) => !emp.isActive).toList();
        break;
      default:
      // Show all
        break;
    }

    return employees;
  }

  Widget _buildFloatingActionButton() {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: _showAddEmployeeDialog,
      backgroundColor: AppColors.secondary,
      child: Icon(Icons.add, color: AppColors.white, semanticLabel: l10n.addEmployee),
    );
  }

  void _handleEmployeeAction(String action, UserModel employee) {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    switch (action) {
      case 'view':
        _showEmployeeDetails(employee, employeeProvider);
        break;
      case 'edit':
        _showEditEmployeeDialog(employee);
        break;
      case 'checkouts':
        _showEmployeeCheckouts(employee);
        break;
      case 'activate':
      case 'deactivate':
        _toggleEmployeeStatus(employee, employeeProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(employee, employeeProvider);
        break;
    }
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditEmployeeWidget(),
    ).then((result) {
      if (result == true) {
        _loadEmployees();
      }
    });
  }

  void _showEditEmployeeDialog(UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AddEditEmployeeWidget(employee: employee),
    ).then((result) {
      if (result == true) {
        _loadEmployees();
      }
    });
  }

  void _showEmployeeDetails(UserModel employee, EmployeeProvider employeeProvider) {
    showDialog(
      context: context,
      builder: (context) => EmployeeDetailsWidget(
        employee: employee,
        employeeProvider: employeeProvider,
      ),
    );
  }

  void _showEmployeeCheckouts(UserModel employee) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.employeeCheckoutsComingSoon(employee.fullName)),
      ),
    );
  }

  void _toggleEmployeeStatus(UserModel employee, EmployeeProvider employeeProvider) async {
    final l10n = AppLocalizations.of(context)!;
    final updatedEmployee = employee.copyWith(isActive: !employee.isActive);
    final success = await employeeProvider.updateEmployee(updatedEmployee);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employee.isActive ? l10n.employeeDeactivatedSuccess : l10n.employeeActivatedSuccess,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employeeProvider.errorMessage ?? l10n.failedToUpdateEmployeeStatus,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteConfirmation(UserModel employee, EmployeeProvider employeeProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEmployee),
        content: Text(
          l10n.deleteEmployeeConfirmation(employee.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await employeeProvider.deleteEmployee(employee.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.employeeDeletedSuccess),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      employeeProvider.errorMessage ?? l10n.failedToDeleteEmployee,
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showEmployeeAnalytics() {
    showDialog(
      context: context,
      builder: (context) => const EmployeeAnalyticsWidget(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}