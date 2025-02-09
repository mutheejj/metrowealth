import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/core/services/database_service.dart';
import 'package:metrowealth/features/analysis/presentation/pages/analysis_page.dart';
import 'package:metrowealth/features/categories/presentation/pages/categories_page.dart';
import 'package:metrowealth/features/navigation/presentation/pages/main_navigation.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/profile/presentation/pages/profile_page.dart';
import 'package:metrowealth/features/transactions/presentation/pages/transactions_page.dart';
import 'package:metrowealth/core/widgets/bottom_nav_bar.dart';
import 'package:metrowealth/features/notifications/presentation/pages/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/auth/data/models/user_model.dart';
import 'package:metrowealth/features/transactions/data/models/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = DatabaseService();
  final _currencyFormat = NumberFormat.currency(
    symbol: 'KES ',
    decimalDigits: 2,
  );
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const CategoriesPage(),
            const AnalysisPage(),
            const TransactionsPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/images/logo_white.png',
          height: 30,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: StreamBuilder<DocumentSnapshot>(
        stream: _db.getUserStream(_db.currentUserId!),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final user = UserModel.fromMap(userData);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(user),
                    const SizedBox(height: 24),
                    _buildBalanceCards(user),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                    const SizedBox(height: 24),
                    _buildSavingsGoalsProgress(user),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Welcome Back! 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: user.photoUrl != null 
              ? NetworkImage(user.photoUrl!) 
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildBalanceCards(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Balances',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildBalanceCard(
                'Total Balance',
                user.totalBalance,
                Icons.account_balance_wallet,
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildBalanceCard(
                'Savings',
                user.savingsBalance,
                Icons.savings,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildBalanceCard(
                'Loan Balance',
                user.loanBalance,
                Icons.credit_score,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
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
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              'Send',
              Icons.send,
              () {/* TODO: Implement send */},
            ),
            _buildQuickActionButton(
              'Request',
              Icons.request_page,
              () {/* TODO: Implement request */},
            ),
            _buildQuickActionButton(
              'Scan',
              Icons.qr_code_scanner,
              () {/* TODO: Implement scan */},
            ),
            _buildQuickActionButton(
              'More',
              Icons.more_horiz,
              () {/* TODO: Implement more */},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {/* TODO: Navigate to transactions */},
              child: const Text('See All'),
            ),
          ],
        ),
        StreamBuilder<List<TransactionModel>>(
          stream: _db.getUserTransactions(_db.currentUserId!, limit: 5),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading transactions'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = snapshot.data!;

            if (transactions.isEmpty) {
              return const Center(
                child: Text('No transactions yet'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(transaction);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    final amount = isExpense ? -transaction.amount : transaction.amount;
    final color = isExpense ? Colors.red : Colors.green;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isExpense ? Icons.remove : Icons.add,
          color: color,
        ),
      ),
      title: Text(
        transaction.category,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        DateFormat('MMM d, y').format(transaction.date),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Text(
        _currencyFormat.format(amount),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsProgress(UserModel user) {
    // TODO: Implement savings goals progress
    return Container();
  }
}