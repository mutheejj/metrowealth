import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _emailServiceUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  final String _serviceId = 'service_metrowealth'; // Replace with your EmailJS service ID
  final String _templateId = 'template_loan_application'; // Replace with your EmailJS template ID
  final String _userId = 'your_emailjs_user_id'; // Replace with your EmailJS user ID

  Future<void> sendLoanApplicationEmail(Map<String, dynamic> loanData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final emailData = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': {
          'to_email': user.email,
          'to_name': user.displayName ?? 'Valued Customer',
          'loan_type': loanData['productName'],
          'loan_amount': loanData['amount'].toString(),
          'loan_tenure': '${loanData['tenure']} months',
          'interest_rate': '${loanData['interestRate']}%',
          'monthly_installment': loanData['monthlyInstallment'].toStringAsFixed(2),
          'total_repayment': loanData['totalRepayment'].toStringAsFixed(2),
          'application_date': DateTime.now().toString(),
        }
      };

      final response = await http.post(
        Uri.parse(_emailServiceUrl),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost', // Update with your domain in production
        },
        body: json.encode(emailData),
      );

      if (response.statusCode != 200) {
        throw 'Failed to send email notification: ${response.body}';
      }

      // Log email sent in Firestore
      await _db.collection('email_logs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'loan_application',
        'loanId': loanData['id'],
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending loan application email: $e');
      // Log failed email attempt
      await _db.collection('email_logs').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'type': 'loan_application',
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }
}