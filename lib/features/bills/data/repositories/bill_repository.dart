import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/bills/data/models/bill_model.dart';

class BillRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  BillRepository(this.userId) : _firestore = FirebaseFirestore.instance;

  // CRUD operations for bills
  Future<List<BillModel>> getBills() async {
    final snapshot = await _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .get();
    
    return snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList();
  }

  Stream<List<BillModel>> getAllBills() {
    return _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList());
  }

  Stream<List<BillModel>> getUpcomingBills() {
    final now = DateTime.now();
    return _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .where('dueDate', isGreaterThanOrEqualTo: now)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList());
  }

  Stream<List<BillModel>> getPaidBills() {
    return _firestore
        .collection('bills')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'paid')
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => BillModel.fromFirestore(doc)).toList());
  }

  // Add other CRUD methods
} 