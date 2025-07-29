import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/add_article_dialog.dart';
import '../../core/widgets/add_edit_equipment_dialog.dart';
import '../../core/widgets/add_edit_meal_dialog.dart';
import '../../core/widgets/article_details_dialog.dart';
import '../../core/widgets/equipment_details_dialog.dart';
import '../../core/widgets/meal_details_dialog.dart';
import '../../models/article_model.dart';
import '../../models/equipment_model.dart';
import '../../models/meal_model.dart';
import '../../providers/stock_provider.dart';
import '../../core/widgets/loading_widget.dart';
import 'package:traiteur_management/generated/l10n/app_localizations.dart'; // Import localization

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

  // Add this method to handle category selection
  void handleCategorySelected(String type, String? category) {
    setState(() {
      _selectedCategories[type] = category;
    });

    // Refresh the data with the new filter
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
      title: Text(l10n.stockManagement), // Localized title
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStockData,
          tooltip: l10n.refresh, // Localized tooltip
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showStockAnalytics,
          tooltip: l10n.analytics, // Localized tooltip
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchStockItems, // Localized hint text
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
            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.white,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.white.withOpacity(0.7),
              tabs: [
                Tab(text: l10n.articles, icon: const Icon(Icons.inventory_2)), // Localized
                Tab(text: l10n.equipment, icon: const Icon(Icons.build)), // Localized
                Tab(text: l10n.meals, icon: const Icon(Icons.restaurant)), // Localized
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
      child: Icon(Icons.add, color: AppColors.white, semanticLabel: l10n.addItem), // Localized semantic label
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
          return LoadingWidget(message: '${l10n.loading} ${l10n.stockData}...'); // Localized loading message
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
              l10n.totalArticles, // Localized
              stats['totalArticles'].toString(),
              Icons.inventory_2,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.equipment, // Localized
              stats['totalEquipment'].toString(),
              Icons.build,
              AppColors.secondary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.meals, // Localized
              stats['totalMeals'].toString(),
              Icons.restaurant,
              AppColors.success,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              l10n.lowStock, // Localized
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
    // TODO: Implement stock analytics dialog
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.stockAnalyticsComingSoon), // Localized
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

// Articles Tab
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
            // Filter Chips
            _buildCategoryFilters(
              stockProvider.articleCategories,
              'articles',
              selectedCategory,
              onCategorySelected, context
            ),
            // Articles List
            Expanded(
              child: articles.isEmpty
                  ? _buildEmptyState(
                l10n.noArticlesFound, // Localized
                searchQuery.isNotEmpty || selectedCategory != null
                    ? l10n.adjustSearchFilters // Localized
                    : l10n.addFirstArticleHint, // Localized
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

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      articles = stockProvider.searchArticles(searchQuery);
    }

    // Apply category filter
    if (selectedCategory != null) {
      articles = articles.where((article) => article.category == selectedCategory).toList();
    }

    return articles;
  }

  Widget _buildArticleCard(BuildContext context, ArticleModel article, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
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
                  // Article Image or Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: article.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2,
                            color: AppColors.primary,
                            size: 24,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.inventory_2,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Article Info
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
                            // Quantity Badge
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
                          article.category.toUpperCase(),
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
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleArticleAction(context, value, article, stockProvider),
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
                        value: 'quantity',
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.updateQuantity), // Localized
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
              // Price and Total Value
              Row(
                children: [
                  _buildInfoChip(l10n.price, '\$${article.price.toStringAsFixed(2)}', context), // Localized
                  const SizedBox(width: 8),
                  _buildInfoChip(l10n.totalValue, '\$${article.totalValue.toStringAsFixed(2)}', context), // Localized
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
                            l10n.lowStock, // Localized
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
        title: Text('${l10n.updateQuantity} - ${article.name}'), // Localized title
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '${l10n.newQuantity} (${article.unit})', // Localized label
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
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
                      content: Text(l10n.quantityUpdatedSuccess), // Localized
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stockProvider.errorMessage ?? l10n.failedToUpdateQuantity, // Localized fallback
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.update), // Localized
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
        title: Text(l10n.deleteArticle), // Localized
        content: Text(l10n.deleteArticleConfirmation(article.name)), // Localized with parameter
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteArticle(article.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.articleDeletedSuccess), // Localized
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteArticle, // Localized fallback
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
}

// Equipment Tab
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
            // Filter Chips
            _buildCategoryFilters(
              stockProvider.equipmentCategories,
              'equipment',
              selectedCategory,
              onCategorySelected, context
            ),
            // Equipment List
            Expanded(
              child: equipment.isEmpty
                  ? _buildEmptyState(
                l10n.noEquipmentFound, // Localized
                searchQuery.isNotEmpty || selectedCategory != null
                    ? l10n.adjustSearchFilters // Localized
                    : l10n.addFirstEquipmentHint, // Localized
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

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      equipment = stockProvider.searchEquipment(searchQuery);
    }

    // Apply category filter
    if (selectedCategory != null) {
      equipment = equipment.where((item) => item.category == selectedCategory).toList();
    }

    return equipment;
  }

  Widget _buildEquipmentCard(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
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
                  // Equipment Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: equipment.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        equipment.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.build,
                            color: AppColors.secondary,
                            size: 24,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.build,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Equipment Info
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
                            // Availability Status
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
                                equipment.isAvailable ? l10n.available : l10n.allCheckedOut, // Localized
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
                          equipment.category.toUpperCase(),
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
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEquipmentAction(context, value, equipment, stockProvider),
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
                        value: 'checkout',
                        child: Row(
                          children: [
                            const Icon(Icons.output, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.checkout), // Localized
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'checkouts',
                        child: Row(
                          children: [
                            const Icon(Icons.history, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.viewCheckouts), // Localized
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
              // Availability Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10n.available}: ${equipment.availableQuantity}/${equipment.totalQuantity}', // Localized
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
              // Quick Actions
              Row(
                children: [
                  if (equipment.checkedOutQuantity > 0)
                    _buildInfoChip(
                      l10n.checkedOut, // Localized
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
                            l10n.allOut, // Localized
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
        content: Text(l10n.equipmentCheckoutComingSoon), // Localized
      ),
    );
  }

  void _showEquipmentCheckouts(BuildContext context, EquipmentModel equipment) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.equipmentCheckoutHistoryComingSoon), // Localized
      ),
    );
  }

  void _showDeleteEquipmentConfirmation(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEquipment), // Localized
        content: Text(l10n.deleteEquipmentConfirmation(equipment.name)), // Localized with parameter
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteEquipment(equipment.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.equipmentDeletedSuccess), // Localized
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteEquipment, // Localized fallback
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
}

// Meals Tab
class MealsTab extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const MealsTab({
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
        List<MealModel> meals = _getFilteredMeals(stockProvider);

        return Column(
          children: [
            // Filter Chips
            _buildCategoryFilters(
              stockProvider.mealCategories,
              'meals',
              selectedCategory,
              onCategorySelected, context
            ),
            // Meals List
            Expanded(
              child: meals.isEmpty
                  ? _buildEmptyState(
                l10n.noMealsFound, // Localized
                searchQuery.isNotEmpty || selectedCategory != null
                    ? l10n.adjustSearchFilters // Localized
                    : l10n.addFirstMealHint, // Localized
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

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      meals = stockProvider.searchMeals(searchQuery);
    }

    // Apply category filter
    if (selectedCategory != null) {
      meals = meals.where((meal) => meal.category == selectedCategory).toList();
    }

    return meals;
  }

  Widget _buildMealCard(BuildContext context, MealModel meal, StockProvider stockProvider) {
    final l10n = AppLocalizations.of(context)!;
    final canBePrepared = stockProvider.canMealBePrepared(meal);

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
                  // Meal Image or Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: meal.imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            color: AppColors.success,
                            size: 24,
                          );
                        },
                      ),
                    )
                        : const Icon(
                      Icons.restaurant,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Meal Info
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
                            // Availability Badge
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
                                    : l10n.outOfStock, // Localized
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
                          meal.category.toUpperCase(),
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
                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMealAction(context, value, meal, stockProvider),
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
                        value: meal.isAvailable ? 'disable' : 'enable',
                        child: Row(
                          children: [
                            Icon(
                              meal.isAvailable ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(meal.isAvailable ? l10n.disable : l10n.enable), // Localized
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
              // Pricing Info
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildInfoChip(l10n.cost, meal.calculatedPrice.toStringAsFixed(2), context), // Localized
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.price, meal.sellingPrice.toStringAsFixed(2), context), // Localized
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.profit, meal.profitMargin.toStringAsFixed(2), context), // Localized
                    const SizedBox(width: 8),
                    _buildInfoChip(l10n.servings, meal.servings.toString(), context), // Localized
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
                              l10n.ingredientsLow, // Localized
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
              // Preparation Time
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.minutes(meal.preparationTime), // Localized
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.inventory, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    l10n.ingredientsCount(meal.ingredients.length), // Localized
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
            meal.isAvailable ? l10n.mealDisabledSuccess : l10n.mealEnabledSuccess, // Localized
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stockProvider.errorMessage ?? l10n.failedToUpdateMealAvailability, // Localized fallback
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
        title: Text(l10n.deleteMeal), // Localized
        content: Text(l10n.deleteMealConfirmation(meal.name)), // Localized with parameter
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel), // Localized
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteMeal(meal.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.mealDeletedSuccess), // Localized
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? l10n.failedToDeleteMeal, // Localized fallback
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
                label: Text(l10n.all), // Localized "All"
                selected: selectedCategory == null,
                onSelected: (selected) {
                  onCategorySelected(null);
                },
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
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
          label: Text(l10n.addItem), // Localized
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String label, String value, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.greyLight.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '${label}: ${value}', // Localized format
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
