import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';


class EmailService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _smtpHost = dotenv.env['SMTP_HOST'] ?? 'smtp.mailersend.net';
  final int _smtpPort = int.parse(dotenv.env['SMTP_PORT'] ?? '587');
  final String _smtpUsername = dotenv.env['SMTP_USERNAME'] ?? '';
  final String _smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
  final String _fromEmail = dotenv.env['SMTP_USERNAME'] ?? '';
  final String _fromName = dotenv.env['SMTP_FROM_NAME'] ?? 'MetroWealth';

  factory EmailService() {
    return instance;
  }

  EmailService._();
  static final EmailService instance = EmailService._();

  Future<void> sendLoanApplicationEmail(Map<String, dynamic> loanData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      if (user.email == null) throw 'User email not found';

      // Check if SMTP credentials are configured
      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(user.email!)
        ..subject = 'Loan Application Confirmation'
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..html = '''
          <h2>Loan Application Details</h2>
          <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
          <p>Your loan application has been received with the following details:</p>
          <ul>
            <li>Loan Type: ${loanData['productName']}</li>
            <li>Amount: KSH ${loanData['amount'].toString()}</li>
            <li>Tenure: ${loanData['tenure']} months</li>
            <li>Interest Rate: ${loanData['interestRate']}%</li>
            <li>Monthly Installment: KSH ${loanData['monthlyInstallment'].toStringAsFixed(2)}</li>
            <li>Total Repayment: KSH ${loanData['totalRepayment'].toStringAsFixed(2)}</li>
            <li>Application Date: ${DateTime.now().toString()}</li>
          </ul>
          <p>We will review your application and get back to you shortly.</p>
          <p>Best regards,<br>MetroWealth Team</p>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
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

  Future<void> sendLoanApprovalEmail(Map<String, dynamic> loanData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      if (user.email == null) throw 'User email not found';

      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(loanData['userEmail'])
        ..subject = 'Loan Application Approved'
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..html = '''
          <h2>Loan Application Approved</h2>
          <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
          <p>Congratulations! Your loan application has been approved with the following details:</p>
          <ul>
            <li>Loan Type: ${loanData['productName']}</li>
            <li>Amount: KSH ${loanData['amount'].toString()}</li>
            <li>Tenure: ${loanData['tenure']} months</li>
            <li>Interest Rate: ${loanData['interestRate']}%</li>
            <li>Monthly Installment: KSH ${loanData['monthlyInstallment'].toStringAsFixed(2)}</li>
            <li>Total Repayment: KSH ${loanData['totalRepayment'].toStringAsFixed(2)}</li>
            <li>Approval Date: ${DateTime.now().toString()}</li>
          </ul>
          <p>Please review the terms and conditions carefully. Our team will contact you shortly with further instructions.</p>
          <p>Best regards,<br>MetroWealth Team</p>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
      }

      await _db.collection('email_logs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'loan_approval',
        'loanId': loanData['id'],
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending loan approval email: $e');
      await _db.collection('email_logs').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'type': 'loan_approval',
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }

  Future<void> sendSavingsStatementEmail(List<SavingsGoalModel> goals) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      if (user.email == null) throw 'User email not found';

      // Check if SMTP credentials are configured
      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      if (goals.isEmpty) {
        throw 'No savings goals available for statement';
      }

      final goalsHtml = goals.map((goal) => '''
        <tr style="background-color: #ffffff;">
          <td style="padding: 12px; border: 1px solid #dee2e6;">${const HtmlEscape().convert(goal.title)}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">KSH ${const HtmlEscape().convert(goal.targetAmount.toString())}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">KSH ${const HtmlEscape().convert(goal.currentAmount.toString())}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${((goal.currentAmount / goal.targetAmount) * 100).toStringAsFixed(1)}%</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${DateFormat('yyyy-MM-dd').format(goal.createdAt)}</td>
        </tr>
      ''').join('');

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(Address(user.email!, user.displayName ?? 'Valued Customer'))
        ..subject = 'Savings Goals Statement'
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..text = 'Please view this email in an HTML-compatible client to see your full savings statement.\n\nSavings goals count: ${goals.length}\nGenerated on: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
            <h2 style="color: #333; text-align: center;">Savings Goals Statement</h2>
            <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
            <p>Here is your savings goals statement as of ${DateFormat('yyyy-MM-dd').format(DateTime.now())}:</p>
            <table style="width: 100%; border-collapse: collapse; margin-top: 20px; margin-bottom: 20px;">
              <tr style="background-color: #f8f9fa;">
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Goal Title</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Target Amount</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Current Amount</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Progress</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Created Date</th>
              </tr>
              $goalsHtml
            </table>
            <p style="color: #666;">If you have any questions about your savings statement, please don't hesitate to contact our support team.</p>
            <p style="margin-top: 30px;">Best regards,<br>MetroWealth Team</p>
          </div>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
      }

      // Log email sent in Firestore
      await _db.collection('email_logs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'savings_statement',
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending savings statement email: $e');
      await _db.collection('email_logs').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'type': 'savings_statement',
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }

  Future<void> sendLoanReminder({required String recipient, required String loanId, required double amount, required DateTime dueDate}) async {
    try {
      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      final formattedAmount = NumberFormat.currency(symbol: 'KSH ', decimalDigits: 2).format(amount);
      final formattedDueDate = DateFormat('MMMM dd, yyyy').format(dueDate);

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(recipient)
        ..subject = 'Loan Payment Reminder'
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..html = '''
          <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Loan Payment Reminder</h2>
            <p>Dear Valued Customer,</p>
            <p>This is a friendly reminder that your loan payment is due soon. Here are the details:</p>
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
              <p><strong>Loan ID:</strong> ${loanId}</p>
              <p><strong>Payment Amount:</strong> ${formattedAmount}</p>
              <p><strong>Due Date:</strong> ${formattedDueDate}</p>
            </div>
            <p>Please ensure that your payment is made before the due date to avoid any late payment penalties.</p>
            <p>If you have already made the payment, please disregard this reminder.</p>
            <p style="margin-top: 30px;">Best regards,<br>MetroWealth Team</p>
          </div>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
      }

      // Log email sent in Firestore
      await _db.collection('email_logs').add({
        'type': 'loan_reminder',
        'loanId': loanId,
        'recipient': recipient,
        'amount': amount,
        'dueDate': dueDate,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending loan reminder email: $e');
      await _db.collection('email_logs').add({
        'type': 'loan_reminder',
        'loanId': loanId,
        'recipient': recipient,
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }

  Future<void> sendLoanStatementEmail(List<Map<String, dynamic>> loans) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User not authenticated';
      if (user.email == null) throw 'User email not found';

      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      if (loans.isEmpty) {
        throw 'No loan data available for statement';
      }

      final loansHtml = loans.map((loan) => '''
        <tr style="background-color: #ffffff;">
          <td style="padding: 12px; border: 1px solid #dee2e6;">${loan['id']}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${loan['productName']}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">KSH ${loan['amount'].toStringAsFixed(2)}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">KSH ${loan['monthlyInstallment'].toStringAsFixed(2)}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${loan['tenure']} months</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${loan['status']}</td>
          <td style="padding: 12px; border: 1px solid #dee2e6;">${DateFormat('yyyy-MM-dd').format(loan['dueDate'].toDate())}</td>
        </tr>
      ''').join('');

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(user.email!)
        ..subject = 'Loan Statement'
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
            <h2 style="color: #333; text-align: center;">Loan Statement</h2>
            <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
            <p>Here is your loan statement as of ${DateFormat('yyyy-MM-dd').format(DateTime.now())}:</p>
            <table style="width: 100%; border-collapse: collapse; margin-top: 20px; margin-bottom: 20px;">
              <tr style="background-color: #f8f9fa;">
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Loan ID</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Product Name</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Amount</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Monthly Payment</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Tenure</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Status</th>
                <th style="padding: 12px; border: 1px solid #dee2e6; text-align: left;">Due Date</th>
              </tr>
              ${loansHtml}
            </table>
            <p style="color: #666;">If you have any questions about your loan statement, please don't hesitate to contact our support team.</p>
            <p style="margin-top: 30px;">Best regards,<br>MetroWealth Team</p>
          </div>
        ''';

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
      }

      await _db.collection('email_logs').add({
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'loan_statement',
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending loan statement email: $e');
      await _db.collection('email_logs').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'type': 'loan_statement',
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }

  Future<void> sendBulkEmail({required List<String> recipients, required String subject, required String htmlContent}) async {
    try {
      if (_smtpUsername.isEmpty || _smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _smtpUsername,
        password: _smtpPassword,
        allowInsecure: false,
        ssl: false,
        ignoreBadCertificate: false
      );

      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..bccRecipients.addAll(recipients)
        ..subject = subject
        ..headers = {
          'Content-Type': 'text/html; charset=UTF-8',
          'X-Mailer': 'MetroWealth App',
        }
        ..html = htmlContent;

      try {
        final sendReport = await send(message, smtpServer);
        if (sendReport == null || sendReport.toString().isEmpty) {
          throw 'Failed to get send report from SMTP server';
        }
      } catch (e) {
        if (e.toString().contains('authentication failed')) {
          throw 'SMTP authentication failed. Please check your credentials.';
        } else if (e.toString().contains('connection refused')) {
          throw 'Failed to connect to SMTP server. Please check your network connection.';
        } else {
          throw 'Failed to send email: ${e.toString()}';
        }
      }

      await _db.collection('email_logs').add({
        'type': 'bulk_email',
        'recipientCount': recipients.length,
        'subject': subject,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

    } catch (e) {
      debugPrint('Error sending bulk email: $e');
      await _db.collection('email_logs').add({
        'type': 'bulk_email',
        'recipientCount': recipients.length,
        'subject': subject,
        'error': e.toString(),
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'failed',
      });
      rethrow;
    }
  }
}