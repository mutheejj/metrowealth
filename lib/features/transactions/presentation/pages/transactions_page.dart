import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/features/home/presentation/pages/home_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/transactions/data/repositories/transaction_repository.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';

enum DateFilterType { all, day, week, month, year, custom }

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _currencyFormat = NumberFormat.currency(symbol: 'KSH ', decimalDigits: 2);
  final _searchController = TextEditingController();
  int _selectedTab = 0; // 0: All, 1: Income, 2: Expense
  late final TransactionRepository _transactionRepository;
  late final CategoryRepository _categoryRepository;
  Map<String, CategoryModel> _categories = {};
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  DateFilterType _dateFilterType = DateFilterType.month;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _transactionRepository = TransactionRepository(userId);
    _categoryRepository = CategoryRepository(userId);
    _initializeDateFilter();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDateFilter() {
    final now = DateTime.now();
    switch (_dateFilterType) {
      case DateFilterType.day:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateFilterType.week:
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case DateFilterType.month:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case DateFilterType.year:
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case DateFilterType.all:
      case DateFilterType.custom:
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  Future<void> _loadData() async {
    try {
      // Load categories
      final categoriesStream = _categoryRepository.getCategories();
      await for (final categories in categoriesStream) {
        _categories = {for (var cat in categories) cat.id: cat};
        break;
      }

      await _updateTotals();
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTotals() async {
    _totalIncome = await _transactionRepository.getTotalIncome(
      startDate: _startDate,
      endDate: _endDate,
    );
    _totalExpenses = await _transactionRepository.getTotalExpenses(
      startDate: _startDate,
      endDate: _endDate,
    );
    
    setState(() {
      _totalBalance = _totalIncome - _totalExpenses;
      _isLoading = false;
    });
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Time'),
              selected: _dateFilterType == DateFilterType.all,
              onTap: () => _updateDateFilter(DateFilterType.all),
            ),
            ListTile(
              title: const Text('Today'),
              selected: _dateFilterType == DateFilterType.day,
              onTap: () => _updateDateFilter(DateFilterType.day),
            ),
            ListTile(
              title: const Text('This Week'),
              selected: _dateFilterType == DateFilterType.week,
              onTap: () => _updateDateFilter(DateFilterType.week),
            ),
            ListTile(
              title: const Text('This Month'),
              selected: _dateFilterType == DateFilterType.month,
              onTap: () => _updateDateFilter(DateFilterType.month),
            ),
            ListTile(
              title: const Text('This Year'),
              selected: _dateFilterType == DateFilterType.year,
              onTap: () => _updateDateFilter(DateFilterType.year),
            ),
            ListTile(
              title: const Text('Custom Range'),
              selected: _dateFilterType == DateFilterType.custom,
              onTap: () => _showCustomDateRangePicker(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDateFilter(DateFilterType type) {
    setState(() {
      _dateFilterType = type;
      _initializeDateFilter();
    });
    Navigator.pop(context);
    _loadData();
  }

  Future<void> _showCustomDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _dateFilterType = DateFilterType.custom;
        _startDate = picked.start;
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });
      Navigator.pop(context);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: _handleNavigation,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search transactions...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'Transactions',
            style: TextStyle(color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() => _isSearching = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _showDateFilterDialog,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // TODO: Implement additional filters
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Total Balance Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(_totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Income/Expense Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: _buildSummaryCard(
                    title: 'Income',
                    amount: _totalIncome,
                    isIncome: true,
                    isSelected: _selectedTab == 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 2),
                  child: _buildSummaryCard(
                    title: 'Expense',
                    amount: _totalExpenses,
                    isIncome: false,
                    isSelected: _selectedTab == 2,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Transactions List
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: StreamBuilder<List<TransactionModel>>(
              stream: _getFilteredTransactions(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedTab == 1 ? Icons.account_balance_wallet_outlined : 
                          _selectedTab == 2 ? Icons.shopping_cart_outlined : 
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 1 ? 'No income transactions' :
                          _selectedTab == 2 ? 'No expense transactions' :
                          'No transactions',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group transactions by month
                final groupedTransactions = _groupTransactionsByMonth(transactions);
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final monthEntry = groupedTransactions.entries.elementAt(index);
                    return _buildMonthSection(
                      monthEntry.key,
                      monthEntry.value,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Stream<List<TransactionModel>> _getFilteredTransactions() {
    Stream<List<TransactionModel>> stream;
    
    // First, filter by type
    switch (_selectedTab) {
      case 1:
        stream = _transactionRepository.getTransactionsByType(TransactionType.income);
        break;
      case 2:
        stream = _transactionRepository.getTransactionsByType(TransactionType.expense);
        break;
      default:
        stream = _transactionRepository.getTransactionsStream();
    }

    // Then filter by date range if set
    if (_startDate != null && _endDate != null) {
      stream = _transactionRepository.getTransactionsByDateRange(_startDate!, _endDate!);
    }

    // Finally, apply search filter
    if (_searchQuery.isNotEmpty) {
      return stream.map((transactions) {
        return transactions.where((transaction) {
          final searchLower = _searchQuery.toLowerCase();
          final category = _categories[transaction.categoryId];
          return transaction.title.toLowerCase().contains(searchLower) ||
                 transaction.description.toLowerCase().contains(searchLower) ||
                 (category?.name.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      });
    }

    return stream;
  }

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(List<TransactionModel> transactions) {
    final grouped = <String, List<TransactionModel>>{};
    for (var transaction in transactions) {
      final monthKey = DateFormat('MMMM yyyy').format(transaction.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    return grouped;
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required bool isIncome,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? (isIncome ? Colors.blue : Colors.red) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSelected ? Colors.white : (isIncome ? Colors.green : Colors.red),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isIncome ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<TransactionModel> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long, size: 20),
            ],
          ),
        ),
        ...transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final category = _categories[transaction.categoryId];
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (category?.color ?? Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(
                    int.parse('0x${category?.icon ?? 'e5c3'}'),
                    fontFamily: 'MaterialIcons',
                  ),
                  color: category?.color ?? Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm - MMM dd, yyyy').format(transaction.date),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (transaction.description.isNotEmpty)
                      Text(
                        transaction.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : ''}${_currencyFormat.format(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    category?.name ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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

  void _showTransactionDetails(TransactionModel transaction) {
    final category = _categories[transaction.categoryId];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Transaction Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteTransaction(transaction),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Amount', _currencyFormat.format(transaction.amount)),
            _buildDetailRow('Category', category?.name ?? 'Unknown'),
            _buildDetailRow('Date', DateFormat('MMMM dd, yyyy').format(transaction.date)),
            _buildDetailRow('Time', DateFormat('HH:mm').format(transaction.date)),
            if (transaction.description.isNotEmpty)
              _buildDetailRow('Description', transaction.description),
            if (transaction.notes?.isNotEmpty ?? false)
              _buildDetailRow('Notes', transaction.notes!),
            if (transaction.tags.isNotEmpty)
              _buildDetailRow('Tags', transaction.tags.join(', ')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      Navigator.pop(context); // Close details sheet
      try {
        await _transactionRepository.deleteTransaction(transaction);
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
  }

  void _handleNavigation(int index) {
    if (index == 3) return;
    
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CategoriesPage();
        break;
      case 2:
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
      MaterialPageRoute(builder: (_) => page),
    );
  }
}