import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../models/cash_transaction_model.dart';
import '../../services/firestore_service.dart';
import 'add_transaction_dialog.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final DateFormat _dateFormat = DateFormat();
  List<CashTransactionModel> _allTransactions = [];
  List<CashTransactionModel> _filteredTransactions = [];
  CashRegisterSummary _summary = CashRegisterSummary.empty();

  bool _isLoading = true;
  String? _error;

  String _selectedType = 'all';
  String _selectedPeriod = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transactions = await _firestoreService.getCashTransactions();
      final summary = await _firestoreService.getCashRegisterSummary();

      setState(() {
        _allTransactions = transactions;
        _summary = summary;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<CashTransactionModel> filtered = List.from(_allTransactions);

    if (_selectedType != 'all') {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    if (_selectedPeriod != 'all') {
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate = now;

      switch (_selectedPeriod) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'custom':
          if (_customStartDate != null && _customEndDate != null) {
            startDate = _customStartDate;
            endDate = _customEndDate;
          }
          break;
      }

      if (startDate != null) {
        filtered = filtered.where((t) =>
        t.date.isAfter(startDate!) && t.date.isBefore(endDate!.add(const Duration(days: 1)))
        ).toList();
      }
    }

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashRegister),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          indicatorColor: AppColors.white,
          tabs: [
            Tab(icon: const Icon(Icons.dashboard), text: l10n.overview),
            Tab(icon: const Icon(Icons.list), text: l10n.transactions),
            Tab(icon: const Icon(Icons.analytics), text: l10n.analytics),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? LoadingWidget(message: l10n.loadingCashData)
          : _error != null
          ? LoadingErrorWidget(
        message: _error!,
        onRetry: _loadData,
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text(
          l10n.addTransaction,
          style: const TextStyle(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: AppDimensions.marginM),
            _buildQuickStatsRow(),
            const SizedBox(height: AppDimensions.marginM),
            _buildRecentTransactionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', Localizations.localeOf(context).languageCode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: AppDimensions.iconL,
              ),
              const SizedBox(width: AppDimensions.marginS),
              Text(
                l10n.realtimeBalance,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginM),
          Text(
            '${_summary.balance.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            _summary.lastTransactionDate != null
                ? '${l10n.lastUpdated}: ${dateFormat.format(_summary.lastTransactionDate!)}'
                : l10n.noTransactionsYet,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            l10n.totalDeposits,
            '${_summary.totalDeposits.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
            Icons.arrow_upward,
            AppColors.success,
            '${_summary.depositsCount} ${l10n.transactionsCount(_summary.depositsCount)}',
          ),
        ),
        const SizedBox(width: AppDimensions.marginM),
        Expanded(
          child: _buildStatCard(
            l10n.totalWithdrawals,
            '${_summary.totalWithdrawals.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
            Icons.arrow_downward,
            AppColors.error,
            '${_summary.withdrawalsCount} ${l10n.transactionsCount(_summary.withdrawalsCount)}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppDimensions.marginS),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final l10n = AppLocalizations.of(context)!;
    final recentTransactions = _allTransactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentTransactions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginS),
        if (recentTransactions.isEmpty)
          EmptyStateWidget(
            title: l10n.noTransactions,
            message: l10n.noTransactionsFound,
            actionText: l10n.addTransaction,
            onAction: () => _showAddTransactionDialog(context),
          )
        else
          ...recentTransactions.map((transaction) => _buildTransactionTile(transaction)),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildFiltersSection(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _filteredTransactions.isEmpty
                ? EmptyStateWidget(
              title: l10n.noTransactions,
              message: _selectedType == 'all' && _selectedPeriod == 'all'
                  ? l10n.noTransactionsFound
                  : l10n.noMatchingTransactions,
              actionText: l10n.addTransaction,
              onAction: () => _showAddTransactionDialog(context),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionTile(_filteredTransactions[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy', Localizations.localeOf(context).languageCode);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  l10n.type,
                  _selectedType,
                  [
                    {'value': 'all', 'label': l10n.allTypes},
                    {'value': 'deposit', 'label': l10n.deposits},
                    {'value': 'withdraw', 'label': l10n.withdrawals},
                  ],
                      (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.marginM),
              Expanded(
                child: _buildFilterDropdown(
                  l10n.period,
                  _selectedPeriod,
                  [
                    {'value': 'all', 'label': l10n.allTime},
                    {'value': 'today', 'label': l10n.today},
                    {'value': 'week', 'label': l10n.thisWeek},
                    {'value': 'month', 'label': l10n.thisMonth},
                    {'value': 'custom', 'label': l10n.customRange},
                  ],
                      (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                    if (value == 'custom') {
                      _showCustomDateRangePicker();
                    } else {
                      _applyFilters();
                    }
                  },
                ),
              ),
            ],
          ),
          if (_selectedPeriod == 'custom' && _customStartDate != null && _customEndDate != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.marginS),
              child: Text(
                l10n.customRangeDisplay(_dateFormat.format(_customStartDate!), _dateFormat.format(_customEndDate!)),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
      String label,
      String value,
      List<Map<String, String>> items,
      void Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(CashTransactionModel transaction) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm', Localizations.localeOf(context).languageCode);
    final isDeposit = transaction.isDeposit;
    final color = isDeposit ? AppColors.success : AppColors.error;
    final icon = isDeposit ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.operationName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(transaction.date),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (transaction.description != null && transaction.description!.isNotEmpty)
              Text(
                transaction.description!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isDeposit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            if (transaction.userName != null)
              Text(
                transaction.userName!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
        onLongPress: () => _showTransactionOptions(transaction),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cashFlowAnalytics,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginM),
          _buildAnalyticsSummaryCards(),
          const SizedBox(height: AppDimensions.marginL),
          _buildCashFlowChart(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummaryCards() {
    final l10n = AppLocalizations.of(context)!;
    final avgDeposit = _summary.depositsCount > 0
        ? _summary.totalDeposits / _summary.depositsCount
        : 0.0;
    final avgWithdrawal = _summary.withdrawalsCount > 0
        ? _summary.totalWithdrawals / _summary.withdrawalsCount
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                l10n.transactionCount,
                _summary.totalTransactions.toString(),
                Icons.receipt_long,
                AppColors.info,
              ),
            ),
            const SizedBox(width: AppDimensions.marginM),
            Expanded(
              child: _buildAnalyticsCard(
                l10n.averageDeposit,
                '${avgDeposit.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginM),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                l10n.averageWithdrawal,
                '${avgWithdrawal.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
                Icons.trending_down,
                AppColors.error,
              ),
            ),
            const SizedBox(width: AppDimensions.marginM),
            Expanded(
              child: _buildAnalyticsCard(
                l10n.netFlow,
                '${(_summary.totalDeposits - _summary.totalWithdrawals).toStringAsFixed(2)} ${AppStrings.currencySymbol}',
                Icons.account_balance,
                _summary.balance >= 0 ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppDimensions.marginS),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginS),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart() {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    // Group transactions by month
    final monthlyData = <DateTime, Map<String, double>>{};
    final now = DateTime.now();

    for (final transaction in _allTransactions) {
      final monthStart = DateTime(transaction.date.year, transaction.date.month);
      monthlyData.putIfAbsent(monthStart, () => {'deposit': 0.0, 'withdraw': 0.0});

      if (transaction.isDeposit) {
        monthlyData[monthStart]!['deposit'] =
            (monthlyData[monthStart]!['deposit'] ?? 0) + transaction.amount;
      } else {
        monthlyData[monthStart]!['withdraw'] =
            (monthlyData[monthStart]!['withdraw'] ?? 0) + transaction.amount;
      }
    }

    // Sort months and take last 6 months
    final sortedMonths = monthlyData.keys.toList()..sort();
    final last6Months = sortedMonths.length > 6
        ? sortedMonths.sublist(sortedMonths.length - 6)
        : sortedMonths;

    // Prepare bar chart data
    final barGroups = last6Months.map((month) {
      final data = monthlyData[month]!;
      return BarChartGroupData(
        x: month.month,
        barRods: [
          BarChartRodData(
            toY: data['deposit'] ?? 0,
            color: AppColors.success,
            width: 12,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: data['withdraw'] ?? 0,
            color: AppColors.error,
            width: 12,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cashFlowAnalytics,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
            // textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: AppDimensions.marginS),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _calculateMaxY(monthlyData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    // tooltipBgColor: AppColors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = last6Months[groupIndex];
                      final type = rodIndex == 0 ? l10n.deposits : l10n.withdrawals;
                      return BarTooltipItem(
                        '$type\n${rod.toY.toStringAsFixed(2)} ${AppStrings.currencySymbol}',
                        TextStyle(
                          color: rodIndex == 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = DateTime(now.year, value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            DateFormat('MMM', Localizations.localeOf(context).languageCode)
                                .format(month),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            // textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          // textDirection: isRTL ? TextDirection.RTL : TextDirection!.LTR,
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginS),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(l10n.deposits, AppColors.success),
              const SizedBox(width: 16),
              _buildChartLegend(l10n.withdrawals, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(Map<DateTime, Map<String, double>> monthlyData) {
    double max = 0;
    for (final data in monthlyData.values) {
      final total = (data['deposit'] ?? 0) + (data['withdraw'] ?? 0);
      if (total > max) max = total;
    }
    return max * 1.2; // Add 20% padding
  }

  Widget _buildChartLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        onTransactionAdded: () {
          _loadData();
        },
      ),
    );
  }

  void _showTransactionDetails(CashTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }

  void _showTransactionOptions(CashTransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionOptionsBottomSheet(
        transaction: transaction,
        onEdit: () {
          Navigator.pop(context);
          _showEditTransactionDialog(transaction);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDeleteTransaction(transaction);
        },
      ),
    );
  }

  void _showEditTransactionDialog(CashTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => EditTransactionDialog(
        transaction: transaction,
        onTransactionUpdated: () {
          _loadData();
        },
      ),
    );
  }

  void _confirmDeleteTransaction(CashTransactionModel transaction) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage(transaction.operationName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteCashTransaction(transaction.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.transactionDeletedSuccess)),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.deleteTransactionFailed(e))),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCustomDateRangePicker() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
      locale: Locale(Localizations.localeOf(context).languageCode),
    );

    if (dateRange != null) {
      setState(() {
        _customStartDate = dateRange.start;
        _customEndDate = dateRange.end;
      });
      _applyFilters();
    }
  }
}