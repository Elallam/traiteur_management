import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/cash_transaction_model.dart';
import '../../providers/cash_transaction_provider.dart';
import '../../services/firestore_service.dart';

class AddTransactionDialog extends StatefulWidget {
  final void Function(dynamic transaction) onTransactionAdded;

  const AddTransactionDialog({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _operationNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'deposit';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _operationNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.white,
                    size: AppDimensions.iconL,
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  Expanded(
                    child: Text(
                      s.addTransaction,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Type
                      Text(
                        s.transactionType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              s.deposit,
                              'deposit',
                              Icons.arrow_upward,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: _buildTypeButton(
                              s.withdraw,
                              'withdraw',
                              Icons.arrow_downward,
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Operation Name
                      CustomTextField(
                        label: s.operationName,
                        hint: s.enterOperationName,
                        controller: _operationNameController,
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return s.operationNameRequired;
                          }
                          if (value
                              .trim()
                              .length < 2) {
                            return s.operationNameMinLength;
                          }
                          return null;
                        },
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Amount
                      CustomTextField(
                        label: s.amount.toString().replaceFirst(
                            '{currencySymbol}', AppStrings.currencySymbol),
                        hint: s.enterAmount,
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return s.amountRequired;
                          }
                          final amount = double.tryParse(value.trim());
                          if (amount == null) {
                            return s.invalidAmountFormat;
                          }
                          if (amount <= 0) {
                            return s.amountMustBePositive;
                          }
                          return null;
                        },
                        prefixIcon: Icons.monetization_on,
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Date
                      _buildDateField(),
                      const SizedBox(height: AppDimensions.marginM),

                      // Description
                      CustomTextField(
                        label: s.descriptionOptional,
                        hint: s.enterDescription,
                        controller: _descriptionController,
                        maxLines: 3,
                        prefixIcon: Icons.description,
                      ),
                      const SizedBox(height: AppDimensions.marginL),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: s.cancel,
                              onPressed: () => Navigator.pop(context),
                              outlined: true,
                              backgroundColor: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: CustomButton(
                              text: s.addTransaction,
                              onPressed: _isLoading ? null : _addTransaction,
                              isLoading: _isLoading,
                              backgroundColor: _selectedType == 'deposit'
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon,
      Color color) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: AppDimensions.iconL,
            ),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final s = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.transactionDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginS),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(_selectedDate),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _addTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = CashTransactionModel(
        id: '',
        // This will be set by Firestore
        operationName: _operationNameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        date: _selectedDate,
        description: _descriptionController.text
            .trim()
            .isEmpty
            ? null
            : _descriptionController.text.trim(),
        userId: null,
        userName: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use the fixed addTransaction method
      await context.read<CashTransactionProvider>().addTransaction(transaction);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _selectedType == 'deposit'
                    ? s.depositAddedSuccess
                    : s.withdrawalAddedSuccess
            ),
            backgroundColor: _selectedType == 'deposit'
                ? AppColors.success
                : AppColors.error,
          ),
        );
        // Don't call widget.onTransactionAdded since the provider handles the state update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.addTransactionFailed.toString().replaceFirst(
                '{error}', e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class TransactionDetailsDialog extends StatelessWidget {
  final CashTransactionModel transaction;

  const TransactionDetailsDialog({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final isDeposit = transaction.isDeposit;
    final color = isDeposit ? AppColors.success : AppColors.error;
    final icon = isDeposit ? Icons.arrow_upward : Icons.arrow_downward;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Icon(icon, color: AppColors.white, size: 24),
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.transactionDetails,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isDeposit ? s.deposit : s.withdraw,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Center(
                    child: Text(
                      '${isDeposit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginL),

                  // Details
                  _buildDetailRow(s.operationName, transaction.operationName),
                  _buildDetailRow(
                      s.transactionDate,
                      DateFormat('MMM dd, yyyy HH:mm').format(transaction.date)
                  ),
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    _buildDetailRow(s.descriptionOptional.replaceAll(' (Optional)', ''), transaction.description!),
                  if (transaction.userName != null)
                    _buildDetailRow(s.addedBy, transaction.userName!),
                  _buildDetailRow(
                      s.lastUpdated,
                      DateFormat('MMM dd, yyyy HH:mm').format(transaction.createdAt)
                  ),
                  if (transaction.updatedAt != transaction.createdAt)
                    _buildDetailRow(
                        s.lastUpdated,
                        DateFormat('MMM dd, yyyy HH:mm').format(transaction.updatedAt)
                    ),

                  const SizedBox(height: AppDimensions.marginL),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: s.close,
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditTransactionDialog extends StatefulWidget {
  final CashTransactionModel transaction;
  final void Function(dynamic transaction) onTransactionUpdated;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.onTransactionUpdated,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _operationNameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late String _selectedType;
  late DateTime _selectedDate;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _operationNameController = TextEditingController(text: widget.transaction.operationName);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController = TextEditingController(text: widget.transaction.description ?? '');
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _operationNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: AppColors.white,
                    size: AppDimensions.iconL,
                  ),
                  const SizedBox(width: AppDimensions.marginS),
                  Expanded(
                    child: Text(
                      s.editTransaction,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Type
                      Text(
                        s.transactionType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeButton(
                              s.deposit,
                              'deposit',
                              Icons.arrow_upward,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: _buildTypeButton(
                              s.withdraw,
                              'withdraw',
                              Icons.arrow_downward,
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Operation Name
                      CustomTextField(
                        label: s.operationName,
                        hint: s.enterOperationName,
                        controller: _operationNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return s.operationNameRequired;
                          }
                          if (value.trim().length < 2) {
                            return s.operationNameMinLength;
                          }
                          return null;
                        },
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Amount
                      CustomTextField(
                        label: s.amount.replaceFirst('{currencySymbol}', AppStrings.currencySymbol),
                        hint: s.enterAmount,
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return s.amountRequired;
                          }
                          final amount = double.tryParse(value.trim());
                          if (amount == null) {
                            return s.invalidAmountFormat;
                          }
                          if (amount <= 0) {
                            return s.amountMustBePositive;
                          }
                          return null;
                        },
                        prefixIcon: Icons.monetization_on,
                      ),
                      const SizedBox(height: AppDimensions.marginM),

                      // Date
                      _buildDateField(),
                      const SizedBox(height: AppDimensions.marginM),

                      // Description
                      CustomTextField(
                        label: s.descriptionOptional,
                        hint: s.enterDescription,
                        controller: _descriptionController,
                        maxLines: 3,
                        prefixIcon: Icons.description,
                      ),
                      const SizedBox(height: AppDimensions.marginL),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: s.cancel,
                              onPressed: () => Navigator.pop(context),
                              outlined: true,
                              backgroundColor: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginM),
                          Expanded(
                            child: CustomButton(
                              text: s.update,
                              onPressed: _isLoading ? null : _updateTransaction,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon, Color color) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: AppDimensions.iconL,
            ),
            const SizedBox(height: AppDimensions.marginS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final s = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.transactionDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginS),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(_selectedDate),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    final s = AppLocalizations.of(context);

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final s = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTransaction = widget.transaction.copyWith(
        operationName: _operationNameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateCashTransaction(updatedTransaction);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.transactionUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onTransactionUpdated(updatedTransaction);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.updateTransactionFailed.toString().replaceFirst('{error}', e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class TransactionOptionsBottomSheet extends StatelessWidget {
  final CashTransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionOptionsBottomSheet({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),

          // Title
          Text(
            s.transactionOptions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            transaction.operationName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginL),

          // Options
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primary),
            title: Text(s.editTransaction),
            onTap: onEdit,
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title: Text(s.deleteTransaction),
            onTap: onDelete,
          ),

          const SizedBox(height: AppDimensions.marginM),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: s.cancel,
              onPressed: () => Navigator.pop(context),
              outlined: true,
              backgroundColor: AppColors.textSecondary,
            ),
          ),

          // Add safe area at bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}