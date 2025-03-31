import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/transactions/data/repositories/transaction_repository.dart';
import 'package:metrowealth/features/categories/data/repositories/category_repository.dart';
import 'package:metrowealth/features/categories/data/models/category_model.dart';

class SpendingInsightsPage extends StatefulWidget {
  final String userId;

  const SpendingInsightsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SpendingInsightsPageState createState() => _SpendingInsightsPageState();
}

class _SpendingInsightsPageState extends State<SpendingInsightsPage> {
  late TransactionRepository _transactionRepository;
  late CategoryRepository _categoryRepository;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  Map<String, double> _categorySpending = {};
  Map<String, CategoryModel> _categories = {};
  double _totalSpending = 0;

  @override
  void initState() {
    super.initState();
    _transactionRepository = TransactionRepository(widget.userId);
    _categoryRepository = CategoryRepository(widget.userId);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load categories first
      final categoriesSnapshot = await _categoryRepository.getCategories().first;
      _categories = {for (var cat in categoriesSnapshot) cat.id: cat};

      // Load spending data
      final spending = await _transactionRepository.getSpendingByCategory(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _categorySpending = spending;
        _totalSpending = spending.values.fold(0, (sum, amount) => sum + amount);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading spending data: $e')),
      );
    }
  }

  List<PieChartSectionData> _getSections() {
    final List<PieChartSectionData> sections = [];
    _categorySpending.forEach((categoryId, amount) {
      final category = _categories[categoryId];
      if (category != null) {
        final percentage = (amount / _totalSpending) * 100;
        sections.add(
          PieChartSectionData(
            color: category.color,
            value: amount,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            radius: 60,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      }
    });
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: _startDate,
                  end: _endDate,
                ),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
                _loadData();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spending: ${NumberFormat.currency(symbol: 'KSH ').format(_totalSpending)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections: _getSections(),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categorySpending.length,
                itemBuilder: (context, index) {
                  final categoryId = _categorySpending.keys.elementAt(index);
                  final amount = _categorySpending[categoryId] ?? 0;
                  final category = _categories[categoryId];
                  if (category == null) return const SizedBox.shrink();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category.color,
                      child: Icon(
                        IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: Text(
                      '${(amount / _totalSpending * 100).toStringAsFixed(1)}%',
                    ),
                    trailing: Text(
                      NumberFormat.currency(symbol: 'KSH ').format(amount),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}