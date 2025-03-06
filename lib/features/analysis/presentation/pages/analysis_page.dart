import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  String _selectedPeriod = 'Daily';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<String> _titles = [];
  List<Map<String, dynamic>> _incomeData = [];
  List<Map<String, dynamic>> _expenseData = [];
  List<BarChartGroupData> _barGroups = [];
  bool _isLoading = false;
  double _maxY = 1000;
  late TabController _tabController;
  Map<String, double> _categorySpending = {};
  double _totalIncome = 0;
  double _totalExpenses = 0;
  bool _showChart = true;
  String _selectedChartType = 'bar';
  bool _showLegend = true;

  // New fields for additional insights
  double _monthlyAvgExpense = 0;
  double _monthlyAvgIncome = 0;
  String _topExpenseCategory = '';
  double _savingsRate = 0;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChartData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeChartData() async {
    setState(() {
      _isLoading = true;
      _incomeData = [];
      _expenseData = [];
    });

    try {
      final now = DateTime.now();
      switch (_selectedPeriod) {
        case 'Daily':
          _startDate = DateTime(now.year, now.month, now.day - 6);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Weekly':
          _startDate = DateTime(now.year, now.month, now.day - 28);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Monthly':
          _startDate = DateTime(now.year, now.month - 5, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case 'Yearly':
          _startDate = DateTime(now.year - 4, 1, 1);
          _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
      }

      // Initialize titles based on period
      _titles = [];
      var current = _startDate;
      while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
        String title = '';
        switch (_selectedPeriod) {
          case 'Daily':
            title = DateFormat('EEE').format(current);
            current = current.add(const Duration(days: 1));
            break;
          case 'Weekly':
            title = 'Week ${((current.difference(_startDate).inDays) / 7).floor() + 1}';
            current = current.add(const Duration(days: 7));
            break;
          case 'Monthly':
            title = DateFormat('MMM').format(current);
            current = DateTime(current.year, current.month + 1, 1);
            break;
          case 'Yearly':
            title = current.year.toString();
            current = DateTime(current.year + 1, 1, 1);
            break;
        }
        _titles.add(title);
      }

      await _loadAnalysisData();
      await _loadCategorySpending();
    } catch (e) {
      debugPrint('Error initializing chart data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategorySpending() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      _categorySpending = await _db.getSpendingByCategory(userId, _startDate, _endDate);
    } catch (e) {
      debugPrint('Error loading category spending: $e');
    }
  }

  Future<void> _loadAnalysisData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final transactions = await _db.getTransactionsByPeriod(
        _selectedPeriod,
        _startDate,
        _endDate,
      );

      final incomeData = <Map<String, dynamic>>[];
      final expenseData = <Map<String, dynamic>>[];
      double maxAmount = 0;
      double totalIncome = 0;
      double totalExpenses = 0;

      for (var transaction in transactions) {
        final date = (transaction['date'] as DateTime);
        final amount = (transaction['amount'] as num).toDouble();
        final type = transaction['type'] as String;

        maxAmount = max(maxAmount, amount);

        final data = {
          'date': date,
          'amount': amount,
          'title': transaction['title'] as String,
        };

        if (type == 'income') {
          incomeData.add(data);
          totalIncome += amount;
        } else {
          expenseData.add(data);
          totalExpenses += amount;
        }
      }

      // Calculate additional insights
      _monthlyAvgExpense = totalExpenses / max(1, _titles.length);
      _monthlyAvgIncome = totalIncome / max(1, _titles.length);
      _savingsRate = totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;

      if (mounted) {
        setState(() {
          _incomeData = incomeData;
          _expenseData = expenseData;
          _maxY = maxAmount > 0 ? maxAmount : 1000;
          _totalIncome = totalIncome;
          _totalExpenses = totalExpenses;
          _generateBarGroups();
        });
      }
    } catch (e) {
      debugPrint('Error loading analysis data: $e');
    }
  }

  void _generateBarGroups() {
    final groups = <BarChartGroupData>[];
    
    for (int i = 0; i < _titles.length; i++) {
      double incomeAmount = 0;
      double expenseAmount = 0;

      // Calculate income for this period
      for (var income in _incomeData) {
        final date = income['date'] as DateTime;
        if (_isDateInPeriod(date, i)) {
          incomeAmount += income['amount'] as double;
        }
      }

      // Calculate expenses for this period
      for (var expense in _expenseData) {
        final date = expense['date'] as DateTime;
        if (_isDateInPeriod(date, i)) {
          expenseAmount += expense['amount'] as double;
        }
      }

      groups.add(_generateBarGroup(i, incomeAmount, expenseAmount));
    }

    setState(() {
      _barGroups = groups;
    });
  }

  bool _isDateInPeriod(DateTime date, int periodIndex) {
    final periodStart = _getPeriodStart(periodIndex);
    final periodEnd = _getPeriodEnd(periodIndex);
    return date.isAfter(periodStart) && date.isBefore(periodEnd);
  }

  DateTime _getPeriodStart(int periodIndex) {
    switch (_selectedPeriod) {
      case 'Daily':
        return _startDate.add(Duration(days: periodIndex));
      case 'Weekly':
        return _startDate.add(Duration(days: periodIndex * 7));
      case 'Monthly':
        return DateTime(_startDate.year, _startDate.month + periodIndex, 1);
      case 'Yearly':
        return DateTime(_startDate.year + periodIndex, 1, 1);
      default:
        return _startDate;
    }
  }

  DateTime _getPeriodEnd(int periodIndex) {
    final start = _getPeriodStart(periodIndex);
    switch (_selectedPeriod) {
      case 'Daily':
        return start.add(const Duration(days: 1));
      case 'Weekly':
        return start.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(start.year, start.month + 1, 0);
      case 'Yearly':
        return DateTime(start.year + 1, 1, 0);
      default:
        return start.add(const Duration(days: 1));
    }
  }

  BarChartGroupData _generateBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.green,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: Colors.red,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0, 1],
      barsSpace: 4,
    );
  }

  Widget _buildChartSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 300,
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
              maxWidth: max(
                MediaQuery.of(context).size.width - 64,
                _barGroups.length * 80.0,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade700,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (rod.toY == 0) return null;
                      final amount = rod.toY;
                      final transactions = rodIndex == 0 ? _incomeData : _expenseData;
                      final transactionsInPeriod = transactions.where((t) => _isDateInPeriod(t['date'] as DateTime, group.x)).toList();
                      final titles = transactionsInPeriod.map((t) => t['title'] as String).join('\n');
                      return BarTooltipItem(
                        '${NumberFormat.currency(symbol: 'KSH ').format(amount)}\n$titles',
                        const TextStyle(
                          color: Colors.white,
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
                        if (value < 0 || value >= _titles.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _titles[value.toInt()],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          NumberFormat.compact().format(value),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      interval: _maxY / 4,
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
                  horizontalInterval: _maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                barGroups: _barGroups.map((group) {
                  return BarChartGroupData(
                    x: group.x,
                    barRods: group.barRods.map((rod) {
                      return BarChartRodData(
                        toY: rod.toY,
                        color: rod.color,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _maxY,
                          color: Colors.grey[100],
                        ),
                      );
                    }).toList(),
                    showingTooltipIndicators: group.barRods.any((rod) => rod.toY > 0) ? [0, 1] : [],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    String periodText = '';
    String avgPrefix = '';
    switch (_selectedPeriod) {
      case 'Daily':
        periodText = 'Daily';
        avgPrefix = 'Daily';
        break;
      case 'Weekly':
        periodText = 'Weekly';
        avgPrefix = 'Weekly';
        break;
      case 'Monthly':
        periodText = 'Monthly';
        avgPrefix = 'Monthly';
        break;
      case 'Yearly':
        periodText = 'Yearly';
        avgPrefix = 'Yearly';
        break;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$periodText Financial Insights',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '$avgPrefix Average Income',
              _monthlyAvgIncome,
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightItem(
              '$avgPrefix Average Expense',
              _monthlyAvgExpense,
              Icons.trending_down,
              Colors.red,
            ),
            _buildInsightItem(
              '$periodText Savings Rate',
              _savingsRate,
              Icons.savings,
              Colors.blue,
              isPercentage: true,
            ),
            if (_topExpenseCategory.isNotEmpty)
              _buildInsightItem(
                '$periodText Top Expense',
                0,
                Icons.category,
                Colors.orange,
                customValue: _topExpenseCategory,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, double value, IconData icon, Color color,
      {bool isPercentage = false, String? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customValue ??
                      (isPercentage
                          ? '${value.toStringAsFixed(1)}%'
                          : NumberFormat.currency(symbol: 'KSH ').format(value)),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ToggleButtons(
            isSelected: [_selectedChartType == 'bar', _selectedChartType == 'line'],
            onPressed: (index) {
              setState(() {
                _selectedChartType = index == 0 ? 'bar' : 'line';
              });
            },
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.bar_chart),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.show_chart),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _showLegend ? Icons.legend_toggle : Icons.legend_toggle_outlined,
              color: _showLegend ? AppColors.primary : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
            tooltip: 'Toggle Legend',
          ),
          IconButton(
            icon: Icon(
              _showChart ? Icons.visibility : Icons.visibility_off,
              color: _showChart ? AppColors.primary : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
            tooltip: 'Toggle Chart',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Summary for ${_selectedPeriod.toLowerCase()} period',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () => _showDateRangePicker(),
                  tooltip: 'Select Date Range',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Income',
                  _totalIncome,
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildSummaryItem(
                  'Expenses',
                  _totalExpenses,
                  Colors.red,
                  Icons.arrow_downward,
                ),
                _buildSummaryItem(
                  'Balance',
                  _totalIncome - _totalExpenses,
                  _totalIncome - _totalExpenses >= 0 ? Colors.blue : Colors.orange,
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: 'KSH ').format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categorySpending.length,
            itemBuilder: (context, index) {
              final category = _categorySpending.keys.elementAt(index);
              final amount = _categorySpending[category] ?? 0;
              final percentage = _totalExpenses > 0 ? (amount / _totalExpenses * 100) : 0;
              
              return ListTile(
                title: Text(category),
                subtitle: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: 'KSH ').format(amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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
        _initializeChartData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          RefreshIndicator(
            onRefresh: _initializeChartData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((period) {
                              final isSelected = _selectedPeriod == period;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(period),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedPeriod = period;
                                        _initializeChartData();
                                      });
                                    }
                                  },
                                  selectedColor: Colors.white,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.red : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _buildSummaryCard(),
                    _buildInsightsCard(),
                    _buildChartControls(),
                    if (_showChart) _buildChartSection(),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Categories Tab
          RefreshIndicator(
            onRefresh: _initializeChartData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCategoryBreakdown(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          
          Widget page;
          switch (index) {
            case 0:
              page = const HomePage();
              break;
            case 1:
              page = const CategoriesPage();
              break;
            case 3:
              page = const TransactionsPage();
              break;
            case 4:
              page = const ProfilePage();
              break;
            default:
              return;
          }
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}