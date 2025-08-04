// core/widgets/admin/occasion/add_edit_occasion/meals_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/meal_model.dart';
import '../../../../../models/occasion_model.dart';
import '../../../../../providers/stock_provider.dart';

class MealsTab extends StatelessWidget {
  final List<OccasionMeal> selectedMeals;
  final Function(MealModel, int) onMealUpdated;
  final Function(MealModel) onMealAdded;

  const MealsTab({
    super.key,
    required this.selectedMeals,
    required this.onMealUpdated,
    required this.onMealAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (selectedMeals.isNotEmpty) ...[
                _SelectedMealsSummary(meals: selectedMeals),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: stockProvider.getAvailableMeals().length,
                  itemBuilder: (context, index) {
                    final meal = stockProvider.getAvailableMeals()[index];
                    final isSelected = selectedMeals.any((m) => m.mealId == meal.id);
                    final selectedMeal = isSelected
                        ? selectedMeals.firstWhere((m) => m.mealId == meal.id)
                        : null;

                    return _MealCard(
                      meal: meal,
                      isSelected: isSelected,
                      quantity: selectedMeal?.quantity ?? 0,
                      onAdd: () => onMealAdded(meal),
                      onQuantityChanged: (newQuantity) =>
                          onMealUpdated(meal, newQuantity),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectedMealsSummary extends StatelessWidget {
  final List<OccasionMeal> meals;

  const _SelectedMealsSummary({required this.meals});

  @override
  Widget build(BuildContext context) {
    final totalPrice = meals.fold(
        0.0,
            (sum, meal) => sum + meal.totalPrice
    );

    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Selected Meals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${meals.length} meals selected',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealModel meal;
  final bool isSelected;
  final int quantity;
  final VoidCallback onAdd;
  final Function(int) onQuantityChanged;

  const _MealCard({
    required this.meal,
    required this.isSelected,
    required this.quantity,
    required this.onAdd,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                        ),
                      ),
                      Text(
                        meal.description,
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${meal.sellingPrice.toStringAsFixed(2)} per serving',
                        style: const TextStyle(
                          color: Colors.blue,
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
                            onPressed: () => onQuantityChanged(quantity - 1),
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
                            onPressed: () => onQuantityChanged(quantity + 1),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: onAdd,
                        child: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 36),
                        ),
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
}