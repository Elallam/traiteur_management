// lib/screens/employee/equipment_checkout.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/loading_widget.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/equipment_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class EquipmentCheckoutScreen extends StatefulWidget {
  final String? occasionId;
  final String? occasionTitle;

  const EquipmentCheckoutScreen({
    super.key,
    this.occasionId,
    this.occasionTitle,
  });

  @override
  State<EquipmentCheckoutScreen> createState() => _EquipmentCheckoutScreenState();
}

class _EquipmentCheckoutScreenState extends State<EquipmentCheckoutScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<EquipmentModel> _allEquipment = [];
  List<EquipmentModel> _filteredEquipment = [];
  Map<String, int> _checkoutQuantities = {};
  String _selectedCategory = 'All'; // This will be updated with localized string
  bool _isLoading = false;
  bool _isCheckingOut = false;

  late TabController _tabController;
  // Categories will be dynamically built based on localized strings
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize _categories after context is available for localization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategories();
    });
    _loadEquipment();
  }

  void _initializeCategories() {
    setState(() {
      final localizations = AppLocalizations.of(context)!;
      _categories = [
        localizations.all,
        localizations.chairs,
        localizations.tables,
        localizations.utensils,
        localizations.decorations,
        localizations.other
      ];
      _tabController = TabController(length: _categories.length, vsync: this);
      _tabController.addListener(_handleTabSelection); // Add listener for tab changes
      _selectedCategory = _categories[0]; // Set initial selected category to 'All' (localized)
      _filterEquipment(); // Filter initially based on 'All'
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
        _filterEquipment();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _tabController.removeListener(_handleTabSelection); // Remove listener
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipment() async {
    setState(() => _isLoading = true);
    try {
      _allEquipment = await _firestoreService.getEquipment();
      _filterEquipment();
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.failedToLoadEquipment(e.toString()));
    }
    setState(() => _isLoading = false);
  }

  void _filterEquipment() {
    setState(() {
      // Get the original English category names for filtering logic
      final localizations = AppLocalizations.of(context)!;
      final Map<String, String> localizedCategoryMap = {
        localizations.all: 'All',
        localizations.chairs: 'chairs',
        localizations.tables: 'tables',
        localizations.utensils: 'utensils',
        localizations.decorations: 'decorations',
        localizations.other: 'other',
      };
      final String actualSelectedCategory = localizedCategoryMap[_selectedCategory] ?? 'All';


      _filteredEquipment = _allEquipment.where((equipment) {
        // Filter by active status
        if (!equipment.isActive) return false;

        // Filter by category
        if (actualSelectedCategory != 'All' && equipment.category != actualSelectedCategory) {
          return false;
        }

        // Filter by search query
        if (_searchController.text.isNotEmpty) {
          return equipment.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }

        return true;
      }).toList();

      // Sort by availability (available first) then by name
      _filteredEquipment.sort((a, b) {
        if (a.isAvailable != b.isAvailable) {
          return a.isAvailable ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    });
  }

  void _updateQuantity(String equipmentId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _checkoutQuantities.remove(equipmentId);
      } else {
        _checkoutQuantities[equipmentId] = quantity;
      }
    });
  }

  int _getTotalSelectedItems() {
    return _checkoutQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double _getTotalSelectedTypes() {
    return _checkoutQuantities.length.toDouble();
  }

  Future<void> _performCheckout() async {
    final localizations = AppLocalizations.of(context)!;
    if (_checkoutQuantities.isEmpty) {
      _showErrorSnackBar(localizations.pleaseSelectEquipmentToCheckout);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel? currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showErrorSnackBar(localizations.userNotAuthenticated);
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      // Validate availability for all selected equipment
      bool allAvailable = true;
      List<String> unavailableItems = [];

      for (String equipmentId in _checkoutQuantities.keys) {
        EquipmentModel equipment = _allEquipment.firstWhere((eq) => eq.id == equipmentId);
        int requestedQuantity = _checkoutQuantities[equipmentId]!;

        if (equipment.availableQuantity < requestedQuantity) {
          allAvailable = false;
          unavailableItems.add('${equipment.name} (${localizations.requested}: $requestedQuantity, ${localizations.available}: ${equipment.availableQuantity})');
        }
      }

      if (!allAvailable) {
        _showUnavailabilityDialog(unavailableItems);
        return;
      }

      // Process checkout for each selected equipment
      List<EquipmentCheckout> checkouts = [];

      for (String equipmentId in _checkoutQuantities.keys) {
        EquipmentModel equipment = _allEquipment.firstWhere((eq) => eq.id == equipmentId);
        int quantity = _checkoutQuantities[equipmentId]!;

        // Create checkout record
        EquipmentCheckout checkout = EquipmentCheckout(
          id: '', // Will be generated by Firestore
          equipmentId: equipmentId,
          employeeId: currentUser.id,
          employeeName: currentUser.fullName,
          quantity: quantity,
          checkoutDate: DateTime.now(),
          occasionId: widget.occasionId,
          status: 'checked_out',
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        // Add checkout to Firestore
        await _firestoreService.addEquipmentCheckout(checkout);

        // Update equipment availability using your existing method
        await _firestoreService.updateEquipmentAvailability(
            equipmentId,
            equipment.availableQuantity - quantity
        );

        checkouts.add(checkout);
      }

      // Show success and navigate back
      _showSuccessDialog(checkouts.length, _getTotalSelectedItems().toInt());

    } catch (e) {
      _showErrorSnackBar('${localizations.checkoutFailed}: $e');
    } finally {
      setState(() => _isCheckingOut = false);
    }
  }

  void _showSuccessDialog(int itemTypes, int totalQuantity) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 64,
        ),
        title: Text(localizations.checkoutSuccessful),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.successfullyCheckedOut,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.equipmentTypesCount(itemTypes),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              localizations.totalItemsCount(totalQuantity),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (widget.occasionTitle != null) ...[
              const SizedBox(height: 12),
              Text(
                '${localizations.forText}: ${widget.occasionTitle}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          CustomButton(
            text: localizations.done,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous screen with success
            },
          ),
        ],
      ),
    );
  }

  void _showUnavailabilityDialog(List<String> unavailableItems) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_outlined,
          color: AppColors.warning,
          size: 64,
        ),
        title: Text(localizations.equipmentUnavailable),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.equipmentNotAvailableInRequestedQuantity),
            const SizedBox(height: 12),
            ...unavailableItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: const TextStyle(color: AppColors.error)),
            )),
            const SizedBox(height: 12),
            Text(localizations.adjustQuantitiesOrRemoveUnavailableItems),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading ? const LoadingWidget() : _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.equipmentCheckout),
          if (widget.occasionTitle != null)
            Text(
              widget.occasionTitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (_checkoutQuantities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_getTotalSelectedTypes().toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.white,
        onTap: (index) {
          setState(() {
            _selectedCategory = _categories[index];
            _filterEquipment();
          });
        },
        tabs: _categories.map((category) => Tab(
          text: category.capitalize(localizations), // Categories are already localized
        )).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomTextField(
            controller: _searchController,
            label: localizations.searchEquipment,
            prefixIcon: Icons.search,
            onChanged: (_) => _filterEquipment(),
          ),
        ),

        // Equipment list
        Expanded(
          child: _filteredEquipment.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredEquipment.length,
            itemBuilder: (context, index) {
              return _buildEquipmentCard(_filteredEquipment[index], context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.noEquipmentFound,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? localizations.tryAdjustingYourSearchTerms
                : localizations.noEquipmentAvailableInCategory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(EquipmentModel equipment, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isSelected = _checkoutQuantities.containsKey(equipment.id);
    final selectedQuantity = _checkoutQuantities[equipment.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Equipment image/icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(equipment.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: equipment.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      equipment.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _getCategoryIcon(equipment.category),
                        color: _getCategoryColor(equipment.category),
                        size: 28,
                      ),
                    ),
                  )
                      : Icon(
                    _getCategoryIcon(equipment.category),
                    color: _getCategoryColor(equipment.category),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Equipment details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipment.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipment.category.capitalize(localizations),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getCategoryColor(equipment.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            equipment.isAvailable ? Icons.check_circle : Icons.error,
                            size: 16,
                            color: equipment.isAvailable ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizations.availableQuantityTotal(equipment.availableQuantity, equipment.totalQuantity),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: equipment.isAvailable ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Availability indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: equipment.isAvailable
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${equipment.availabilityPercentage.toInt()}%',
                    style: TextStyle(
                      color: equipment.isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            if (equipment.description != null) ...[
              const SizedBox(height: 12),
              Text(
                equipment.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.quantityToCheckout,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: equipment.isAvailable && selectedQuantity > 0
                          ? () => _updateQuantity(equipment.id, selectedQuantity - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          selectedQuantity.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: equipment.isAvailable && selectedQuantity < equipment.availableQuantity
                          ? () => _updateQuantity(equipment.id, selectedQuantity + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (_checkoutQuantities.isEmpty) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Notes field
          CustomTextField(
            controller: _notesController,
            label: localizations.notesOptional,
            maxLines: 2,
            prefixIcon: Icons.note_alt_outlined,
          ),
          const SizedBox(height: 16),

          // Summary and checkout button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.typesSelected(localizations.equipmentTypesCount(_getTotalSelectedTypes().toInt())),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      localizations.totalItemsCount(_getTotalSelectedItems()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 140,
                child: CustomButton(
                  text: _isCheckingOut ? localizations.processing : localizations.checkout,
                  onPressed: _isCheckingOut ? null : _performCheckout,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chairs':
        return Colors.blue;
      case 'tables':
        return Colors.green;
      case 'utensils':
        return Colors.orange;
      case 'decorations':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chairs':
        return Icons.chair;
      case 'tables':
        return Icons.table_restaurant;
      case 'utensils':
        return Icons.restaurant;
      case 'decorations':
        return Icons.celebration;
      default:
        return Icons.inventory;
    }
  }
}

extension StringExtension on String {
  String capitalize(AppLocalizations localizations) {
    // Check if the string is one of the category keys and return its localized capitalized version
    switch (this.toLowerCase()) {
      case 'all':
        return localizations.all;
      case 'chairs':
        return localizations.chairs.capitalizeFirstofEach;
      case 'tables':
        return localizations.tables.capitalizeFirstofEach;
      case 'utensils':
        return localizations.utensils.capitalizeFirstofEach;
      case 'decorations':
        return localizations.decorations.capitalizeFirstofEach;
      case 'other':
        return localizations.other.capitalizeFirstofEach;
      default:
        if (isEmpty) return this;
        return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
  }

  // Helper to capitalize the first letter of each word
  String get capitalizeFirstofEach {
    return split(" ").map((str) => str.isEmpty ? "" : "${str[0].toUpperCase()}${str.substring(1)}").join(" ");
  }
}
