import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/categories/presentation/pages/add_expense_page.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryDetailPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryDetailPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final _currencyFormat = NumberFormat.currency(symbol: 'KES ');
  final _dateFormat = DateFormat('MMM dd');
  final _timeFormat = DateFormat('HH:mm');
  final DatabaseService _db = DatabaseService();
  late CategoryRepository _repository;
  late Stream<CategoryModel> _categoryStream;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year', 'All Time'];
  int _currentIndex = 1; // For bottom navigation, Categories tab
  List<FlSpot> _spendingData = [];

  @override
  void initState() {
    super.initState();
    _repository = CategoryRepository(FirebaseAuth.instance.currentUser!.uid);
    _initializeData();
  }

  void _initializeData() {
    // Set up real-time category updates using DatabaseService
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _categoryStream = _db
        .getUserCategories(userId)
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.id == widget.category.id)
            .map((doc) => CategoryModel.fromFirestore(doc))
            .first);
    _loadStatistics();
    _loadSpendingData();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _repository.getCategoryStatistics(widget.category.id);
      setState(() => _statistics = stats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSpendingData() async {
    try {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'This Week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        case 'All Time':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      final transactions = await _db
          .getTransactionsByDateRange(widget.category.userId, startDate, now)
          .first;

      // Group transactions by date and calculate daily totals
      final Map<DateTime, double> dailyTotals = {};
      
      for (var transaction in transactions) {
        final date = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        dailyTotals[date] = (dailyTotals[date] ?? 0) + transaction.amount;
      }

      // Convert to FlSpot points
      final spots = dailyTotals.entries.map((entry) {
        final daysFromStart = entry.key.difference(startDate).inDays.toDouble();
        return FlSpot(daysFromStart, entry.value);
      }).toList();

      // Sort spots by x value
      spots.sort((a, b) => a.x.compareTo(b.x));

      setState(() => _spendingData = spots);
    } catch (e) {
      debugPrint('Error loading spending data: $e');
    }
  }

  void _onNavigationItemTapped(int index) {
    if (_currentIndex == index) return;

    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CategoriesPage();
        break;
      case 2:
        page = const TransactionsPage();
        break;
      case 3:
        page = const AnalysisPage();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: _showOptions,
            ),
          ),
        ],
      ),
      body: StreamBuilder<CategoryModel>(
        stream: _categoryStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final category = snapshot.data!;

          return Column(
            children: [
              _buildHeader(category),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  _buildPeriodSelector(),
                                  _buildStatisticsCards(),
                                  _buildSpendingChart(),
                                  _buildTransactionHeader(),
                                ],
                              ),
                            ),
                            _buildTransactionsList(category),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigationItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpensePage(category: widget.category),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(CategoryModel category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                IconData(int.parse('0x${category.icon}'), fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                category.type.toString().split('.').last,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${category.percentageSpent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: category.isOverBudget ? Colors.red[200] : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(category.budget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Spent',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(category.spent),
                    style: TextStyle(
                      color: category.isOverBudget ? Colors.red[200] : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: category.percentageSpent / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                category.isOverBudget ? Colors.red[200]! : Colors.white,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periods.length,
        itemBuilder: (context, index) {
          final period = _periods[index];
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPeriod = period);
                  _loadStatistics();
                  _loadSpendingData();
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            'Daily Average',
            _currencyFormat.format(_statistics['dailyAverage'] ?? 0),
            Icons.timeline,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Monthly Total',
            _currencyFormat.format(_statistics['monthlyTotal'] ?? 0),
            Icons.calendar_today,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'Growth',
            '${(_statistics['monthOverMonthGrowth'] ?? 0).toStringAsFixed(1)}%',
            Icons.trending_up,
            color: (_statistics['monthOverMonthGrowth'] ?? 0) > 0 
                ? Colors.green 
                : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[600]),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    if (_spendingData.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No spending data available'),
        ),
      );
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _currencyFormat.format(value).split('.')[0],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.now().subtract(
                    Duration(days: (_spendingData.last.x - value).toInt()),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                interval: _spendingData.length > 7 ? 7 : 1,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _spendingData,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = DateTime.now().subtract(
                    Duration(days: (_spendingData.last.x - spot.x).toInt()),
                  );
                  return LineTooltipItem(
                    '${DateFormat('MMM dd').format(date)}\n${_currencyFormat.format(spot.y)}',
                    const TextStyle(color: Colors.black),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // TODO: Show all transactions
            },
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(CategoryModel category) {
    final transactions = category.transactions.where((transaction) {
      final now = DateTime.now();
      switch (_selectedPeriod) {
        case 'This Week':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return transaction.date.isAfter(startOfWeek);
        case 'This Month':
          final startOfMonth = DateTime(now.year, now.month, 1);
          return transaction.date.isAfter(startOfMonth);
        case 'This Year':
          final startOfYear = DateTime(now.year, 1, 1);
          return transaction.date.isAfter(startOfYear);
        case 'All Time':
          return true;
        default:
          return true;
      }
    }).toList();

    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions for ${_selectedPeriod.toLowerCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first transaction to start tracking',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group transactions by month
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in transactions) {
      final monthKey = DateFormat('MMMM yyyy').format(transaction.date);
      if (!groupedTransactions.containsKey(monthKey)) {
        groupedTransactions[monthKey] = [];
      }
      groupedTransactions[monthKey]!.add(transaction);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final monthKey = groupedTransactions.keys.elementAt(index);
          final monthTransactions = groupedTransactions[monthKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  monthKey,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...monthTransactions.map((transaction) => _buildTransactionItem(transaction)),
            ],
          );
        },
        childCount: groupedTransactions.length,
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return InkWell(
      onTap: () => _showTransactionDetails(transaction),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(
                  int.parse('0x${widget.category.icon}'),
                  fontFamily: 'MaterialIcons',
                ),
                color: widget.category.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _dateFormat.format(transaction.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeFormat.format(transaction.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '-${_currencyFormat.format(transaction.amount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Amount', _currencyFormat.format(transaction.amount)),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(transaction.date)),
            _buildDetailRow('Time', _timeFormat.format(transaction.date)),
            _buildDetailRow('Description', transaction.description),
            if (transaction.note != null)
              _buildDetailRow('Note', transaction.note!),
            if (transaction.frequency != TransactionFrequency.oneTime)
              _buildDetailRow('Frequency', transaction.frequency.toString().split('.').last),
            if (transaction.tags.isNotEmpty)
              _buildDetailRow('Tags', transaction.tags.join(', ')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editTransaction(transaction),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteTransaction(transaction),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Category'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit category
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('View Analytics'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement view analytics
            },
          ),
          if (!widget.category.isDefault)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Category',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteCategory();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    Navigator.pop(context); // Close details sheet
    // TODO: Implement edit transaction
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    Navigator.pop(context); // Close details sheet
    try {
      await _repository.deleteTransaction(widget.category.id, transaction.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting transaction: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? '
          'This will delete all associated transactions and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await _repository.deleteCategory(widget.category.id);
        if (mounted) {
          Navigator.pop(context); // Return to categories page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      }
    }
  }
} 