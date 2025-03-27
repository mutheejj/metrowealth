import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrowealth/core/constants/app_colors.dart';
import 'package:metrowealth/features/loans/data/services/loan_service.dart';
import 'package:metrowealth/features/loans/presentation/pages/loan_application_page.dart';
import 'package:metrowealth/features/loans/presentation/widgets/empty_loans_state.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final _loanService = LoanService();
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>>? _loans;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final loans = await _loanService.getUserLoans(userId);
        setState(() {
          _loans = loans;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loans = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loans == null || _loans!.isEmpty
              ? const EmptyLoansState()
              : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Loan Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find the perfect loan for your needs',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLoanCard(
                    context,
                    title: 'Personal Loan',
                    description: 'Get up to KSH 50,000 for your personal needs',
                    icon: Icons.person,
                    features: [
                      'Competitive interest rates from 8% p.a.',
                      'Flexible repayment terms up to 5 years',
                      'No collateral required',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLoanCard(
                    context,
                    title: 'Business Loan',
                    description: 'Grow your business with up to KSH 100,000',
                    icon: Icons.business,
                    features: [
                      'Interest rates from 10% p.a.',
                      'Repayment terms up to 7 years',
                      'Business plan assessment support',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLoanCard(
                    context,
                    title: 'Home Loan',
                    description: 'Make your dream home a reality',
                    icon: Icons.home,
                    features: [
                      'Interest rates from 6.5% p.a.',
                      'Loan terms up to 30 years',
                      'Free property valuation service',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoanApplicationPage(),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoanApplicationPage(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}