import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/employee_provider.dart';
import '../../../constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class AddEditEmployeeWidget extends StatefulWidget {
  final UserModel? employee;

  const AddEditEmployeeWidget({Key? key, this.employee}) : super(key: key);

  @override
  State<AddEditEmployeeWidget> createState() => _AddEditEmployeeWidgetState();
}

class _AddEditEmployeeWidgetState extends State<AddEditEmployeeWidget> {
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
      title: Text(_isEditMode ? l10n.editEmployee : l10n.addEmployee),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNameField(l10n),
                const SizedBox(height: 16),
                _buildEmailField(l10n),
                const SizedBox(height: 16),
                _buildPhoneField(l10n),
                const SizedBox(height: 16),
                _buildAddressField(l10n),
                if (!_isEditMode) ...[
                  const SizedBox(height: 16),
                  _buildPasswordField(l10n),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEmployee,
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(_isEditMode ? l10n.update : l10n.create),
        ),
      ],
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: l10n.employeeName,
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.validationRequired;
        }
        if (value.trim().length < 2) {
          return l10n.validationNameTooShort;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: l10n.email,
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.validationRequired;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.validationInvalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: l10n.employeePhone,
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.validationRequired;
        }
        return null;
      },
    );
  }

  Widget _buildAddressField(AppLocalizations l10n) {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: l10n.address,
        prefixIcon: const Icon(Icons.location_on),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.validationRequired;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: l10n.password,
        prefixIcon: const Icon(Icons.lock),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.validationRequired;
        }
        if (value.length < 6) {
          return l10n.validationPasswordTooShort;
        }
        return null;
      },
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
          content: Text('${l10n.errorOccurred}: $e'),
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