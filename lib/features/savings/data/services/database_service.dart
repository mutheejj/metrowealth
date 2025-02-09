import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';
import 'package:metrowealth/features/savings/data/models/contribution_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Savings Goals
  Future<void> createSavingsGoal(SavingsGoalModel goal) async {
    await _db.collection('savings_goals').doc(goal.id).set(goal.toFirestore());
  }

  Future<void> updateSavingsGoal(SavingsGoalModel goal) async {
    await _db.collection('savings_goals').doc(goal.id).update(goal.toFirestore());
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    await _db.collection('savings_goals').doc(goalId).delete();
  }

  Stream<List<SavingsGoalModel>> getSavingsGoals(String userId) {
    return _db
        .collection('savings_goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingsGoalModel.fromFirestore(doc))
            .toList());
  }

  // Contributions
  Future<void> addContribution(String goalId, ContributionModel contribution) async {
    final batch = _db.batch();

    // Add contribution
    final contributionRef = _db
        .collection('savings_goals')
        .doc(goalId)
        .collection('contributions')
        .doc(contribution.id);
    batch.set(contributionRef, contribution.toFirestore());

    // Update goal's saved amount
    final goalRef = _db.collection('savings_goals').doc(goalId);
    batch.update(goalRef, {
      'savedAmount': FieldValue.increment(contribution.amount),
      'currentAmount': FieldValue.increment(contribution.amount),
    });

    await batch.commit();
  }

  Stream<List<ContributionModel>> getContributions(String goalId) {
    return _db
        .collection('savings_goals')
        .doc(goalId)
        .collection('contributions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContributionModel.fromFirestore(doc))
            .toList());
  }
} 