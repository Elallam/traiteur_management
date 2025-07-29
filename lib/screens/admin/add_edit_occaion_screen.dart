import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/equipment_model.dart';
import '../../models/meal_model.dart';
import '../../models/occasion_model.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/equipment_booking_provider.dart';
import '../../core/widgets/equipment_availability_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

class AddOccasionDialog extends StatefulWidget {
  final OccasionModel? occasion;

  const AddOccasionDialog({Key? key, this.occasion}) : super(key: key);

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

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  // Meals and Equipment
  List<OccasionMeal> _selectedMeals = [];
  List<OccasionEquipment> _selectedEquipment = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.occasion != null) {
      _populateFields();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStockData();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.occasion == null ? l10n.createNewEvent : l10n.editOccasion, // Localized
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: l10n.basicInfo), // Localized
                Tab(text: l10n.meals), // Localized
                Tab(text: l10n.equipment), // Localized
              ],
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
                  ],
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: l10n.cancel, // Localized
                    onPressed: () => Navigator.pop(context),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: widget.occasion == null ? l10n.createEvent : l10n.updateEvent, // Localized
                    onPressed: _saveOccasion,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          CustomTextField(
            label: l10n.eventTitle, // Localized
            controller: _titleController,
            validator: Validators.required,
            hint: l10n.enterEventTitle, // Localized
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.description, // Localized
            controller: _descriptionController,
            validator: Validators.required,
            hint: l10n.describeEvent, // Localized
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
            label: l10n.eventAddress, // Localized
            controller: _addressController,
            validator: Validators.required,
            hint: l10n.enterCompleteAddress, // Localized
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.expectedGuests, // Localized
            controller: _expectedGuestsController,
            validator: Validators.required,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hint: l10n.numberOfGuests, // Localized
          ),
          const SizedBox(height: 24),

          // Client Information
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.clientInformation, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientName, // Localized
            controller: _clientNameController,
            validator: Validators.required,
            hint: l10n.enterClientName, // Localized
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientPhone, // Localized
            controller: _clientPhoneController,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            hint: l10n.enterPhoneNumber, // Localized
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.clientEmail, // Localized
            controller: _clientEmailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            hint: l10n.enterEmailAddress, // Localized
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: l10n.notesOptional, // Localized
            controller: _notesController,
            hint: l10n.additionalNotes, // Localized
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventDate, // Localized
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
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventTime, // Localized
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
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableMeals = stockProvider.getAvailableMeals();

        return Column(
          children: [
            // Selected Meals Summary
            if (_selectedMeals.isNotEmpty) ...[
              _buildSelectedMealsSummary(),
              const SizedBox(height: 16),
            ],

            // Available Meals
            Expanded(
              child: ListView.builder(
                itemCount: availableMeals.length,
                itemBuilder: (context, index) {
                  final meal = availableMeals[index];
                  final isSelected = _selectedMeals.any((m) => m.mealId == meal.id);
                  final selectedMeal = isSelected
                      ? _selectedMeals.firstWhere((m) => m.mealId == meal.id)
                      : null;

                  return _buildMealCard(meal, isSelected, selectedMeal?.quantity ?? 0);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedMealsSummary() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    double totalPrice = _selectedMeals.fold(0.0, (sum, meal) => sum + meal.totalPrice);

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
                  l10n.selectedMeals, // Localized
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.mealsSelected(_selectedMeals.length), // Localized
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MealModel meal, bool isSelected, int quantity) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
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
                        meal.description,
                        style: const TextStyle(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.pricePerServing(meal.sellingPrice.toStringAsFixed(2)), // Localized
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
                        children: [
                          IconButton(
                            onPressed: () => _updateMealQuantity(meal, quantity - 1),
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _updateMealQuantity(meal, quantity + 1),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ] else ...[
                      CustomButton(
                        text: l10n.add, // Localized
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
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Consumer2<StockProvider, EquipmentBookingProvider>(
      builder: (context, stockProvider, bookingProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableEquipment = stockProvider.getAvailableEquipment();
        final groupedEquipment = <String, List<EquipmentModel>>{};

        for (var equipment in availableEquipment) {
          if (!groupedEquipment.containsKey(equipment.category)) {
            groupedEquipment[equipment.category] = [];
          }
          groupedEquipment[equipment.category]!.add(equipment);
        }

        return Column(
          children: [
            // Equipment Availability Widget - NEW
            EquipmentAvailabilityWidget(
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

            const SizedBox(height: 16),

            // Rest of your existing equipment selection UI
            if (_selectedEquipment.isNotEmpty) ...[
              _buildSelectedEquipmentSummary(),
              const SizedBox(height: 16),
            ],

            // Equipment by Category
            Expanded(
              child: ListView.builder(
                itemCount: groupedEquipment.keys.length,
                itemBuilder: (context, index) {
                  final category = groupedEquipment.keys.elementAt(index);
                  final categoryEquipment = groupedEquipment[category]!;

                  return _buildEquipmentCategory(category, categoryEquipment);
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildSelectedEquipmentSummary() {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Card(
      color: AppColors.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  l10n.selectedEquipment, // Localized
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.itemsSelected(_selectedEquipment.length), // Localized
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCategory(String category, List<EquipmentModel> equipment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...equipment.map((eq) {
          final isSelected = _selectedEquipment.any((e) => e.equipmentId == eq.id);
          final selectedEquipment = isSelected
              ? _selectedEquipment.firstWhere((e) => e.equipmentId == eq.id)
              : null;

          return _buildEquipmentCard(eq, isSelected, selectedEquipment?.quantity ?? 0);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment, bool isSelected, int quantity) {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    equipment.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (equipment.description != null) ...[
                    Text(
                      equipment.description!,
                      style: const TextStyle(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    l10n.availableQuantityTotal(equipment.availableQuantity, equipment.totalQuantity), // Localized
                    style: TextStyle(
                      color: equipment.availableQuantity > 0
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              Row(
                children: [
                  IconButton(
                    onPressed: () => _updateEquipmentQuantity(equipment, quantity - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: quantity < equipment.availableQuantity
                        ? () => _updateEquipmentQuantity(equipment, quantity + 1)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ] else ...[
              CustomButton(
                text: l10n.add, // Localized
                onPressed: equipment.availableQuantity > 0
                    ? () => _addEquipment(equipment)
                    : null,
                width: 80,
                height: 36,
              ),
            ],
          ],
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
      _selectedEquipment.add(OccasionEquipment(
        equipmentId: equipment.id,
        equipmentName: equipment.name,
        quantity: 1,
        status: 'assigned',
      ));
    });
  }

  void _updateEquipmentQuantity(EquipmentModel equipment, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _selectedEquipment.removeWhere((e) => e.equipmentId == equipment.id);
      } else {
        final index = _selectedEquipment.indexWhere((e) => e.equipmentId == equipment.id);
        if (index != -1) {
          _selectedEquipment[index] = _selectedEquipment[index].copyWith(
            quantity: newQuantity,
          );
        }
      }
    });
  }

  Future<void> _saveOccasion() async {
    final l10n = AppLocalizations.of(context)!; // Localizations instance
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectAtLeastOneMeal), // Localized
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
            content: Text(l10n.equipmentAvailabilityConflicts), // Localized
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
                : l10n.eventUpdatedSuccessfully), // Localized
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(occasionProvider.errorMessage ?? l10n.failedToSaveEvent), // Localized fallback
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!; // Localizations instance
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'), // Localized error message
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
