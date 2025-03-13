import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/admin/data/services/admin_service.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final AdminService _adminService = AdminService();
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLoanDetailsDialog(Map<String, dynamic> loanData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loan Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Applicant', loanData['applicantName']),
              _buildDetailRow('Amount', 'KSH ${loanData['amount'].toStringAsFixed(2)}'),
              _buildDetailRow('Purpose', loanData['purpose']),
              _buildDetailRow('Duration', '${loanData['duration']} months'),
              _buildDetailRow('Interest Rate', '${loanData['interestRate']}%'),
              _buildDetailRow('Status', loanData['status'].toUpperCase()),
              _buildDetailRow('Application Date',
                  DateFormat('yyyy-MM-dd').format(loanData['applicationDate'].toDate())),
              const SizedBox(height: 16),
              const Text(
                'Documents',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.description),
                    label: const Text('ID Document'),
                    onPressed: () {
                      // TODO: View ID document
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.work),
                    label: const Text('Proof of Income'),
                    onPressed: () {
                      // TODO: View proof of income
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.account_balance),
                    label: const Text('Bank Statements'),
                    onPressed: () {
                      // TODO: View bank statements
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (loanData['status'] == 'pending')
            TextButton(
              onPressed: () async {
                await _adminService.updateLoanStatus(loanData['id'], 'rejected');
                if (mounted) Navigator.pop(context);
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (loanData['status'] == 'pending')
            FilledButton(
              onPressed: () async {
                await _adminService.updateLoanStatus(loanData['id'], 'approved');
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Approve'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search loans...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedStatus,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Status')),
                      const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      const DropdownMenuItem(value: 'approved', child: Text('Approved')),
                      const DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getLoansStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final loans = snapshot.data?.docs ?? [];
                final filteredLoans = loans.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = _searchQuery.isEmpty ||
                      data['applicantName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      data['purpose'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _selectedStatus == 'all' ||
                      data['status'] == _selectedStatus;
                  return matchesSearch && matchesStatus;
                }).toList();

                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Applicant')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Duration')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredLoans.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final date = data['applicationDate']?.toDate() ?? DateTime.now();
                        final status = data['status'] as String;

                        return DataRow(
                          cells: [
                            DataCell(Text(DateFormat('yyyy-MM-dd').format(date))),
                            DataCell(Text(data['applicantName'] ?? 'N/A')),
                            DataCell(Text('KSH ${data['amount'].toStringAsFixed(2)}')),
                            DataCell(Text('${data['duration']} months')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _showLoanDetailsDialog(data),
                                  ),
                                  if (status == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.check_circle),
                                      color: Colors.green,
                                      onPressed: () async {
                                        await _adminService.updateLoanStatus(
                                            data['id'], 'approved');
                                      },
                                    ),
                                  if (status == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.cancel),
                                      color: Colors.red,
                                      onPressed: () async {
                                        await _adminService.updateLoanStatus(
                                            data['id'], 'rejected');
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}