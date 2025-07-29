import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

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
      title: Text(l10n.employeeManagement), // Localized title
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadEmployees,
          tooltip: l10n.refresh, // Localized tooltip
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showEmployeeAnalytics,
          tooltip: l10n.analytics, // Localized tooltip
        ),
      ],
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return LoadingWidget(message: '${l10n.loading} ${l10n.employees}...'); // Localized loading message
        }

        return Column(
          children: [
            _buildSearchAndFilter(),
            _buildQuickStats(employeeProvider),
            Expanded(
              child: _buildEmployeeList(employeeProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchEmployeeHint, // Localized hint text
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.greyLight),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            children: [
              _buildFilterChip(l10n.allGood.split(' ')[1], 'all'), // Localized "All"
              const SizedBox(width: 8),
              _buildFilterChip(l10n.active, 'active'), // Localized "Active"
              const SizedBox(width: 8),
              _buildFilterChip(l10n.inactive, 'inactive'), // Localized "Inactive"
              const Spacer(),
              // Sort options
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: AppColors.primary),
                onSelected: (value) {
                  // TODO: Implement sorting
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'name', child: Text(l10n.sortByName)), // Localized
                  PopupMenuItem(value: 'date', child: Text(l10n.sortByDate)), // Localized
                  PopupMenuItem(value: 'checkouts', child: Text(l10n.sortByCheckouts)), // Localized
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildQuickStats(EmployeeProvider employeeProvider) {
    final l10n = AppLocalizations.of(context)!;
    final stats = employeeProvider.getEmployeeStatistics();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              l10n.totalEmployees, // Localized "Total Employees"
              stats['totalEmployees'].toString(),
              Icons.people,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              l10n.active, // Localized "Active"
              stats['activeEmployees'].toString(),
              Icons.check_circle,
              AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList(EmployeeProvider employeeProvider) {
    final l10n = AppLocalizations.of(context)!;
    List<UserModel> employees = _getFilteredEmployees(employeeProvider);

    if (employees.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return _buildEmployeeCard(employees[index], employeeProvider);
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

  Widget _buildEmployeeCard(UserModel employee, EmployeeProvider employeeProvider) {
    final l10n = AppLocalizations.of(context)!;
    final activeCheckouts = employeeProvider.getEmployeeActiveCheckouts(employee.id);
    final overdueCheckouts = employeeProvider.getEmployeeOverdueCheckouts(employee.id);
    final performance = employeeProvider.getEmployeePerformance(employee.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEmployeeDetails(employee, employeeProvider),
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
                    child: Column(
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
                                employee.isActive ? l10n.active : l10n.inactive, // Localized status
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
                    ),
                  ),
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEmployeeAction(value, employee, employeeProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewDetails), // Localized
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit), // Localized
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'checkouts',
                        child: Row(
                          children: [
                            const Icon(Icons.inventory, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewCheckouts), // Localized
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
                            Text(employee.isActive ? l10n.deactivate : l10n.activate), // Localized
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.delete, style: const TextStyle(color: AppColors.error)), // Localized
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quick Stats Row
              Row(
                children: [
                  _buildQuickStat(
                    l10n.activeCheckouts, // Localized
                    activeCheckouts.length.toString(),
                    activeCheckouts.isNotEmpty ? AppColors.info : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    l10n.overdue, // Localized
                    overdueCheckouts.length.toString(),
                    overdueCheckouts.isNotEmpty ? AppColors.error : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                    l10n.totalCheckouts, // Localized
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
                            l10n.needsAttention, // Localized
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
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildEmptyState() {
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
            _searchQuery.isNotEmpty
                ? l10n.noEmployeesFoundSearch(_searchQuery) // Localized with parameter
                : l10n.noEmployeesFound, // Localized
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? l10n.adjustSearchFilters // Localized
                : l10n.addFirstEmployeeHint, // Localized
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _showAddEmployeeDialog(),
              icon: const Icon(Icons.add),
              label: Text(l10n.addEmployee), // Localized
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: _showAddEmployeeDialog,
      backgroundColor: AppColors.secondary,
      child: Icon(Icons.add, color: AppColors.white, semanticLabel: l10n.addEmployee), // Localized semantic label
    );
  }

  void _handleEmployeeAction(String action, UserModel employee, EmployeeProvider employeeProvider) {
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AddEditEmployeeDialog(),
    ).then((result) {
      if (result == true) {
        _loadEmployees();
      }
    });
  }

  void _showEditEmployeeDialog(UserModel employee) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AddEditEmployeeDialog(employee: employee),
    ).then((result) {
      if (result == true) {
        _loadEmployees();
      }
    });
  }

  void _showEmployeeDetails(UserModel employee, EmployeeProvider employeeProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => EmployeeDetailsDialog(
        employee: employee,
        employeeProvider: employeeProvider,
      ),
    );
  }

  void _showEmployeeCheckouts(UserModel employee) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.employeeCheckoutsComingSoon(employee.fullName)), // Localized
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
            employee.isActive ? l10n.employeeDeactivatedSuccess : l10n.employeeActivatedSuccess, // Localized
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employeeProvider.errorMessage ?? l10n.failedToUpdateEmployeeStatus, // Localized fallback
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
        title: Text(l10n.deleteEmployee), // Localized
        content: Text(
          l10n.deleteEmployeeConfirmation(employee.fullName), // Localized with parameter
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await employeeProvider.deleteEmployee(employee.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.employeeDeletedSuccess), // Localized
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      employeeProvider.errorMessage ?? l10n.failedToDeleteEmployee, // Localized fallback
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
            child: Text(l10n.delete), // Localized
          ),
        ],
      ),
    );
  }

  void _showEmployeeAnalytics() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => const EmployeeAnalyticsDialog(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Add/Edit Employee Dialog
class AddEditEmployeeDialog extends StatefulWidget {
  final UserModel? employee;

  const AddEditEmployeeDialog({Key? key, this.employee}) : super(key: key);

  @override
  State<AddEditEmployeeDialog> createState() => _AddEditEmployeeDialogState();
}

class _AddEditEmployeeDialogState extends State<AddEditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.employee != null;

    if (_isEditMode) {
      _fullNameController.text = widget.employee!.fullName;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone;
      _addressController.text = widget.employee!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_isEditMode ? l10n.editEmployee : l10n.addEmployee), // Localized title
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: l10n.employeeName, // Localized label
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired; // Localized
                    }
                    if (value.trim().length < 2) {
                      return l10n.validationNameTooShort; // Localized
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email, // Localized label
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired; // Localized
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return l10n.validationInvalidEmail; // Localized
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: l10n.employeePhone, // Localized label
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired; // Localized
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: l10n.address, // Localized label
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired; // Localized
                    }
                    return null;
                  },
                ),
                if (!_isEditMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password, // Localized label
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.validationRequired; // Localized
                      }
                      if (value.length < 6) {
                        return l10n.validationPasswordTooShort; // Localized
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel), // Localized
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEmployee,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(_isEditMode ? l10n.update : l10n.create), // Localized
        ),
      ],
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    bool success = false;

    try {
      if (_isEditMode) {
        // Update existing employee
        final updatedEmployee = widget.employee!.copyWith(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
        success = await employeeProvider.updateEmployee(updatedEmployee);
      } else {
        // Create new employee
        success = await employeeProvider.createEmployee(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );
      }

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? l10n.employeeUpdatedSuccess
                  : l10n.employeeCreatedSuccess,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employeeProvider.errorMessage ??
                  (_isEditMode ? l10n.failedToUpdateEmployee : l10n.failedToCreateEmployee),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorOccurred}: $e'), // Localized error message
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Employee Details Dialog
class EmployeeDetailsDialog extends StatelessWidget {
  final UserModel employee;
  final EmployeeProvider employeeProvider;

  const EmployeeDetailsDialog({
    Key? key,
    required this.employee,
    required this.employeeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final performance = employeeProvider.getEmployeePerformance(employee.id);
    final activeCheckouts = employeeProvider.getEmployeeActiveCheckouts(employee.id);
    final overdueCheckouts = employeeProvider.getEmployeeOverdueCheckouts(employee.id);

    return AlertDialog(
      title: Text(employee.fullName),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Info
              _buildInfoSection(l10n.employeeInformation, [ // Localized
                _buildInfoRow(l10n.email, employee.email), // Localized
                _buildInfoRow(l10n.employeePhone, employee.phone), // Localized
                _buildInfoRow(l10n.address, employee.address), // Localized
                _buildInfoRow(l10n.employeeRole, employee.role.toUpperCase()), // Localized
                _buildInfoRow(l10n.employeeStatus, employee.isActive ? l10n.active : l10n.inactive), // Localized
                _buildInfoRow(l10n.joined, _formatDate(employee.createdAt)), // Localized
              ]),
              const SizedBox(height: 16),

              // Performance Stats
              _buildInfoSection(l10n.performanceStatistics, [ // Localized
                _buildInfoRow(l10n.totalCheckouts, performance['totalCheckouts'].toString()), // Localized
                _buildInfoRow(l10n.activeCheckouts, performance['activeCheckouts'].toString()), // Localized
                _buildInfoRow(l10n.completedCheckouts, performance['completedCheckouts'].toString()), // Localized
                _buildInfoRow(l10n.overdueItems, performance['overdueCheckouts'].toString()), // Localized
                _buildInfoRow(l10n.reliabilityScore, '${performance['reliabilityScore'].toStringAsFixed(1)}%'), // Localized
              ]),
              const SizedBox(height: 16),

              // Current Checkouts
              if (activeCheckouts.isNotEmpty) ...[
                _buildInfoSection(l10n.currentCheckouts, []), // Localized
                ...activeCheckouts.map((checkout) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: AppColors.info),
                    title: Text('${l10n.equipmentId}: ${checkout.equipmentId}'), // Localized
                    subtitle: Text('${l10n.quantity}: ${checkout.quantity} • ${l10n.checkedOut}: ${_formatDate(checkout.checkoutDate)}'), // Localized
                    trailing: checkout.isOverdue
                        ? const Icon(Icons.warning, color: AppColors.error)
                        : null,
                  ),
                )),
              ],

              // Overdue Items
              if (overdueCheckouts.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildInfoSection('⚠️ ${l10n.overdueItems}', []), // Localized
                ...overdueCheckouts.map((checkout) => Card(
                  color: AppColors.error.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: AppColors.error),
                    title: Text('${l10n.equipmentId}: ${checkout.equipmentId}'), // Localized
                    subtitle: Text(
                        l10n.overdueByDays(DateTime.now().difference(checkout.checkoutDate).inDays) // Localized
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close), // Localized
        ),
        ElevatedButton(
          onPressed: ()  {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AddEditEmployeeDialog(employee: employee),
            ).then((result) async {
              if (result == true) {
                final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                await employeeProvider.loadAllEmployeeData();
              }
            });
          },
          child: Text(l10n.editEmployee), // Localized
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
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
}

// Employee Analytics Dialog
class EmployeeAnalyticsDialog extends StatelessWidget {
  const EmployeeAnalyticsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        final stats = employeeProvider.getEmployeeStatistics();
        final topPerformers = employeeProvider.getTopPerformingEmployees(limit: 5);
        final alerts = employeeProvider.getEmployeesRequiringAttention();

        return AlertDialog(
          title: Text(l10n.employeeAnalytics), // Localized
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  _buildAnalyticsSection(l10n.overview, [ // Localized
                    _buildAnalyticsGrid([
                      _buildAnalyticsCard(l10n.totalEmployees, stats['totalEmployees'].toString(), Icons.people, AppColors.primary), // Localized
                      _buildAnalyticsCard(l10n.activeEmployees, stats['activeEmployees'].toString(), Icons.check_circle, AppColors.success), // Localized
                      _buildAnalyticsCard(l10n.activeCheckouts, stats['totalActiveCheckouts'].toString(), Icons.inventory, AppColors.info), // Localized
                      _buildAnalyticsCard(l10n.overdueItems, stats['totalOverdueCheckouts'].toString(), Icons.warning, AppColors.error), // Localized
                    ]),
                  ]),
                  const SizedBox(height: 24),

                  // Top Performers
                  if (topPerformers.isNotEmpty) ...[
                    _buildAnalyticsSection(l10n.topPerformingEmployees, [ // Localized
                      ...topPerformers.take(3).map((performer) {
                        final employee = performer['employee'] as UserModel;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.success,
                              child: Text(
                                employee.fullName[0].toUpperCase(),
                                style: const TextStyle(color: AppColors.white),
                              ),
                            ),
                            title: Text(employee.fullName),
                            subtitle: Text('${l10n.reliability}: ${performer['reliabilityScore'].toStringAsFixed(1)}%'), // Localized
                            trailing: Text(l10n.totalCheckoutsCount(performer['totalCheckouts'])), // Localized
                          ),
                        );
                      }),
                    ]),
                    const SizedBox(height: 24),
                  ],

                  // Alerts
                  if (alerts.isNotEmpty) ...[
                    _buildAnalyticsSection(l10n.employeesRequiringAttention, [ // Localized
                      ...alerts.take(5).map((alert) {
                        final employee = alert['employee'] as UserModel;
                        return Card(
                          color: alert['priority'] == 'high'
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                          child: ListTile(
                            leading: Icon(
                              alert['type'] == 'overdue_equipment'
                                  ? Icons.warning
                                  : Icons.info,
                              color: alert['priority'] == 'high'
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                            title: Text(employee.fullName),
                            subtitle: Text(alert['message']),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: alert['priority'] == 'high'
                                    ? AppColors.error
                                    : AppColors.warning,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                alert['priority'].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close), // Localized
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.detailedAnalyticsExportComingSoon), // Localized
                  ),
                );
              },
              child: Text(l10n.exportReport), // Localized
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildAnalyticsGrid(List<Widget> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: cards,
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
