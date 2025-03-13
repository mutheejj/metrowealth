import 'package:flutter/material.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/admin/data/services/admin_service.dart';
import 'package:metrowealth/features/admin/presentation/pages/users_management_page.dart';
import 'package:metrowealth/features/admin/presentation/pages/transactions_page.dart';
import 'package:metrowealth/features/admin/presentation/pages/loans_page.dart';
import 'package:metrowealth/features/admin/presentation/pages/reports_page.dart';
import 'package:metrowealth/features/admin/presentation/pages/settings_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  final List<String> _menuTitles = [
    'Dashboard',
    'Users',
    'Transactions',
    'Loans',
    'Reports'
  ];

  final AdminService _adminService = AdminService();
  Map<String, dynamic> _dashboardStats = {
    'totalUsers': 0,
    'totalTransactions': 0,
    'activeLoans': 0,
    'revenue': 0.0
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
      });
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/logo_white.png',
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'MetroWealth Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: _selectedIndex == 0,
              selectedColor: AppColors.primary,
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: _selectedIndex == 1,
              selectedColor: AppColors.primary,
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: _selectedIndex == 2,
              selectedColor: AppColors.primary,
              leading: const Icon(Icons.receipt_long),
              title: const Text('Transactions'),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: _selectedIndex == 3,
              selectedColor: AppColors.primary,
              leading: const Icon(Icons.account_balance),
              title: const Text('Loans'),
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: _selectedIndex == 4,
              selectedColor: AppColors.primary,
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () {
                setState(() => _selectedIndex = 4);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const UsersManagementPage();
      case 2:
        return const TransactionsPage();
      case 3:
        return const LoansPage();
      case 4:
        return const ReportsPage();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            GridView.count(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Users',
                  _dashboardStats['totalUsers'].toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Total Transactions',
                  'KSH ${_dashboardStats['totalTransactions']}',
                  Icons.receipt_long,
                  Colors.green,
                ),
                _buildStatCard(
                  'Active Loans',
                  _dashboardStats['activeLoans'].toString(),
                  Icons.account_balance,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Revenue',
                  'KSH ${_dashboardStats['revenue'].toStringAsFixed(2)}',
                  Icons.analytics,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _adminService.getTransactionsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error loading transactions');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final transactions = snapshot.data?.docs.take(5).toList() ?? [];

                        return Column(
                          children: transactions.map((transaction) {
                            final data = transaction.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: Icon(
                                data['type'] == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                                color: data['type'] == 'income' ? Colors.green : Colors.red,
                              ),
                              title: Text(data['title'] ?? 'Unknown Transaction'),
                              subtitle: Text(data['date']?.toDate()?.toString() ?? 'No date'),
                              trailing: Text(
                                'KSH ${(data['amount'] as num).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: data['type'] == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsers() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // TODO: Implement search functionality
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    onPressed: () {
                      // TODO: Implement add user functionality
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data?.docs ?? [];

                return Card(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: users.map((user) {
                        final userData = user.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Text(userData['name'] ?? 'N/A')),
                            DataCell(Text(userData['email'] ?? 'N/A')),
                            DataCell(Text(userData['phone'] ?? 'N/A')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: userData['isActive'] == true
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  userData['isActive'] == true ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: userData['isActive'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditUserDialog(context, user);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _showDeleteConfirmation(context, user);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, DocumentSnapshot user) {
    final userData = user.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: userData['name']);
    final emailController = TextEditingController(text: userData['email']);
    final phoneController = TextEditingController(text: userData['phone']);
    bool isActive = userData['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Status: '),
                  Switch(
                    value: isActive,
                    onChanged: (value) {
                      isActive = value;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await user.reference.update({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'isActive': isActive,
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DocumentSnapshot user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await user.reference.delete();
              if (mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    return const Center(child: Text('Transactions Management Coming Soon'));
  }

  Widget _buildLoans() {
    return const Center(child: Text('Loans Management Coming Soon'));
  }

  Widget _buildReports() {
    return const Center(child: Text('Reports Coming Soon'));
  }
}