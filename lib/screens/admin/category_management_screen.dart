// category_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/core/constants/app_colors.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryManagement),
        bottom: TabBar(
          unselectedLabelColor: AppColors.white,
          labelColor: AppColors.secondary,
          controller: _tabController,
          tabs: [
            Tab(text: l10n.articles),
            Tab(text: l10n.meals),
            Tab(text: l10n.equipment),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, _tabController.index),
        child: const Icon(Icons.add),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,

            children: [
              _buildCategoryList(provider.getCategoriesByType('article')),
              _buildCategoryList(provider.getCategoriesByType('meal')),
              _buildCategoryList(provider.getCategoriesByType('equipment')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: category.icon != null
              ? Icon(IconData(int.parse(category.icon!), fontFamily: 'MaterialIcons'))
              : const Icon(Icons.category),
          title: Text(category.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditCategoryDialog(context, category),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(context, category),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, int tabIndex) {
    final type = ['article', 'meal', 'equipment'][tabIndex];
    _showCategoryDialog(context, null, type);
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    _showCategoryDialog(context, category, category.type);
  }

  void _showCategoryDialog(BuildContext context, CategoryModel? category, String type) {
    final l10n = AppLocalizations.of(context);
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final nameController = TextEditingController(text: category?.name ?? '');
    final iconController = TextEditingController(text: category?.icon ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? l10n.addCategory : l10n.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.validationEnterCategoryName;
                }
                return null;
              },
            ),
            // const SizedBox(height: 16),
            // TextFormField(
            //   controller: iconController,
            //   decoration: InputDecoration(
            //     labelText: '${l10n.icon} (${l10n.optional})',
            //     border: const OutlineInputBorder(),
            //     hintText: 'e.g., 0xe3c9 for restaurant icon',
            //   ),
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCategory = CategoryModel(
                id: category?.id ?? '',
                name: nameController.text.trim(),
                type: type,
                icon: iconController.text.trim().isEmpty ? null : iconController.text.trim(),
                createdAt: category?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (category == null) {
                await provider.addCategory(newCategory);
              } else {
                await provider.updateCategory(newCategory);
              }
              Navigator.pop(context);
            },
            child: Text(category == null ? l10n.add : l10n.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CategoryModel category) {
    final l10n = AppLocalizations.of(context);
    final provider = Provider.of<CategoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.confirmDeleteCategory(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}