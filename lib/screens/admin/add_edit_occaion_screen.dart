import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:traiteur_management/core/utils/helpers.dart';
import 'package:traiteur_management/core/widgets/admin/occasion/add_edit_occasion/financial_tab.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/equipment_model.dart';
import '../../models/meal_model.dart';
import '../../models/occasion_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../core/widgets/equipment_availability_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class AddOccasionDialog extends StatefulWidget {
  final OccasionModel? occasion;

  const AddOccasionDialog({super.key, this.occasion});

  @override
  State<AddOccasionDialog> createState() => _AddOccasionDialogState();
}

class _AddOccasionDialogState extends State<AddOccasionDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _expectedGuestsController = TextEditingController();
  final _notesController = TextEditingController();
  final _equipmentDepreciationController = TextEditingController();
  final _profitMarginController = TextEditingController();
  final _transportCostController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  // Meals and Equipment
  List<OccasionMeal> _selectedMeals = [];
  List<OccasionEquipment> _selectedEquipment = [];
  String? _selectedCategory;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    if (widget.occasion != null) {
      _populateFields();
    } else {
      // Set default values for new occasions
      _profitMarginController.text = '15.0'; // Default 15% profit margin
      _transportCostController.text = '0.0';
      _equipmentDepreciationController.text = '0.0';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStockData();
      _loadCategoriesData();
    });
  }

  void _populateFields() {
    final occasion = widget.occasion!;
    _titleController.text = occasion.title;
    _descriptionController.text = occasion.description;
    _addressController.text = occasion.address;
    _clientNameController.text = occasion.clientName;
    _clientPhoneController.text = occasion.clientPhone;
    _clientEmailController.text = occasion.clientEmail;
    _expectedGuestsController.text = occasion.expectedGuests.toString();
    _notesController.text = occasion.notes ?? '';

    // Financial fields - use new model properties
    _profitMarginController.text = occasion.profitMarginPercentage.toString();
    _transportCostController.text = occasion.transportPrice.toString();
    _equipmentDepreciationController.text = occasion.equipmentPrice.toString();

    _selectedDate = DateTime(
      occasion.date.year,
      occasion.date.month,
      occasion.date.day,
    );
    _selectedTime = TimeOfDay.fromDateTime(occasion.date);

    _selectedMeals = List.from(occasion.meals);
    _selectedEquipment = List.from(occasion.equipment);
  }

  Future<void> _loadStockData() async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await Future.wait([
      stockProvider.loadMeals(),
      stockProvider.loadEquipment(),
    ]);
  }

  Future<void> _loadCategoriesData() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await Future.wait([
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _expectedGuestsController.dispose();
    _notesController.dispose();
    _equipmentDepreciationController.dispose();
    _profitMarginController.dispose();
    _transportCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: screenWidth * 0.99,
        height: screenHeight * 0.99,
        constraints: BoxConstraints(
          maxHeight: screenHeight,
          maxWidth: screenWidth,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.occasion == null ? l10n.createNewEvent : l10n
                          .editOccasion,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: l10n.basicInfo),
                  Tab(text: l10n.meals),
                  Tab(text: l10n.equipment),
                  Tab(text: l10n.financialTabTitle),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildMealsTab(),
                    _buildEquipmentTab(),
                    FinancialTab(
                      selectedMeals: _selectedMeals,
                      selectedEquipment: _selectedEquipment,
                      equipmentDepreciationController: _equipmentDepreciationController,
                      profitMarginController: _profitMarginController,
                      transportCostController: _transportCostController,
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: l10n.cancel,
                      onPressed: () => Navigator.pop(context),
                      outlined: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: widget.occasion == null ? l10n.createEvent : l10n
                          .updateEvent,
                      onPressed: _saveOccasion,
                      isLoading: _isLoading,
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

  Widget _buildSelectedEquipmentSummary(StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Row(
          children: [
            const Icon(Icons.checklist, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.selectedEquipment,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedEquipment.length}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _selectedEquipment.length,
              itemBuilder: (context, index) {
                final eq = _selectedEquipment[index];
                final equipment = stockProvider.getEquipmentById(eq.equipmentId);
                final TextEditingController _quantityController =
                TextEditingController(text: eq.quantity.toString());
                final FocusNode _quantityFocus = FocusNode();

                // Update controller when quantity changes externally
                _quantityController.text = eq.quantity.toString();

                if (equipment == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory, size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eq.equipmentName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (equipment.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                equipment.description!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () {
                              final newQuantity = eq.quantity - 1;
                              if (newQuantity > 0) {
                                _updateEquipmentQuantity(equipment, newQuantity);
                              } else {
                                // Remove if quantity reaches 0
                                setState(() {
                                  _selectedEquipment.removeAt(index);
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            height: 32,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  // When focus is lost, validate and update quantity
                                  final newQuantity = int.tryParse(_quantityController.text) ?? eq.quantity;
                                  final clampedQuantity = newQuantity.clamp(1, equipment.availableQuantity);
                                  _updateEquipmentQuantity(equipment, clampedQuantity);
                                }
                              },
                              child: TextField(
                                controller: _quantityController,
                                focusNode: _quantityFocus,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onSubmitted: (value) {
                                  final newQuantity = int.tryParse(value) ?? eq.quantity;
                                  final clampedQuantity = newQuantity.clamp(1, equipment.availableQuantity);
                                  _updateEquipmentQuantity(equipment, clampedQuantity);
                                  _quantityFocus.unfocus();
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: eq.quantity < equipment.availableQuantity
                                ? () => _updateEquipmentQuantity(
                              equipment,
                              eq.quantity + 1,
                            )
                                : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCategory(String category,
      List<EquipmentModel> equipment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${equipment.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...equipment.map((eq) => _buildEquipmentCard(eq)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment) {
    final isSelected = _selectedEquipment.any((e) =>
    e.equipmentId == equipment.id);
    final selectedItem = isSelected
        ? _selectedEquipment.firstWhere((e) => e.equipmentId == equipment.id)
        : null;
    final quantity = selectedItem?.quantity ?? 0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (isSelected) {
              _updateEquipmentQuantity(equipment, quantity - 1);
            } else if (equipment.availableQuantity > 0) {
              _addEquipment(equipment);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            equipment.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (equipment.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              equipment.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildAvailabilityBadge(equipment),
                  ],
                ),
                const SizedBox(height: 16),
                if (isSelected) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${l10n.quantity}:',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _updateEquipmentQuantity(
                                      equipment, quantity - 1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                ),
                                Container(
                                  width: 40,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: quantity <
                                      equipment.availableQuantity
                                      ? () =>
                                      _updateEquipmentQuantity(
                                        equipment,
                                        quantity + 1,
                                      )
                                      : null,
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: quantity < equipment.availableQuantity
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: quantity / equipment.totalQuantity,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            quantity <= equipment.availableQuantity
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available: ${equipment
                                  .availableQuantity}/${equipment
                                  .totalQuantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _updateEquipmentQuantity(equipment, 0),
                              child: const Text('Remove All'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                minimumSize: const Size(0, 32),
                                foregroundColor: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else
                  ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            equipment.availableQuantity > 0
                                ? 'Tap to add to your selection'
                                : 'Currently unavailable',
                            style: TextStyle(
                              fontSize: 12,
                              color: equipment.availableQuantity > 0
                                  ? AppColors.textSecondary
                                  : AppColors.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        if (equipment.availableQuantity > 0)
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge(EquipmentModel equipment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: equipment.availableQuantity > 0
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${equipment.availableQuantity} available',
        style: TextStyle(
          color: equipment.availableQuantity > 0
              ? AppColors.success
              : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addMeal(MealModel meal) {
    setState(() {
      _selectedMeals.add(OccasionMeal(
        mealId: meal.id,
        mealName: meal.name,
        quantity: 1,
        unitPrice: meal.sellingPrice,
        totalPrice: meal.sellingPrice,
      ));
    });
  }

  void _updateMealQuantity(MealModel meal, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _selectedMeals.removeWhere((m) => m.mealId == meal.id);
      } else {
        final index = _selectedMeals.indexWhere((m) => m.mealId == meal.id);
        if (index != -1) {
          _selectedMeals[index] = OccasionMeal(
            mealId: meal.id,
            mealName: meal.name,
            quantity: newQuantity,
            unitPrice: meal.sellingPrice,
            totalPrice: meal.sellingPrice * newQuantity,
          );
        }
      }
    });
  }

  void _addEquipment(EquipmentModel equipment) {
    setState(() {
      // Calculate rental prices based on equipment model
      final unitRentalPrice = equipment.price;

      _selectedEquipment.add(OccasionEquipment(
        equipmentId: equipment.id,
        equipmentName: equipment.name,
        quantity: 1,
        unitRentalPrice: unitRentalPrice!,
        // totalRentalPrice: totalRentalPrice,
        status: 'assigned',
      ));
    });
  }

  void _updateEquipmentQuantity(EquipmentModel equipment, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _selectedEquipment.removeWhere((e) => e.equipmentId == equipment.id);
      } else {
        final index = _selectedEquipment.indexWhere((e) =>
        e.equipmentId == equipment.id);
        if (index != -1) {
          final unitRentalPrice = equipment.price!;
          _selectedEquipment[index] = _selectedEquipment[index].copyWith(
            quantity: newQuantity,
            unitRentalPrice: unitRentalPrice,
            totalRentalPrice: unitRentalPrice * newQuantity,
          );
        }
      }
    });
  }

  Widget _buildBasicInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CustomTextField(
            label: l10n.eventTitle,
            controller: _titleController,
            validator: Validators.required,
            hint: l10n.enterEventTitle,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.description,
            controller: _descriptionController,
            validator: Validators.required,
            hint: l10n.describeEvent,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Date and Time
          Row(
            children: [
              Expanded(
                child: _buildDateField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.eventAddress,
            controller: _addressController,
            validator: Validators.required,
            hint: l10n.enterCompleteAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.expectedGuests,
            controller: _expectedGuestsController,
            validator: Validators.required,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hint: l10n.numberOfGuests,
          ),
          const SizedBox(height: 24),

          // Client Information
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.clientInformation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientName,
            controller: _clientNameController,
            validator: Validators.required,
            hint: l10n.enterClientName,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientPhone,
            controller: _clientPhoneController,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            hint: l10n.enterPhoneNumber,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientEmail,
            controller: _clientEmailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            hint: l10n.enterEmailAddress,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.notesOptional,
            controller: _notesController,
            hint: l10n.additionalNotes,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventDate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventTime,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsTab() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<StockProvider, CategoryProvider>(
      builder: (context, stockProvider, categoryProvider, child) {
        if (stockProvider.isLoading || categoryProvider.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableMeals = stockProvider.getAvailableMeals();

        // Create a map of category IDs to names
        final categoryMap = {
          for (var category in categoryProvider.categories)
            category.id: category.name
        };

        // Group meals by category name
        final groupedMeals = <String, List<MealModel>>{};
        for (var meal in availableMeals) {
          final categoryName = categoryMap[meal.category] ?? meal.category;
          groupedMeals.putIfAbsent(categoryName, () => []).add(meal);
        }

        // Sort categories alphabetically
        final sortedCategories = groupedMeals.keys.toList()..sort();
        print(sortedCategories);
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomScrollView(
              slivers: [
                // Selected Meals Summary
                if (_selectedMeals.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildSelectedMealsSummary(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                // Search bar
                SliverToBoxAdapter(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchMeals,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onChanged: (value) {
                      // Implement search filtering here
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Category tabs
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // All categories chip
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                        ),
                        // Category chips
                        ...sortedCategories.map((categoryName) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(categoryName),
                              selected: _selectedCategory == categoryName,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? categoryName : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Available Meals by Category
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final category = sortedCategories
                          .where((category) => _selectedCategory == null ||
                          category == _selectedCategory)
                          .elementAt(index);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              category,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...groupedMeals[category]!.map((meal) {
                            final isSelected = _selectedMeals.any((m) =>
                            m.mealId == meal.id);
                            final selectedMeal = isSelected
                                ? _selectedMeals.firstWhere((m) => m.mealId == meal.id)
                                : null;

                            return _buildMealCard(
                                meal, isSelected, selectedMeal?.quantity ?? 0);
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    childCount: _selectedCategory == null
                        ? sortedCategories.length
                        : 1, // Only show selected category
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedMealsSummary() {
    final l10n = AppLocalizations.of(context)!;
    double totalPrice = _selectedMeals.fold(
        0.0, (sum, meal) => sum + meal.totalPrice);

    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.selectedMeals,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              Helpers.formatMAD(totalPrice),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.mealsSelected(_selectedMeals.length),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MealModel meal, bool isSelected, int quantity) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController _quantityController = TextEditingController(text: quantity.toString());
    final FocusNode _quantityFocus = FocusNode();

    // Update controller when quantity changes externally
    _quantityController.text = quantity.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        meal.description ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pricePerServing(meal.sellingPrice.toStringAsFixed(2)),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (isSelected) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              int newQuantity = quantity - 1;
                              if (newQuantity >= 0) {
                                _updateMealQuantity(meal, newQuantity);
                              }
                            },
                            icon: const Icon(Icons.remove),
                            splashRadius: 20,
                          ),
                          SizedBox(
                            width: 50,
                            child: Focus(
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) {
                                  // When focus is lost, validate and update quantity
                                  int? newQuantity = int.tryParse(_quantityController.text);
                                  if (newQuantity != null && newQuantity >= 0) {
                                    _updateMealQuantity(meal, newQuantity);
                                  } else {
                                    // Reset to previous value if invalid
                                    _quantityController.text = quantity.toString();
                                  }
                                }
                              },
                              child: TextField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                focusNode: _quantityFocus,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  isDense: true,
                                ),
                                onSubmitted: (value) {
                                  int? newQuantity = int.tryParse(value);
                                  if (newQuantity != null && newQuantity >= 0) {
                                    _updateMealQuantity(meal, newQuantity);
                                  } else {
                                    _quantityController.text = quantity.toString();
                                  }
                                  _quantityFocus.unfocus();
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _updateMealQuantity(meal, quantity + 1),
                            icon: const Icon(Icons.add),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ] else ...[
                      CustomButton(
                        text: l10n.add,
                        onPressed: () => _addMeal(meal),
                        width: 80,
                        height: 36,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTab() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer3<StockProvider, EquipmentBookingProvider, CategoryProvider>(
      builder: (context, stockProvider, bookingProvider, categoryProvider, child) {
        if (stockProvider.isLoading || categoryProvider.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableEquipment = stockProvider.getAvailableEquipment();
        final groupedEquipment = <String, List<EquipmentModel>>{};

        // Create a map of category IDs to names
        final categoryMap = {
          for (var category in categoryProvider.categories)
            category.id: category.name
        };

        for (var equipment in availableEquipment) {
          // Use category name instead of ID for grouping
          final categoryName = categoryMap[equipment.category] ?? equipment.category;
          groupedEquipment.putIfAbsent(categoryName, () => []).add(equipment);
        }

        return Column(
          children: [
            // Equipment Availability Widget
            Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: EquipmentAvailabilityWidget(
                occasionDate: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ),
                selectedEquipment: _selectedEquipment,
                onEquipmentChanged: (updatedEquipment) {
                  setState(() {
                    _selectedEquipment = updatedEquipment;
                  });
                },
                excludeOccasionId: widget.occasion?.id,
              ),
            ),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Selected Equipment Summary
                    if (_selectedEquipment.isNotEmpty) ...[
                      _buildSelectedEquipmentSummary(stockProvider),
                      const SizedBox(height: 16),
                    ],

                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: l10n.searchEquipment,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        // Implement search filtering here
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category tabs
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // All categories chip
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('All'),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            ),
                          ),
                          // Category chips
                          ...groupedEquipment.keys.map((categoryName) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(categoryName),
                                selected: _selectedCategory == categoryName,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = selected ? categoryName : null;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Equipment list
                    ...groupedEquipment.entries
                        .where((entry) =>
                    _selectedCategory == null || entry.key == _selectedCategory)
                        .map((entry) =>
                        _buildEquipmentCategory(entry.key, entry.value))
                        .toList(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Future<void> _saveOccasion() async {

    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {

      return;

    }



    if (_selectedMeals.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(l10n.selectAtLeastOneMeal),

          backgroundColor: AppColors.error,

        ),

      );

      _tabController.animateTo(1);

      return;

    }



    // NEW: Validate equipment availability

    if (_selectedEquipment.isNotEmpty) {

      final bookingProvider = Provider.of<EquipmentBookingProvider>(context, listen: false);



      final eventDateTime = DateTime(

        _selectedDate.year,

        _selectedDate.month,

        _selectedDate.day,

        _selectedTime.hour,

        _selectedTime.minute,

      );



      final validation = await bookingProvider.validateEquipmentBooking(

        equipment: _selectedEquipment,

        occasionDate: eventDateTime,

        excludeOccasionId: widget.occasion?.id,

      );



      if (!validation['isValid']) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(l10n.equipmentAvailabilityConflicts),

            backgroundColor: AppColors.error,

          ),

        );

        _tabController.animateTo(2); // Switch to equipment tab

        return;

      }

    }



    setState(() {

      _isLoading = true;

    });



    try {

      final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);



      final eventDateTime = DateTime(

        _selectedDate.year,

        _selectedDate.month,

        _selectedDate.day,

        _selectedTime.hour,

        _selectedTime.minute,

      );



      final occasion = occasionProvider.createOccasion(

        title: _titleController.text.trim(),

        description: _descriptionController.text.trim(),

        date: eventDateTime,

        address: _addressController.text.trim(),

        clientName: _clientNameController.text.trim(),

        clientPhone: _clientPhoneController.text.trim(),

        clientEmail: _clientEmailController.text.trim(),

        meals: _selectedMeals,

        equipment: _selectedEquipment,

        expectedGuests: int.parse(_expectedGuestsController.text),

        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),

        equipmentCost: double.parse(_equipmentDepreciationController.text),

        transportCost: double.parse(_transportCostController.text),
        
        profitMargin: double.parse(_profitMarginController.text),

        context: context,
      );



      bool success;

      if (widget.occasion == null) {

        success = await occasionProvider.addOccasion(occasion);

      } else {

        success = await occasionProvider.updateOccasion(

          occasion.copyWith(id: widget.occasion!.id),

        );

      }



      if (success) {

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(widget.occasion == null

                ? l10n.eventCreatedSuccessWithBooking

                : l10n.eventUpdatedSuccessfully),

            backgroundColor: AppColors.success,

          ),

        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(occasionProvider.errorMessage ?? l10n.failedToSaveEvent),

            backgroundColor: AppColors.error,

          ),

        );

      }

    } catch (e) {

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text('${l10n.error}: $e'),

          backgroundColor: AppColors.error,

        ),

      );

    } finally {

      setState(() {

        _isLoading = false;

      });

    }

  }

}