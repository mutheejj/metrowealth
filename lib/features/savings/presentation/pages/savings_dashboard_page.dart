import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/data/services/database_service.dart';

class SavingsDashboardPage extends StatefulWidget {
  const SavingsDashboardPage({super.key});

  @override
  State<SavingsDashboardPage> createState() => _SavingsDashboardPageState();
}

class _SavingsDashboardPageState extends State<SavingsDashboardPage> with SingleTickerProviderStateMixin {
  final _savingsService = SavingsService();
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _analytics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final analytics = await _savingsService.getSavingsAnalytics('current_user_id'); // Replace with actual user ID
      setState(() => _analytics = analytics);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Savings Dashboard'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: _buildSavingsOverview(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Active Goals'),
                    Tab(text: 'Achievements'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGoalsList(),
                      _buildAchievementsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement add new savings goal
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildSavingsOverview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_analytics == null) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Saved: KES ${_analytics!['totalSaved'].toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _analytics!['savingsRate'],
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_analytics!['savingsRate'] * 100).toStringAsFixed(1)}% of Target',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return StreamBuilder<List<SavingsGoalModel>>(
      stream: _savingsService.getSavingsGoals('current_user_id'), // Replace with actual user ID
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final goals = snapshot.data!;
        if (goals.isEmpty) {
          return const Center(
            child: Text('No savings goals yet. Create one to get started!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.savings, color: Colors.white),
                ),
                title: Text(goal.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.description),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: goal.progressPercentage),
                    const SizedBox(height: 4),
                    Text(
                      'KES ${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Show goal options
                  },
                ),
                onTap: () {
                  // TODO: Navigate to goal details
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsList() {
    // TODO: Implement achievements list
    return const Center(
      child: Text('Achievements coming soon!'),
    );
  }
}