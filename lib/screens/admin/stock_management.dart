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
    return AppBar(
      title: const Text('Stock Management'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStockData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: _showStockAnalytics,
          tooltip: 'Analytics',
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
                  hintText: 'Search stock items...',
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
              tabs: const [
                Tab(text: 'Articles', icon: Icon(Icons.inventory_2)),
                Tab(text: 'Equipment', icon: Icon(Icons.build)),
                Tab(text: 'Meals', icon: Icon(Icons.restaurant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddItemDialog,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: AppColors.white),
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
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const LoadingWidget(message: 'Loading stock data...');
        }

        return Column(
          children: [
            _buildQuickStats(stockProvider),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ArticlesTab(searchQuery: _searchQuery),
                  EquipmentTab(searchQuery: _searchQuery),
                  MealsTab(searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(StockProvider stockProvider) {
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
              'Total Articles',
              stats['totalArticles'].toString(),
              Icons.inventory_2,
              AppColors.primary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Equipment',
              stats['totalEquipment'].toString(),
              Icons.build,
              AppColors.secondary,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Meals',
              stats['totalMeals'].toString(),
              Icons.restaurant,
              AppColors.success,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Low Stock',
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
    // showDialog(
    //   context: context,
    //   builder: (context) => const StockAnalyticsDialog(),
    // );
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
    // showDialog(
    //   context: context,
    //   builder: (context) => const AddEditMealDialog(),
    // );
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

  const ArticlesTab({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<ArticleModel> articles = searchQuery.isEmpty
            ? stockProvider.articles
            : stockProvider.searchArticles(searchQuery);

        return Column(
          children: [
            // Filter Chips
            _buildCategoryFilters(stockProvider.articleCategories, 'articles'),
            // Articles List
            Expanded(
              child: articles.isEmpty
                  ? _buildEmptyState(
                'No articles found',
                searchQuery.isNotEmpty
                    ? 'Try adjusting your search'
                    : 'Add your first article to get started',
                Icons.inventory_2,
                    () => _showAddArticleDialog(context),
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

  Widget _buildArticleCard(BuildContext context, ArticleModel article, StockProvider stockProvider) {
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
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'quantity',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, size: 18),
                            SizedBox(width: 8),
                            Text('Update Quantity'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
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
                  _buildInfoChip('Price', '\$${article.price.toStringAsFixed(2)}'),
                  const SizedBox(width: 8),
                  _buildInfoChip('Total Value', '\$${article.totalValue.toStringAsFixed(2)}'),
                  const Spacer(),
                  if (article.isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: AppColors.error, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Low Stock',
                            style: TextStyle(
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

  Widget _buildInfoChip(String label, String value) {
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
    final controller = TextEditingController(text: article.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Quantity - ${article.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Quantity (${article.unit})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    const SnackBar(
                      content: Text('Quantity updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        stockProvider.errorMessage ?? 'Failed to update quantity',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ArticleModel article, StockProvider stockProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Article'),
        content: Text('Are you sure you want to delete "${article.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteArticle(article.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Article deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? 'Failed to delete article',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Equipment Tab
class EquipmentTab extends StatelessWidget {
  final String searchQuery;

  const EquipmentTab({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<EquipmentModel> equipment = searchQuery.isEmpty
            ? stockProvider.equipment
            : stockProvider.searchEquipment(searchQuery);

        return Column(
          children: [
            // Filter Chips
            _buildCategoryFilters(stockProvider.equipmentCategories, 'equipment'),
            // Equipment List
            Expanded(
              child: equipment.isEmpty
                  ? _buildEmptyState(
                'No equipment found',
                searchQuery.isNotEmpty
                    ? 'Try adjusting your search'
                    : 'Add your first equipment to get started',
                Icons.build,
                    () => _showAddEquipmentDialog(context),
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

  Widget _buildEquipmentCard(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
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
                                equipment.isAvailable ? 'Available' : 'All Checked Out',
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
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'checkout',
                        child: Row(
                          children: [
                            Icon(Icons.output, size: 18),
                            SizedBox(width: 8),
                            Text('Checkout'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'checkouts',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 18),
                            SizedBox(width: 8),
                            Text('View Checkouts'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
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
                        'Available: ${equipment.availableQuantity}/${equipment.totalQuantity}',
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
                      'Checked Out',
                      equipment.checkedOutQuantity.toString(),
                    ),
                  const SizedBox(width: 8),
                  if (equipment.isFullyCheckedOut)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block, color: AppColors.error, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'All Out',
                            style: TextStyle(
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
    // TODO: Implement checkout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipment checkout - Coming soon'),
      ),
    );
  }

  void _showEquipmentCheckouts(BuildContext context, EquipmentModel equipment) {
    // TODO: Implement equipment checkouts view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equipment checkout history - Coming soon'),
      ),
    );
  }

  void _showDeleteEquipmentConfirmation(BuildContext context, EquipmentModel equipment, StockProvider stockProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text('Are you sure you want to delete "${equipment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteEquipment(equipment.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Equipment deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? 'Failed to delete equipment',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Meals Tab
class MealsTab extends StatelessWidget {
  final String searchQuery;

  const MealsTab({Key? key, required this.searchQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        List<MealModel> meals = searchQuery.isEmpty
            ? stockProvider.meals
            : stockProvider.searchMeals(searchQuery);

        return Column(
          children: [
            // Filter Chips
            _buildCategoryFilters(stockProvider.mealCategories, 'meals'),
            // Meals List
            Expanded(
              child: meals.isEmpty
                  ? _buildEmptyState(
                'No meals found',
                searchQuery.isNotEmpty
                    ? 'Try adjusting your search'
                    : 'Add your first meal to get started',
                Icons.restaurant,
                    () => _showAddMealDialog(context),
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

  Widget _buildMealCard(BuildContext context, MealModel meal, StockProvider stockProvider) {
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
                                    ? 'Available'
                                    : !meal.isAvailable
                                    ? 'Disabled'
                                    : 'Out of Stock',
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
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 18),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
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
                            Text(meal.isAvailable ? 'Disable' : 'Enable'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
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
                child: Row(
                  children: [
                    _buildInfoChip('Cost', meal.calculatedPrice.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _buildInfoChip('Price', meal.sellingPrice.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _buildInfoChip('Profit', meal.profitMargin.toStringAsFixed(2)),
                    const SizedBox(width: 8),
                    _buildInfoChip('Servings', meal.servings.toString()),
                    const Spacer(),
                    if (!canBePrepared && meal.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, color: AppColors.warning, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Ingredients Low',
                              style: TextStyle(
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
                    '${meal.preparationTime} minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.inventory, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${meal.ingredients.length} ingredients',
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
    final success = await stockProvider.updateMealAvailability(meal.id, !meal.isAvailable);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meal ${meal.isAvailable ? 'disabled' : 'enabled'} successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stockProvider.errorMessage ?? 'Failed to update meal availability',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteMealConfirmation(BuildContext context, MealModel meal, StockProvider stockProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await stockProvider.deleteMeal(meal.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      stockProvider.errorMessage ?? 'Failed to delete meal',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Common helper widgets and functions
Widget _buildCategoryFilters(List<String> categories, String type) {
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
                label: const Text('All'),
                selected: true, // TODO: Implement category filtering
                onSelected: (selected) {
                  // TODO: Implement category filtering
                },
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: false, // TODO: Implement category filtering
              onSelected: (selected) {
                // TODO: Implement category filtering
              },
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildEmptyState(String title, String subtitle, IconData icon, VoidCallback onAdd) {
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
          label: const Text('Add Item'),
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String label, String value) {
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