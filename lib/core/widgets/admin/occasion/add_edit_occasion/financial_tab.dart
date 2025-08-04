// core/widgets/admin/occasion/add_edit_occasion/financial_tab.dart
import 'package:flutter/material.dart';
import 'package:traiteur_management/core/utils/helpers.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';
import 'package:traiteur_management/generated/l10n/app_localizations_ar.dart';

import '../../../../../models/occasion_model.dart';

// lib/core/widgets/admin/occasion/add_edit_occasion/financial_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/stock_provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class FinancialTab extends StatefulWidget {
  final List<OccasionMeal> selectedMeals;
  final List<OccasionEquipment> selectedEquipment;
  final TextEditingController equipmentDepreciationController;
  final TextEditingController profitMarginController;
  final TextEditingController transportCostController;

  const FinancialTab({
    Key? key,
    required this.selectedMeals,
    required this.selectedEquipment,
    required this.equipmentDepreciationController,
    required this.profitMarginController,
    required this.transportCostController,
  }) : super(key: key);

  @override
  State<FinancialTab> createState() => _FinancialTabState();
}

class _FinancialTabState extends State<FinancialTab> {
  double _equipmentRentalPrice = 0.0;
  double _transportPrice = 0.0;
  double _profitMarginPercentage = 15.0; // Default 15%

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    widget.profitMarginController.text = _profitMarginPercentage.toString();
    widget.transportCostController.text = _transportPrice.toString();
    widget.equipmentDepreciationController.text =
        _equipmentRentalPrice.toString();

    // Calculate initial equipment rental price
    _calculateEquipmentRentalPrice();
  }

  void _calculateEquipmentRentalPrice() {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    double totalRentalPrice = 0.0;

    for (var eq in widget.selectedEquipment) {
      final equipment = stockProvider.getEquipmentById(eq.equipmentId);
      if (equipment != null) {
        // Use equipment's rental price or calculate depreciation-based price
        double unitRentalPrice = equipment.price!; // 10% of purchase price as default
        totalRentalPrice += unitRentalPrice * eq.quantity;
      }
    }

    setState(() {
      _equipmentRentalPrice = totalRentalPrice;
      widget.equipmentDepreciationController.text =
          _equipmentRentalPrice.toStringAsFixed(2);
    });
  }

  double get _mealsCost {
    return widget.selectedMeals.fold(0.0, (sum, meal) => sum + meal.totalPrice);
  }

  double get _baseCost {
    return _mealsCost + _equipmentRentalPrice + _transportPrice;
  }

  double get _calculatedProfit {
    return _baseCost * (_profitMarginPercentage / 100);
  }

  double get _finalTotalPrice {
    return _baseCost + _calculatedProfit;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cost Breakdown Section
          _buildCostBreakdownCard(),
          const SizedBox(height: 24),

          // Equipment Rental Configuration
          _buildEquipmentRentalCard(),
          const SizedBox(height: 16),

          // Transport Cost Configuration
          _buildTransportCostCard(),
          const SizedBox(height: 16),

          // Profit Margin Configuration
          _buildProfitMarginCard(),
          const SizedBox(height: 24),

          // Final Pricing Summary
          _buildPricingSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildCostBreakdownCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.costBreakdown,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Meals Cost
            _buildCostRow(
              icon: Icons.restaurant_menu,
              label: l10n.mealsCost,
              amount: _mealsCost,
              color: AppColors.info,
              details: '${widget.selectedMeals.length} ${l10n.items}',
            ),

            const SizedBox(height: 12),

            // Equipment Rental Cost
            _buildCostRow(
              icon: Icons.inventory,
              label: l10n.equipmentRental,
              amount: _equipmentRentalPrice,
              color: AppColors.warning,
              details: '${widget.selectedEquipment.length} ${l10n.items}',
            ),

            const SizedBox(height: 12),

            // Transport Cost
            _buildCostRow(
              icon: Icons.local_shipping,
              label: l10n.transportCost,
              amount: _transportPrice,
              color: AppColors.secondary,
            ),

            const Divider(height: 24),

            // Total Base Cost
            _buildCostRow(
              icon: Icons.calculate,
              label: l10n.totalBaseCost,
              amount: _baseCost,
              color: AppColors.textPrimary,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    String? details,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
              if (details != null)
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          Helpers.formatMAD(amount),
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentRentalCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.equipmentRentalPricing,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: l10n.totalEquipmentRentalPrice,
              controller: widget.equipmentDepreciationController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              onChanged: (value) {
                setState(() {
                  _equipmentRentalPrice = double.tryParse(value) ?? 0.0;
                });
              },
              hint: l10n.enterEquipmentRentalPrice,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateEquipmentRentalPrice,
                    icon: const Icon(Icons.auto_fix_high, size: 16),
                    label: Text(l10n.autoCalculate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning.withOpacity(0.1),
                      foregroundColor: AppColors.warning,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),

            if (widget.selectedEquipment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.equipmentBreakdown,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.selectedEquipment.map((eq) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${eq.equipmentName} x${eq.quantity}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Text(
                                '\$${(eq.totalRentalPrice).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransportCostCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  l10n.transportConfiguration,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              label: l10n.transportDeliveryCost,
              controller: widget.transportCostController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              onChanged: (value) {
                setState(() {
                  _transportPrice = double.tryParse(value) ?? 0.0;
                });
              },
              hint: l10n.enterTransportCost,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitMarginCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and text
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.profitMarginConfiguration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text field for profit margin input
            CustomTextField(
              label: l10n.profitMarginPercentage,
              controller: widget.profitMarginController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              onChanged: (value) {
                setState(() {
                  _profitMarginPercentage = double.tryParse(value) ?? 0.0;
                });
              },
              hint: l10n.enterProfitMargin,
            ),

            const SizedBox(height: 12),

            // Quick margin buttons - improved Wrap with runSpacing
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8, // Vertical spacing between lines
                  children: [10.0, 15.0, 20.0, 25.0, 30.0].map((margin) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth / 3 - 12, // 3 items per row
                      ),
                      child: ChoiceChip(
                        label: Text(
                          '${margin.toInt()}%',
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: _profitMarginPercentage == margin,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _profitMarginPercentage = margin;
                              widget.profitMarginController.text = margin.toString();
                            });
                          }
                        },
                        selectedColor: AppColors.success.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _profitMarginPercentage == margin
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: _profitMarginPercentage == margin
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummaryCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 3,
      color: AppColors.success.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  l10n.finalPricingSummary,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Base Cost
            _buildSummaryRow(
              label: l10n.baseCost,
              amount: _baseCost,
              color: AppColors.textPrimary,
            ),

            const SizedBox(height: 8),

            // Profit Amount
            _buildSummaryRow(
              label: l10n.profitAmount,
              amount: _calculatedProfit,
              color: AppColors.success,
              subtitle: '${_profitMarginPercentage.toStringAsFixed(1)}% ${l10n
                  .margin}',
            ),

            const Divider(height: 24),

            // Final Total Price
            _buildSummaryRow(
              label: l10n.finalTotalPrice,
              amount: _finalTotalPrice,
              color: AppColors.success,
              isTotal: true,
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required double amount,
    required Color color,
    String? subtitle,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 18 : 16,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          Helpers.formatMAD(amount),
          style: TextStyle(
            fontSize: isTotal ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}