import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traiteur_management/core/utils/helpers.dart';
import 'package:traiteur_management/providers/category_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/add_article_dialog.dart';
import '../../core/widgets/add_edit_equipment_dialog.dart';
import '../../core/widgets/add_edit_meal_dialog.dart';
import '../../core/widgets/article_details_dialog.dart';
import '../../core/widgets/equipment_details_dialog.dart';
import '../../core/widgets/meal_details_dialog.dart';
import '../../core/widgets/image_picker_widget.dart'; // Import the new widget
import '../../models/article_model.dart';
import '../../models/category_model.dart';
import '../../models/equipment_model.dart';
import '../../models/meal_model.dart';
import '../../providers/stock_provider.dart';
import '../../core/widgets/loading_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, String?> _selectedCategories = {
    'articles': null,
    'equipment': null,
    'meals': null,
  };

  void handleCategorySelected(String type, String? category) {
    setState(() {
      _selectedCategories[type] = category;
    });

    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    stockProvider.applyCategoryFilters(_selectedCategories);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStockData();
    });
  }

  Future<void> _loadStockData() async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await stockProvider.loadAllStockData();
    final categoryProvider = Provider.of<CategoryProvider>(context, listen:false);
    await categoryProvider.loadCategories();
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
      title: Text(l10n.stockManagement),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStockData,
          tooltip: l10n.refresh,
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showStockAnalytics,
          tooltip: l10n.analytics,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchStockItems,
                  prefixIcon: const Icon(Icons.search, color: AppColors.white),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: AppColors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(color: AppColors.white),
                ),
                style: const TextStyle(color: AppColors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              tabs: [
                Tab(text: l10n.articles, icon: const Icon(Icons.inventory_2)),
                Tab(text: l10n.equipment, icon: const Icon(Icons.build)),
                Tab(text: l10n.meals, icon: const Icon(Icons.restaurant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: _showAddItemDialog,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.add, color: AppColors.white, semanticLabel: l10n.addItem),
    );
  }

  void _showAddItemDialog() {
    switch (_tabController.index) {
      case 0:
        _showAddArticleDialog(context);
        break;
      case 1:
        _showAddEquipmentDialog(context);
        break;
      case 2:
        _showAddMealDialog(context);
        break;
    }
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return LoadingWidget(message: '${l10n.loading} ${l10n.stockData}...');
        }

        return Column(
          children: [
            _buildQuickStats(stockProvider),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ArticlesTab(
                    searchQuery: _searchQuery,
                    selectedCategory: _selectedCategories['articles'],
                    onCategorySelected: (category) => handleCategorySelected('articles', category),
                  ),
                  EquipmentTab(
                    searchQuery: _searchQuery,
                    selectedCategory: _selectedCategories['equipment'],
                    onCategorySelected: (category) => handleCategorySelected('equipment', category),
                  ),
                  MealsTab(
                    searchQuery: _searchQuery,
                    selectedCategory: _selectedCategories['meals'],
                    onCategorySelected: (category) => handleCategorySelected('meals', category),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final stats = stockProvider.getStockSummary();

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard(
              l10n.totalArticles,
              stats['totalArticles'].toString(),
              Icons.inventory_2,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.equipment,
              stats['totalEquipment'].toString(),
              Icons.build,
              AppColors.secondary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.meals,
              stats['totalMeals'].toString(),
              Icons.restaurant,
              AppColors.success,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.lowStock,
              stats['lowStockArticles'].toString(),
              Icons.warning,
              AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  void _showStockAnalytics() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.stockAnalyticsComingSoon),
      ),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditArticleDialog(),
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditEquipmentDialog(),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditMealDialog(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// Articles Tab - Updated to use CustomImageDisplay
class ArticlesTab extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const ArticlesTab({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<ArticleModel> articles = _getFilteredArticles(stockProvider);

        return Column(
          children: [
            _buildCategoryFilters(
                stockProvider.articleCategories,
                'articles',
                selectedCategory,
                onCategorySelected, context
            ),
            Expanded(
              child: articles.isEmpty
                  ? _buildEmptyState(
                  l10n.noArticlesFound,
                  searchQuery.isNotEmpty || selectedCategory != null
                      ? l10n.adjustSearchFilters
                      : l10n.addFirstArticleHint,
                  Icons.inventory_2,
                      () => _showAddArticleDialog(context), context
              )
                  : RefreshIndicator(
                onRefresh: () => stockProvider.loadArticles(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return _buildArticleCard(context, articles[index], stockProvider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<ArticleModel> _getFilteredArticles(StockProvider stockProvider) {
    List<ArticleModel> articles = stockProvider.filteredArticles;

    if (searchQuery.isNotEmpty) {
      articles = stockProvider.searchArticles(searchQuery);
    }

    if (selectedCategory != null) {
      articles = articles.where((article) => article.category == selectedCategory).toList();
    }

    return articles;
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhere(
          (c) => c.id == article.category,
      orElse: () => CategoryModel(
        id: '',
        name: l10n.uncategorized,
        type: 'article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showArticleDetails(context, article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Updated to use CustomImageDisplay
                  CustomImageDisplay(
                    imagePath: article.imagePath,
                    width: 50,
                    height: 50,
                    defaultIcon: Icons.inventory_2,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                article.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: article.isLowStock
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${article.quantity} ${article.unit}',
                                style: TextStyle(
                                  color: article.isLowStock
                                      ? AppColors.error
                                      : AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (article.description != null && article.description!.isNotEmpty)
                          Text(
                            article.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleArticleAction(context, value, article, stockProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewDetails),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'quantity',
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.updateQuantity),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(l10n.price, Helpers.formatMAD(article.price), context),
                  const SizedBox(width: 8),
                  _buildInfoChip(l10n.totalValue, Helpers.formatMAD(article.totalValue), context),
                  const Spacer(),
                  if (article.isLowStock)
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
                            l10n.lowStock,
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

  void _handleArticleAction(BuildContext context, String action, ArticleModel article, StockProvider stockProvider) {
    switch (action) {
      case 'view':
        _showArticleDetails(context, article);
        break;
      case 'edit':
        _showEditArticleDialog(context, article);
        break;
      case 'quantity':
        _showUpdateQuantityDialog(context, article, stockProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, article, stockProvider);
        break;
    }
  }

  void _showArticleDetails(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder: (context) => ArticleDetailsDialog(article: article),
    );
  }

  void _showAddArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditArticleDialog(),
    );
  }

  void _showEditArticleDialog(BuildContext context, ArticleModel article) {
    showDialog(
      context: context,
      builder: (context) => AddEditArticleDialog(article: article),
    );
  }

  void _showUpdateQuantityDialog(BuildContext context, ArticleModel article, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: article.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.updateQuantity} - ${article.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${l10n.newQuantity} (${article.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null && newQuantity >= 0) {
                Navigator.pop(context);
                final success = await stockProvider.updateArticleQuantity(
                  article.id,
                  newQuantity,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.quantityUpdatedSuccess),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stockProvider.errorMessage ?? l10n.failedToUpdateQuantity,
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ArticleModel article, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteArticle),
        content: Text(l10n.deleteArticleConfirmation(article.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteArticle(article.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.articleDeletedSuccess),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteArticle,
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
}

// Equipment Tab - Updated to use CustomImageDisplay
class EquipmentTab extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const EquipmentTab({
    Key? key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<EquipmentModel> equipment = _getFilteredEquipment(stockProvider);

        return Column(
          children: [
            _buildCategoryFilters(
                stockProvider.equipmentCategories,
                'equipment',
                selectedCategory,
                onCategorySelected, context
            ),
            Expanded(
              child: equipment.isEmpty
                  ? _buildEmptyState(
                  l10n.noEquipmentFound,
                  searchQuery.isNotEmpty || selectedCategory != null
                      ? l10n.adjustSearchFilters
                      : l10n.addFirstEquipmentHint,
                  Icons.build,
                      () => _showAddEquipmentDialog(context), context
              )
                  : RefreshIndicator(
                onRefresh: () => stockProvider.loadEquipment(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    return _buildEquipmentCard(context, equipment[index], stockProvider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<EquipmentModel> _getFilteredEquipment(StockProvider stockProvider) {
    List<EquipmentModel> equipment = stockProvider.equipment;

    if (searchQuery.isNotEmpty) {
      equipment = stockProvider.searchEquipment(searchQuery);
    }

    if (selectedCategory != null) {
      equipment = equipment.where((item) => item.category == selectedCategory).toList();
    }

    return equipment;
  }

  Widget _buildEquipmentCard(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhere(
          (c) => c.id == equipment.category,
      orElse: () => CategoryModel(
        id: '',
        name: l10n.uncategorized,
        type: 'article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEquipmentDetails(context, equipment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Updated to use CustomImageDisplay
                  CustomImageDisplay(
                    imagePath: equipment.imagePath,
                    width: 50,
                    height: 50,
                    defaultIcon: Icons.build,
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                equipment.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: equipment.isAvailable
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                equipment.isAvailable ? l10n.available : l10n.allCheckedOut,
                                style: TextStyle(
                                  color: equipment.isAvailable
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
                          category.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (equipment.description != null && equipment.description!.isNotEmpty)
                          Text(
                            equipment.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEquipmentAction(context, value, equipment, stockProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewDetails),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'checkout',
                        child: Row(
                          children: [
                            const Icon(Icons.output, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.checkout),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'checkouts',
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewCheckouts),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.available}: ${equipment.availableQuantity}/${equipment.totalQuantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${equipment.availabilityPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: equipment.availabilityPercentage > 50
                              ? AppColors.success
                              : equipment.availabilityPercentage > 20
                              ? AppColors.warning
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: equipment.availabilityPercentage / 100,
                    backgroundColor: AppColors.greyLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      equipment.availabilityPercentage > 50
                          ? AppColors.success
                          : equipment.availabilityPercentage > 20
                          ? AppColors.warning
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (equipment.checkedOutQuantity > 0)
                    _buildInfoChip(
                        l10n.checkedOut,
                        equipment.checkedOutQuantity.toString(), context
                    ),
                  const SizedBox(width: 8),
                  if (equipment.isFullyCheckedOut)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.block, color: AppColors.error, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            l10n.allOut,
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

  void _handleEquipmentAction(BuildContext context, String action, EquipmentModel equipment, StockProvider stockProvider) {
    switch (action) {
      case 'view':
        _showEquipmentDetails(context, equipment);
        break;
      case 'edit':
        _showEditEquipmentDialog(context, equipment);
        break;
      case 'checkout':
        _showCheckoutDialog(context, equipment, stockProvider);
        break;
      case 'checkouts':
        _showEquipmentCheckouts(context, equipment);
        break;
      case 'delete':
        _showDeleteEquipmentConfirmation(context, equipment, stockProvider);
        break;
    }
  }

  void _showEquipmentDetails(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => EquipmentDetailsDialog(equipment: equipment),
    );
  }

  void _showAddEquipmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditEquipmentDialog(),
    );
  }

  void _showEditEquipmentDialog(BuildContext context, EquipmentModel equipment) {
    showDialog(
      context: context,
      builder: (context) => AddEditEquipmentDialog(equipment: equipment),
    );
  }

  void _showCheckoutDialog(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.equipmentCheckoutComingSoon),
      ),
    );
  }

  void _showEquipmentCheckouts(BuildContext context, EquipmentModel equipment) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.equipmentCheckoutHistoryComingSoon),
      ),
    );
  }

  void _showDeleteEquipmentConfirmation(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEquipment),
        content: Text(l10n.deleteEquipmentConfirmation(equipment.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteEquipment(equipment.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.equipmentDeletedSuccess),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteEquipment,
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
}

// Meals Tab - Updated to use CustomImageDisplay
class MealsTab extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const MealsTab({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<MealModel> meals = _getFilteredMeals(stockProvider);

        return Column(
          children: [
            _buildCategoryFilters(
                stockProvider.mealCategories,
                'meals',
                selectedCategory,
                onCategorySelected, context
            ),
            Expanded(
              child: meals.isEmpty
                  ? _buildEmptyState(
                  l10n.noMealsFound,
                  searchQuery.isNotEmpty || selectedCategory != null
                      ? l10n.adjustSearchFilters
                      : l10n.addFirstMealHint,
                  Icons.restaurant,
                      () => _showAddMealDialog(context), context
              )
                  : RefreshIndicator(
                onRefresh: () => stockProvider.loadMeals(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    return _buildMealCard(context, meals[index], stockProvider);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<MealModel> _getFilteredMeals(StockProvider stockProvider) {
    List<MealModel> meals = stockProvider.meals;

    if (searchQuery.isNotEmpty) {
      meals = stockProvider.searchMeals(searchQuery);
    }

    if (selectedCategory != null) {
      meals = meals.where((meal) => meal.category == selectedCategory).toList();
    }

    return meals;
  }

  Widget _buildMealCard(BuildContext context, MealModel meal, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final canBePrepared = stockProvider.canMealBePrepared(meal);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhere(
          (c) => c.id == meal.category,
      orElse: () => CategoryModel(
        id: '',
        name: l10n.uncategorized,
        type: 'article',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMealDetails(context, meal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Updated to use CustomImageDisplay
                  CustomImageDisplay(
                    imagePath: meal.imagePath,
                    width: 50,
                    height: 50,
                    defaultIcon: Icons.restaurant,
                    iconColor: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                meal.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: (meal.isAvailable && canBePrepared)
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (meal.isAvailable && canBePrepared)
                                    ? l10n.available
                                    : !meal.isAvailable
                                    ? l10n.disabled
                                    : l10n.outOfStock,
                                style: TextStyle(
                                  color: (meal.isAvailable && canBePrepared)
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
                          category.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          meal.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMealAction(context, value, meal, stockProvider),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewDetails),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: meal.isAvailable ? 'disable' : 'enable',
                        child: Row(
                          children: [
                            Icon(
                              meal.isAvailable ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(meal.isAvailable ? l10n.disable : l10n.enable),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInfoChip(l10n.cost, meal.calculatedPrice.toStringAsFixed(2), context),
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.price, meal.sellingPrice.toStringAsFixed(2), context),
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.profit, meal.profitMargin.toStringAsFixed(2), context),
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.servings, meal.servings.toString(), context),
                    const SizedBox(width: 8),
                    if (!canBePrepared && meal.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning, color: AppColors.warning, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              l10n.ingredientsLow,
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.minutes(meal.preparationTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.inventory, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.ingredientsCount(meal.ingredients.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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

  void _handleMealAction(BuildContext context, String action, MealModel meal, StockProvider stockProvider) {
    switch (action) {
      case 'view':
        _showMealDetails(context, meal);
        break;
      case 'edit':
        _showEditMealDialog(context, meal);
        break;
      case 'enable':
      case 'disable':
        _toggleMealAvailability(context, meal, stockProvider);
        break;
      case 'delete':
        _showDeleteMealConfirmation(context, meal, stockProvider);
        break;
    }
  }

  void _showMealDetails(BuildContext context, MealModel meal) {
    showDialog(
      context: context,
      builder: (context) => MealDetailsDialog(meal: meal),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditMealDialog(),
    );
  }

  void _showEditMealDialog(BuildContext context, MealModel meal) {
    showDialog(
      context: context,
      builder: (context) => AddEditMealDialog(meal: meal),
    );
  }

  void _toggleMealAvailability(BuildContext context, MealModel meal, StockProvider stockProvider) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await stockProvider.updateMealAvailability(meal.id, !meal.isAvailable);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            meal.isAvailable ? l10n.mealDisabledSuccess : l10n.mealEnabledSuccess,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stockProvider.errorMessage ?? l10n.failedToUpdateMealAvailability,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteMealConfirmation(BuildContext context, MealModel meal, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMeal),
        content: Text(l10n.deleteMealConfirmation(meal.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteMeal(meal.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.mealDeletedSuccess),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteMeal,
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
}

// Common helper widgets and functions
Widget _buildCategoryFilters(
    List<String> categories,
    String type,
    String? selectedCategory,
    Function(String?) onCategorySelected, BuildContext context
    ) {
  final l10n = AppLocalizations.of(context)!;
  if (categories.isEmpty) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(l10n.all),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  onCategorySelected(null);
                },
              ),
            );
          }

          final category = categories[index - 1];
          final categoryProvider = Provider.of<CategoryProvider>(context);
          final categorie = categoryProvider.categories.firstWhere(
                (c) => c.id == category,
            orElse: () => CategoryModel(
              id: '',
              name: l10n.uncategorized,
              type: 'article',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categorie.name),
              selected: selectedCategory == category,
              onSelected: (selected) {
                onCategorySelected(selected ? category : null);
              },
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildEmptyState(String title, String subtitle, IconData icon, VoidCallback onAdd, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 64,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(l10n.addItem),
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String label, String value, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.greyLight.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$label: $value',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
  );
}