import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/bill.dart';

class BillsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get _userId => _auth.currentUser?.uid ?? '';

  // Get bills collection reference
  CollectionReference get _billsCollection => _firestore.collection('bills');

  // Add new bill
  Future<void> addBill(Bill bill) async {
    await _billsCollection.add(bill.toMap());
  }

  // Update existing bill
  Future<void> updateBill(Bill bill) async {
    await _billsCollection.doc(bill.id).update(bill.toMap());
  }

  // Delete bill
  Future<void> deleteBill(String billId) async {
    await _billsCollection.doc(billId).delete();
  }

  // Get all bills for current user
  Stream<List<Bill>> getBills() {
    return _billsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList());
  }

  // Get upcoming bills
  Stream<List<Bill>> getUpcomingBills() {
    return _billsCollection
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'pending')
        .where('dueDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList());
  }

  // Get bill history
  Stream<List<Bill>> getBillHistory() {
    return _billsCollection
        .where('userId', isEqualTo: _userId)
        .where('status', isEqualTo: 'paid')
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList());
  }

  // Mark bill as paid
  Future<void> markBillAsPaid(String billId) async {
    await _billsCollection.doc(billId).update({'status': 'paid'});
  }
} 