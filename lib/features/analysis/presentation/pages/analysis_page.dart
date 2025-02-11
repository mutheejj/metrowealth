import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/search_page.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/core/services/database_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  final _currencyFormat = NumberFormat.currency(symbol: 'KSH ', decimalDigits: 2);
  String _selectedPeriod = 'Monthly';
  DateTime _selectedDate = DateTime.now();
  late DateTime _startDate;
  DateTime _endDate = DateTime.now();
  
  late TabController _tabController;
  late List<BarChartGroupData> _barGroups;
  late FlTitlesData _titlesData;
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Year'];
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  Map<String, double> _incomeData = {};
  Map<String, double> _expenseData = {};
  Map<String, double> _categorySpending = {};
  Map<String, List<double>> _trends = {};
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _totalBudget = 0;
  Map<String, double> _categoryBudgets = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startDate = DateTime(DateTime.now().year, 1, 1); // Start from beginning of year
    _loadAnalysisData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysisData() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _db.getTransactionsByDateRangeAsFuture(
        _db.currentUserId!,
        _startDate,
        _endDate,
      );
      
      final categorySpending = await _db.getSpendingByCategory(
        _db.currentUserId!,
        _startDate,
        _endDate,
      );

      // Get category budgets
      final categories = await _db.getUserCategories(_db.currentUserId!).first;
      _categoryBudgets = {};
      for (var doc in categories.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String;
        final budget = (data['budget'] as num).toDouble();
        _categoryBudgets[name] = budget;
      }

      final totalBudget = await _db.getTotalBudget(_db.currentUserId!);

      _categorySpending = categorySpending;
      _totalBudget = totalBudget;
      
      _processTransactionData(transactions);
      _calculateTrends(transactions);
      _initializeChartData();
      
      setState(() {
        _isLoading = false;
        _totalIncome = _calculateTotalIncome();
        _totalExpense = _calculateTotalExpense();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  void _processTransactionData(List<dynamic> transactions) {
    _incomeData.clear();
    _expenseData.clear();

    // Group transactions by period
    for (var transaction in transactions) {
      final date = _getDateKey(transaction.date);
      final amount = transaction.amount;
      
      if (transaction.type == 'income') {
        _incomeData[date] = (_incomeData[date] ?? 0) + amount;
      } else {
        _expenseData[date] = (_expenseData[date] ?? 0) + amount;
      }
    }

    // Ensure all periods have data (fill gaps with zeros)
    final allDates = {..._incomeData.keys, ..._expenseData.keys}.toList()..sort();
    
    // Fill missing dates based on selected period
    final filledDates = _fillMissingDates(allDates);
    
    for (var date in filledDates) {
      _incomeData.putIfAbsent(date, () => 0);
      _expenseData.putIfAbsent(date, () => 0);
    }
  }

  List<String> _fillMissingDates(List<String> existingDates) {
    if (existingDates.isEmpty) return [];

    final filledDates = <String>[];
    final firstDate = _parseDate(existingDates.first);
    final lastDate = _parseDate(existingDates.last);
    
    var currentDate = firstDate;
    while (currentDate.isBefore(lastDate) || currentDate.isAtSameMomentAs(lastDate)) {
      filledDates.add(_getDateKey(currentDate));
      
      switch (_selectedPeriod) {
        case 'Daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'Weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
          break;
        case 'Year':
          currentDate = DateTime(currentDate.year + 1);
          break;
      }
    }
    
    return filledDates;
  }

  DateTime _parseDate(String dateKey) {
    try {
      switch (_selectedPeriod) {
        case 'Daily':
          return DateTime.parse(dateKey);
        case 'Weekly':
          final weekNumber = int.parse(dateKey.split(' ')[1]);
          return DateTime(_startDate.year).add(Duration(days: weekNumber * 7));
        case 'Monthly':
          return DateFormat('MMM yyyy').parse(dateKey);
        case 'Year':
          return DateTime(int.parse(dateKey));
        default:
          return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  void _calculateTrends(List<dynamic> transactions) {
    _trends.clear();
    final now = DateTime.now();
    
    // Calculate last 6 months trends
    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = DateFormat('MMM yyyy').format(month);
      _trends[monthKey] = [0, 0]; // [income, expense]
    }

    for (var transaction in transactions) {
      final date = transaction.date as DateTime;
      final monthKey = DateFormat('MMM yyyy').format(date);
      final amount = transaction.amount as double;
      
      if (_trends.containsKey(monthKey)) {
        if (transaction.type == 'income') {
          _trends[monthKey]![0] += amount;
        } else {
          _trends[monthKey]![1] += amount;
        }
      }
    }
  }

  String _getDateKey(DateTime date) {
    switch (_selectedPeriod) {
      case 'Daily':
        return DateFormat('yyyy-MM-dd').format(date);
      case 'Weekly':
        final firstDayOfYear = DateTime(date.year);
        final diff = date.difference(firstDayOfYear);
        final weekNumber = (diff.inDays / 7).ceil();
        return 'Week $weekNumber';
      case 'Monthly':
        return DateFormat('MMM yyyy').format(date);
      case 'Year':
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  void _initializeChartData() {
    final sortedDates = _incomeData.keys.toList()..sort();
    _barGroups = sortedDates.asMap().entries.map((entry) {
      final date = entry.value;
      return _generateBarGroup(
        entry.key,
        _incomeData[date] ?? 0,
        _expenseData[date] ?? 0,
        date,
      );
    }).toList();

    _titlesData = FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= sortedDates.length) return const Text('');
            final date = sortedDates[value.toInt()];
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  _formatDateLabel(date),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            );
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              _currencyFormat.format(value).replaceAll('KSH ', ''),
              style: const TextStyle(fontSize: 10),
            );
          },
          reservedSize: 60,
        ),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _formatDateLabel(String date) {
    switch (_selectedPeriod) {
      case 'Daily':
        try {
          return DateFormat('dd MMM').format(DateTime.parse(date));
        } catch (e) {
          return date;
        }
      case 'Weekly':
        return date;
      case 'Monthly':
        // Don't try to parse monthly format, just return as is
        return date;
      case 'Year':
        return date;
      default:
        return date;
    }
  }

  Future<void> _selectDateRange() async {
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
      });
      _loadAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Analysis',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Analysis is the third tab
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Balance Section with Date Range
        _buildHeaderSection(),
        const SizedBox(height: 20),

        // Main Content Area
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Categories'),
                    Tab(text: 'Trends'),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(),
                            _buildCategoriesTab(),
                            _buildTrendsTab(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final spendingRatio = _totalBudget > 0 ? (_totalExpense / _totalBudget).clamp(0.0, double.infinity) : 0.0;
    final isOverBudget = spendingRatio > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_totalIncome - _totalExpense),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range, color: Colors.white),
                label: Text(
                  '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: spendingRatio.clamp(0, 1),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.blue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${(spendingRatio * 100).toStringAsFixed(1)}% of Budget',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _currencyFormat.format(_totalBudget),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periods.map((period) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: period != _periods.last ? 10 : 0,
                  ),
                  child: _buildPeriodButton(period),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _buildChartSection(),
          const SizedBox(height: 20),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final sortedCategories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildPieChartSection(),
        const SizedBox(height: 20),
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedCategories.map((entry) {
          final category = entry.key;
          final spent = entry.value;
          final budget = _categoryBudgets[category] ?? _totalBudget * 0.2;
          
          return _buildBudgetItem(
            category: category,
            spent: spent,
            budget: budget,
          );
        }),
        const SizedBox(height: 20),
        _buildCategoryAnalysis(),
      ],
    );
  }

  Widget _buildTrendsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTrendChart(),
        const SizedBox(height: 20),
        _buildTrendAnalysis(),
      ],
    );
  }

  Widget _buildPieChartSection() {
    final total = _categorySpending.values.fold(0.0, (a, b) => a + b);
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    final sections = _categorySpending.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / total) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: amount,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Column(
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
          children: _categorySpending.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final amount = entry.value.value;
            final color = colors[index % colors.length];
                final percentage = (amount / total) * 100;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                      const SizedBox(width: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                    _currencyFormat.format(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final months = _trends.keys.toList();
    final incomePoints = _trends.values.map((v) => v[0]).toList();
    final expensePoints = _trends.values.map((v) => v[1]).toList();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6-Month Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= months.length) {
                          return const Text('');
                        }
                        return RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            months[value.toInt()],
                            style: const TextStyle(fontSize: 10),
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
                          _currencyFormat.format(value).replaceAll('KSH ', ''),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: incomePoints.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: expensePoints.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y < 0 ? 'Expense' : 'Income'}\n${_currencyFormat.format(spot.y.abs())}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    // Calculate month-over-month changes
    final months = _trends.keys.toList();
    if (months.length < 2) return const SizedBox();

    final currentMonth = months.last;
    final previousMonth = months[months.length - 2];
    
    final currentIncome = _trends[currentMonth]![0];
    final currentExpense = _trends[currentMonth]![1];
    final previousIncome = math.max(_trends[previousMonth]![0], 0.01); // Avoid division by zero
    final previousExpense = math.max(_trends[previousMonth]![1], 0.01); // Avoid division by zero

    final incomeChange = ((currentIncome - previousIncome) / previousIncome * 100)
        .clamp(-double.infinity, double.infinity);
    final expenseChange = ((currentExpense - previousExpense) / previousExpense * 100)
        .clamp(-double.infinity, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Month-over-Month Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTrendCard(
          title: 'Income Trend',
          amount: currentIncome,
          change: incomeChange.isFinite ? incomeChange : 0.0,
          isIncome: true,
        ),
        const SizedBox(height: 12),
        _buildTrendCard(
          title: 'Expense Trend',
          amount: currentExpense,
          change: expenseChange.isFinite ? expenseChange : 0.0,
          isIncome: false,
        ),
      ],
    );
  }

  Widget _buildTrendCard({
    required String title,
    required double amount,
    required double change,
    required bool isIncome,
  }) {
    final isPositive = change > 0;
    final changeColor = isIncome ? (isPositive ? Colors.green : Colors.red)
                                : (isPositive ? Colors.red : Colors.green);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFormat.format(amount),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAnalysis() {
    if (_categorySpending.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final sortedCategories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalSpent = sortedCategories.fold<double>(
      0, (sum, entry) => sum + entry.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...sortedCategories.map((entry) {
          final percentage = totalSpent > 0 
              ? (entry.value / totalSpent * 100).clamp(0, 100)
              : 0.0;
          
          return _buildCategoryAnalysisItem(
            category: entry.key,
            amount: entry.value,
            percentage: percentage,
            budget: _categoryBudgets[entry.key] ?? 0,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryAnalysisItem({
    required String category,
    required double amount,
    required num percentage,
    required double budget,
  }) {
    final budgetUsage = budget > 0 ? (amount / budget * 100).clamp(0.0, 100.0) : 0.0;
    final isOverBudget = amount > budget && budget > 0;
    final double safePercentage = percentage.toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${safePercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currencyFormat.format(amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (budget > 0)
                Text(
                  'Budget: ${_currencyFormat.format(budget)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          if (budget > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: budgetUsage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isOverBudget
                  ? 'Over budget by ${_currencyFormat.format(amount - budget)}'
                  : '${budgetUsage.toStringAsFixed(1)}% of budget used',
              style: TextStyle(
                color: isOverBudget ? Colors.red : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Income & Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem('Income', Colors.blue),
                    _buildLegendItem('Expense', Colors.red),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rodIndex == 0 ? 'Income' : 'Expense'}\n${_currencyFormat.format(rod.toY)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: _titlesData,
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: _barGroups,
                maxY: _calculateMaxY(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Income',
            amount: _calculateTotalIncome(),
            isIncome: true,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Expense',
            amount: _calculateTotalExpense(),
            isIncome: false,
          ),
        ),
      ],
    );
  }

  double _calculateMaxY() {
    double maxIncome = _incomeData.values.fold(0.0, (max, value) => math.max(max, value));
    double maxExpense = _expenseData.values.fold(0.0, (max, value) => math.max(max, value));
    return (math.max(maxIncome, maxExpense) * 1.2).ceilToDouble();
  }

  double _calculateTotalIncome() {
    return _incomeData.values.fold(0, (sum, value) => sum + value);
  }

  double _calculateTotalExpense() {
    return _expenseData.values.fold(0, (sum, value) => sum + value);
  }

  BarChartGroupData _generateBarGroup(int x, double income, double expense, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: Colors.blue,
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expense,
          color: Colors.red,
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              _currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index == 2) return; // Already on analysis page
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TransactionsPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  Widget _buildBudgetItem({
    required String category,
    required double spent,
    required double budget,
  }) {
    final percentage = (spent / budget * 100).clamp(0.0, 100.0);
    final isOverBudget = spent > budget;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isOverBudget ? Colors.red : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _currencyFormat.format(spent),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'of ${_currencyFormat.format(budget)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
} 