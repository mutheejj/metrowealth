import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new notification
  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? userId,
  }) async {
    try {
      final notification = {
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': userId ?? _auth.currentUser?.uid,
      };

      await _firestore.collection('notifications').add(notification);
      await _sendEmailNotification(title, message, userId);
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  // Get user's notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  // Send email notification
  Future<void> _sendEmailNotification(
    String title,
    String message,
    String? userId,
  ) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userEmail = userDoc.data()?['email'];

      if (userEmail == null) return;

      // Check if SMTP credentials are configured
      final smtpUsername = dotenv.env['SMTP_USERNAME'] ?? '';
      final smtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
      
      if (smtpUsername.isEmpty || smtpPassword.isEmpty) {
        throw 'SMTP credentials not configured. Please check your .env file.';
      }

      // Configure SMTP server
      final smtpServer = SmtpServer(
        dotenv.env['SMTP_HOST'] ?? 'smtp.mailersend.net',
        port: int.parse(dotenv.env['SMTP_PORT'] ?? '587'),
        username: smtpUsername,
        password: smtpPassword,
        ssl: false,
        allowInsecure: true,
      );

      // Create a professional email message
      final emailMessage = Message()
        ..from = Address(dotenv.env['SMTP_USERNAME'] ?? '', dotenv.env['SMTP_FROM_NAME'] ?? 'MetroWealth Notifications')
        ..recipients.add(userEmail)
        ..subject = 'MetroWealth: $title'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background-color: #f44336; padding: 20px; text-align: center;">
              <h1 style="color: white; margin: 0;">MetroWealth</h1>
            </div>
            <div style="padding: 20px; background-color: #ffffff; border: 1px solid #e0e0e0;">
              <h2 style="color: #333333;">$title</h2>
              <p style="color: #666666; line-height: 1.6;">
                $message
              </p>
            </div>
            <div style="padding: 20px; background-color: #f5f5f5; text-align: center; font-size: 12px; color: #666666;">
              <p>This is an automated message from MetroWealth. Please do not reply to this email.</p>
              <p>© ${DateTime.now().year} MetroWealth. All rights reserved.</p>
            </div>
          </div>
        ''';

      // Send email with error handling
      try {
        await send(emailMessage, smtpServer);
      } catch (e) {
        print('Failed to send email: $e');
        // Store failed notification in a separate collection for retry
        await _firestore.collection('failed_notifications').add({
          'email': userEmail,
          'title': title,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'error': e.toString(),
        });
      }
    } catch (e) {
      print('Failed to send email notification: $e');
    }
  }
}