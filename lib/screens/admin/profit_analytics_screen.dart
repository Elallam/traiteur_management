import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/occasion_model.dart';
import '../../providers/occasion_provider.dart';
import '../../generated/l10n/app_localizations.dart'; // Import AppLocalizations

class ProfitAnalyticsScreen extends StatefulWidget {
  const ProfitAnalyticsScreen({super.key});

  @override
  State<ProfitAnalyticsScreen> createState() => _ProfitAnalyticsScreenState();
}

class _ProfitAnalyticsScreenState extends State<ProfitAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  Future<void> _loadAnalyticsData() async {
    final occasionProvider = Provider.of<OccasionProvider>(context, listen: false);
    await occasionProvider.loadOccasions();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.profitAnalytics, // Localized
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range, color: AppColors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'export', child: Text(l10n.exportReport)), // Localized
              PopupMenuItem(value: 'share', child: Text(l10n.shareAnalytics)), // Localized
              PopupMenuItem(value: 'settings', child: Text(l10n.settings)), // Localized
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: [
            Tab(text: l10n.overview), // Localized
            Tab(text: l10n.trends), // Localized
            Tab(text: l10n.performance), // Localized
          ],
        ),
      ),
      body: Consumer<OccasionProvider>(
        builder: (context, occasionProvider, child) {
          if (occasionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (occasionProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.error}: ${occasionProvider.errorMessage}', // Localized
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: l10n.retry, // Localized
                    onPressed: _loadAnalyticsData,
                    width: 120,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildDateRangeHeader(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(occasionProvider),
                    _buildTrendsTab(occasionProvider),
                    _buildPerformanceTab(occasionProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    final l10n = AppLocalizations.of(context);
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
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            _selectedPeriod,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)})',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          CustomButton(
            text: l10n.changePeriod, // Localized
            onPressed: _showDateRangePicker,
            outlined: true,
            width: 120,
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(OccasionProvider occasionProvider) {
    final filteredOccasions = _getFilteredOccasions(occasionProvider);
    final stats = _calculateStats(filteredOccasions);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          _buildKeyMetrics(stats),
          const SizedBox(height: 24),

          // Quick Insights
          _buildQuickInsights(stats, filteredOccasions),
          const SizedBox(height: 24),

          // Top Performing Events
          _buildTopPerformingEvents(filteredOccasions),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(Map<String, dynamic> stats) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.keyMetrics, // Localized
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              l10n.totalRevenue, // Localized
              '\$${stats['totalRevenue'].toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.success,
              '+${stats['revenueGrowth'].toStringAsFixed(1)}%',
            ),
            _buildMetricCard(
              l10n.totalProfit, // Localized
              '\$${stats['totalProfit'].toStringAsFixed(0)}',
              Icons.trending_up,
              AppColors.primary,
              '+${stats['profitGrowth'].toStringAsFixed(1)}%',
            ),
            _buildMetricCard(
              l10n.completedEvents, // Localized
              stats['completedEvents'].toString(),
              Icons.event_available,
              AppColors.info,
              '+${stats['eventGrowth'].toStringAsFixed(1)}%',
            ),
            _buildMetricCard(
              l10n.averageOrderValue, // Localized
              '\$${stats['averageOrderValue'].toStringAsFixed(0)}',
              Icons.shopping_cart,
              AppColors.warning,
              '+${stats['aovGrowth'].toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights(Map<String, dynamic> stats, List<OccasionModel> occasions) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.quickInsights, // Localized
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              l10n.profitMargin, // Localized
              '${stats['profitMargin'].toStringAsFixed(1)}%',
              stats['profitMargin'] >= 30 ? l10n.excellent : stats['profitMargin'] >= 20 ? l10n.good : l10n.needsImprovement, // Localized
              stats['profitMargin'] >= 30 ? AppColors.success : stats['profitMargin'] >= 20 ? AppColors.warning : AppColors.error,
            ),
            const Divider(),
            _buildInsightItem(
              l10n.bestMonth, // Localized
              _getBestMonth(occasions),
              l10n.highestRevenueMonth, // Localized
              AppColors.info,
            ),
            const Divider(),
            _buildInsightItem(
              l10n.eventSuccessRate, // Localized
              '${(stats['completedEvents'] / stats['totalEvents'] * 100).toStringAsFixed(1)}%',
              l10n.eventsCompletedSuccessfully, // Localized
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingEvents(List<OccasionModel> occasions) {
    final l10n = AppLocalizations.of(context);
    final topEvents = occasions
        .where((o) => o.status == 'completed')
        .toList()
      ..sort((a, b) => b.profit.compareTo(a.profit));

    final displayEvents = topEvents.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.topPerformingEvents, // Localized
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...displayEvents.asMap().entries.map((entry) {
          final index = entry.key;
          final occasion = entry.value;
          return _buildTopEventCard(occasion, index + 1);
        }),
        if (displayEvents.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.event_busy,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noCompletedEventsInPeriod, // Localized
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopEventCard(OccasionModel occasion, int rank) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3 ? AppColors.primary : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occasion.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(occasion.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    l10n.guestsCount(occasion.expectedGuests), // Localized
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${occasion.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${l10n.profit}: \$${occasion.profit.toStringAsFixed(0)}', // Localized
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '${occasion.profitPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(OccasionProvider occasionProvider) {
    final filteredOccasions = _getFilteredOccasions(occasionProvider);
    final monthlyData = _getMonthlyData(filteredOccasions);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Trend Chart
          _buildChartCard(
            l10n.revenueTrend, // Localized
            Icons.trending_up,
            _buildRevenueChart(monthlyData),
          ),
          const SizedBox(height: 24),

          // Events Count Chart
          _buildChartCard(
            l10n.eventsCount, // Localized
            Icons.event,
            _buildEventsChart(monthlyData),
          ),
          const SizedBox(height: 24),

          // Profit Margin Trend
          _buildChartCard(
            l10n.profitMarginTrend, // Localized
            Icons.percent,
            _buildProfitMarginChart(monthlyData),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, IconData icon, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, Map<String, double>> monthlyData) {
    final l10n = AppLocalizations.of(context);
    if (monthlyData.isEmpty) {
      return _buildEmptyChart(l10n.revenueChart); // Localized
    }

    final spots = monthlyData.entries.map((entry) {
      final monthIndex = DateTime.parse('${entry.key}-01').month.toDouble();
      return FlSpot(monthIndex, entry.value['revenue'] ?? 0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
                  l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december]; // Localized months
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(months[value.toInt() - 1]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('\$${(value / 1000).toStringAsFixed(0)}k');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsChart(Map<String, Map<String, double>> monthlyData) {
    final l10n = AppLocalizations.of(context);
    if (monthlyData.isEmpty) {
      return _buildEmptyChart(l10n.eventsCountChart); // Localized
    }

    final barGroups = monthlyData.entries.map((entry) {
      final monthIndex = DateTime.parse('${entry.key}-01').month;
      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: entry.value['events'] ?? 0,
            color: AppColors.info,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.isNotEmpty ?
        barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
                  l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december]; // Localized months
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(months[value.toInt() - 1]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildProfitMarginChart(Map<String, Map<String, double>> monthlyData) {
    final l10n = AppLocalizations.of(context);
    if (monthlyData.isEmpty) {
      return _buildEmptyChart(l10n.profitMarginChart); // Localized
    }

    final spots = monthlyData.entries.map((entry) {
      final monthIndex = DateTime.parse('${entry.key}-01').month.toDouble();
      return FlSpot(monthIndex, entry.value['profitMargin'] ?? 0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
                  l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december]; // Localized months
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(months[value.toInt() - 1]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.success,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.success.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noDataAvailableForPeriod, // Localized
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(OccasionProvider occasionProvider) {
    final filteredOccasions = _getFilteredOccasions(occasionProvider);
    final performanceMetrics = _calculatePerformanceMetrics(filteredOccasions);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary
          _buildPerformanceSummary(performanceMetrics),
          const SizedBox(height: 24),

          // Category Performance
          _buildCategoryPerformance(filteredOccasions),
          const SizedBox(height: 24),

          // Monthly Comparison
          _buildMonthlyComparison(filteredOccasions),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(Map<String, dynamic> metrics) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceSummary, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    l10n.successRate, // Localized
                    '${metrics['successRate'].toStringAsFixed(1)}%',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    l10n.avgProfitMargin, // Localized
                    '${metrics['avgProfitMargin'].toStringAsFixed(1)}%',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    l10n.bestMonth, // Localized
                    metrics['bestMonth'],
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    l10n.growthRate, // Localized
                    '+${metrics['growthRate'].toStringAsFixed(1)}%',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryPerformance(List<OccasionModel> occasions) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.performanceByEventSize, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSizeCategory(l10n.smallEvents, // Localized
                occasions.where((o) => o.expectedGuests < 50).toList()),
            const SizedBox(height: 8),
            _buildSizeCategory(l10n.mediumEvents, // Localized
                occasions.where((o) => o.expectedGuests >= 50 && o.expectedGuests <= 150).toList()),
            const SizedBox(height: 8),
            _buildSizeCategory(l10n.largeEvents, // Localized
                occasions.where((o) => o.expectedGuests > 150).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeCategory(String title, List<OccasionModel> events) {
    final l10n = AppLocalizations.of(context);
    final completedEvents = events.where((e) => e.status == 'completed').toList();
    final totalRevenue = completedEvents.fold(0.0, (sum, e) => sum + e.totalPrice);
    final avgProfit = completedEvents.isNotEmpty
        ? completedEvents.fold(0.0, (sum, e) => sum + e.profitPercentage) / completedEvents.length
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              l10n.eventsCountLabel(completedEvents.length), // Localized
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '\$${totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${avgProfit.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison(List<OccasionModel> occasions) {
    final monthlyData = _getMonthlyData(occasions);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.monthlyComparison, // Localized
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (monthlyData.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: _buildMonthlyComparisonChart(monthlyData),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.timeline,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noDataAvailableForMonthlyComparison, // Localized
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonChart(Map<String, Map<String, double>> monthlyData) {
    final l10n = AppLocalizations.of(context);
    final barGroups = monthlyData.entries.map((entry) {
      final monthIndex = DateTime.parse('${entry.key}-01').month;
      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: entry.value['revenue'] ?? 0,
            color: AppColors.primary,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: entry.value['profit'] ?? 0,
            color: AppColors.success,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.isNotEmpty ?
        barGroups.map((g) => g.barRods.map((r) => r.toY).reduce((a, b) => a > b ? a : b)).reduce((a, b) => a > b ? a : b) * 1.2 : 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = [l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
                  l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december]; // Localized months
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(months[value.toInt() - 1]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('\$${(value / 1000).toStringAsFixed(0)}k');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        barGroups: barGroups,
      ),
    );
  }

  // Helper Methods
  List<OccasionModel> _getFilteredOccasions(OccasionProvider occasionProvider) {
    return occasionProvider.getOccasionsByDateRange(_startDate, _endDate);
  }

  Map<String, dynamic> _calculateStats(List<OccasionModel> occasions) {
    final completedEvents = occasions.where((o) => o.status == 'completed').toList();

    final totalRevenue = completedEvents.fold(0.0, (sum, o) => sum + o.totalPrice);
    final totalCost = completedEvents.fold(0.0, (sum, o) => sum + o.totalCost);
    final totalProfit = totalRevenue - totalCost;
    final profitMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;
    final averageOrderValue = completedEvents.isNotEmpty ? totalRevenue / completedEvents.length : 0.0;

    return {
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'profitMargin': profitMargin,
      'completedEvents': completedEvents.length,
      'totalEvents': occasions.length,
      'averageOrderValue': averageOrderValue,
      'revenueGrowth': 12.5, // Mock data
      'profitGrowth': 8.3,   // Mock data
      'eventGrowth': 15.2,   // Mock data
      'aovGrowth': 5.7,      // Mock data
    };
  }

  Map<String, dynamic> _calculatePerformanceMetrics(List<OccasionModel> occasions) {
    final completedEvents = occasions.where((o) => o.status == 'completed').toList();
    final successRate = occasions.isNotEmpty ? (completedEvents.length / occasions.length) * 100 : 0.0;
    final avgProfitMargin = completedEvents.isNotEmpty
        ? completedEvents.fold(0.0, (sum, o) => sum + o.profitPercentage) / completedEvents.length
        : 0.0;

    return {
      'successRate': successRate,
      'avgProfitMargin': avgProfitMargin,
      'bestMonth': _getBestMonth(occasions),
      'growthRate': 15.2, // Mock data
    };
  }

  String _getBestMonth(List<OccasionModel> occasions) {
    if (occasions.isEmpty) return 'N/A';
    final l10n = AppLocalizations.of(context);

    final monthlyRevenue = <int, double>{};

    for (final occasion in occasions.where((o) => o.status == 'completed')) {
      final month = occasion.date.month;
      monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + occasion.totalPrice;
    }

    if (monthlyRevenue.isEmpty) return 'N/A';

    final bestMonth = monthlyRevenue.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final months = [l10n.january, l10n.february, l10n.march, l10n.april, l10n.may, l10n.june,
      l10n.july, l10n.august, l10n.september, l10n.october, l10n.november, l10n.december]; // Localized months

    return months[bestMonth - 1];
  }

  Map<String, Map<String, double>> _getMonthlyData(List<OccasionModel> occasions) {
    final monthlyData = <String, Map<String, double>>{};

    for (final occasion in occasions.where((o) => o.status == 'completed')) {
      final monthKey = DateFormat('yyyy-MM').format(occasion.date);

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {
          'revenue': 0.0,
          'profit': 0.0,
          'events': 0.0,
          'profitMargin': 0.0,
        };
      }

      monthlyData[monthKey]!['revenue'] = monthlyData[monthKey]!['revenue']! + occasion.totalPrice;
      monthlyData[monthKey]!['profit'] = monthlyData[monthKey]!['profit']! + occasion.profit;
      monthlyData[monthKey]!['events'] = monthlyData[monthKey]!['events']! + 1;
    }

    // Calculate profit margins
    monthlyData.forEach((key, data) {
      if (data['revenue']! > 0) {
        data['profitMargin'] = (data['profit']! / data['revenue']!) * 100;
      }
    });

    return monthlyData;
  }

  Future<void> _showDateRangePicker() async {
    final l10n = AppLocalizations.of(context);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = l10n.customRange; // Localized
      });
      await _loadAnalyticsData();
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'export':
        _exportReport();
        break;
      case 'share':
        _shareAnalytics();
        break;
      case 'settings':
        _openSettings();
        break;
    }
  }

  void _exportReport() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportFunctionalityComingSoon), // Localized
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _shareAnalytics() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shareFunctionalityComingSoon), // Localized
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openSettings() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsFunctionalityComingSoon), // Localized
        backgroundColor: AppColors.info,
      ),
    );
  }
}
