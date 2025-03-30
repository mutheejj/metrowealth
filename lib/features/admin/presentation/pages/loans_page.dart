import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/admin/data/services/admin_service.dart';
import 'package:metrowealth/features/notifications/data/services/email_service.dart';
import 'package:metrowealth/features/notifications/data/services/notification_service.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final AdminService _adminService = AdminService();
  final EmailService _emailService = EmailService();
  final NotificationService _notificationService = NotificationService();
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showLoanDetailsDialog(QueryDocumentSnapshot doc) {
    final loanData = doc.data() as Map<String, dynamic>;
    _commentController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loan Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Applicant', loanData['userEmail']?.toString() ?? 'N/A'),
              _buildDetailRow('Amount', 'KSH ${(loanData['amount'] ?? 0.0).toStringAsFixed(2)}'),
              _buildDetailRow('Purpose', loanData['purpose']?.toString() ?? 'N/A'),
              _buildDetailRow('Duration', '${loanData['tenure']?.toString() ?? '0'} months'),
              _buildDetailRow('Interest Rate', '${loanData['interestRate'] ?? 0}%'),
              _buildDetailRow('Status', (loanData['status'] ?? 'pending').toUpperCase()),
              _buildDetailRow('Application Date',
                  DateFormat('yyyy-MM-dd').format((loanData['applicationDate'] as Timestamp?)?.toDate() ?? DateTime.now())),
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
              if (loanData['status'] == 'pending') ...[                
                const SizedBox(height: 16),
                const Text(
                  'Admin Comment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Enter comment for approval/rejection',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
              if (loanData['status'] == 'approved') ...[                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _sendLoanReminder({
                    ...loanData,
                    'id': doc.id,
                  }),
                  icon: const Icon(Icons.notification_add),
                  label: const Text('Send Payment Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (loanData['status'] == 'pending')
            TextButton(
              onPressed: () async {
                if (_commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a comment for rejection')),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Rejection'),
                    content: const Text('Are you sure you want to reject this loan application?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _adminService.updateLoanStatus(doc.id, 'rejected', comment: _commentController.text);
                          await _notificationService.createNotification(
                            title: 'Loan Application Rejected',
                            message: 'Your loan application has been rejected. Reason: ${_commentController.text}',
                            type: 'loan_status',
                            userId: loanData['userId'],
                          );
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Reject', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (loanData['status'] == 'pending')
            FilledButton(
              onPressed: () async {
                if (_commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a comment for approval')),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Approval'),
                    content: const Text('Are you sure you want to approve this loan application?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _adminService.updateLoanStatus(doc.id, 'approved', comment: _commentController.text);
                          await _notificationService.createNotification(
                            title: 'Loan Application Approved',
                            message: 'Congratulations! Your loan application has been approved. Note: ${_commentController.text}',
                            type: 'loan_status',
                            userId: loanData['userId'],
                          );
                          await _emailService.sendLoanApprovalEmail({
                            ...loanData,
                            'id': doc.id,
                          });
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                );
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

  Future<void> _sendLoanReminder(Map<String, dynamic> loanData) async {
    try {
      if (loanData['userEmail'] == null) {
        throw 'User email not found';
      }
      
      await _emailService.sendLoanReminder(
        recipient: loanData['userEmail'],
        loanId: loanData['id'],
        amount: loanData['amount'] ?? 0.0,
        dueDate: (loanData['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan reminder sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reminder: $e')),
        );
      }
    }
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
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
                    const SizedBox(width: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: _adminService.getLoansStream(),
                      builder: (context, emailSnapshot) {
                        return FilledButton.icon(
                          onPressed: emailSnapshot.hasData ? () async {
                            try {
                              final loans = emailSnapshot.data?.docs.map((doc) => doc.data() as Map<String, dynamic>).toList() ?? [];
                              await _emailService.sendLoanStatementEmail(loans);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Loan statement sent successfully')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to send loan statement: $e')),
                                );
                              }
                            }
                          } : null,
                          icon: const Icon(Icons.email),
                          label: const Text('Get Loan Statement'),
                        );
                      },
                    ),
                  ],
                ),
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
                final filteredLoans = loans.where((QueryDocumentSnapshot doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = _searchQuery.isEmpty ||
                      data['userEmail'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
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
                        DataColumn(label: Text('Duration (Months)')),
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
                            DataCell(Text(data['userEmail']?.toString() ?? 'N/A')),
                            DataCell(Text('KSH ${(data['amount'] ?? 0.0).toStringAsFixed(2)}')),
                            DataCell(Text('${data['tenure']?.toString() ?? '0'} months')),
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
                                    onPressed: () => _showLoanDetailsDialog(doc),
                                  ),
                                  if (status == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.check_circle),
                                      color: Colors.green,
                                      onPressed: () async {
                                        await _adminService.updateLoanStatus(
                                            doc.id, 'approved', comment: 'Approved via quick action');
                                      },
                                    ),
                                  if (status == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.cancel),
                                      color: Colors.red,
                                      onPressed: () async {
                                        await _adminService.updateLoanStatus(
                                            doc.id, 'rejected', comment: 'Rejected via quick action');
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