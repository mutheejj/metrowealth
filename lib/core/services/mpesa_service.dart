import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MPesaService {
  final String consumerKey;
  final String consumerSecret;
  final bool isProduction;
  
  final String _baseUrl;
  String? _accessToken;

  MPesaService({
    required this.consumerKey,
    required this.consumerSecret,
    this.isProduction = false,
  }) : _baseUrl = isProduction 
      ? 'https://api.safaricom.co.ke' 
      : 'https://sandbox.safaricom.co.ke';

  Future<String> _getAccessToken() async {
    if (_accessToken != null) return _accessToken!;

    final credentials = base64Encode(
      utf8.encode('$consumerKey:$consumerSecret')
    );

    final response = await http.get(
      Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      return _accessToken!;
    } else {
      throw Exception('Failed to get access token');
    }
  }
  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String userId,
  }) async {
    try {
      final token = await _getAccessToken();
      final timestamp = DateTime.now()
          .toUtc()
          .toString()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      
      const businessShortCode = '174379';
      const passKey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
      
      final password = base64Encode(
        utf8.encode('$businessShortCode$passKey$timestamp')
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': businessShortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.round(),
          'PartyA': phoneNumber,
          'PartyB': businessShortCode,
          'PhoneNumber': phoneNumber,
          'CallBackURL': 'https://your-domain.com/api/mpesa/stkCallback',
          'AccountReference': userId,
          'TransactionDesc': 'Payment for user $userId',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('STK push failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error initiating STK push: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> b2cPayment({
    required String phoneNumber,
    required double amount,
    required String remarks,
    required String initiatorName,
    required String securityCredential,
    required String commandID,
  }) async {
    try {
      final token = await _getAccessToken();

      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/b2c/v1/paymentrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'InitiatorName': initiatorName,
          'SecurityCredential': securityCredential,
          'CommandID': commandID,
          'Amount': amount.round(),
          'PartyA': 'YOUR_SHORTCODE',
          'PartyB': phoneNumber,
          'Remarks': remarks,
          'QueueTimeOutURL': 'YOUR_TIMEOUT_URL',
          'ResultURL': 'YOUR_RESULT_URL',
          'Occasion': '',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('B2C payment failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error processing B2C payment: $e');
      rethrow;
    }
  }
}