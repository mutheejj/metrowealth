import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:metrowealth/features/savings/data/models/savings_goal_model.dart';

class SavingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Savings Goals CRUD Operations
  Future<void> createSavingsGoal(SavingsGoalModel goal) async {
    try {
      await _db.collection('savings_goals').doc(goal.id).set(goal.toFirestore());
    } catch (e) {
      debugPrint('Error creating savings goal: $e');
      rethrow;
    }
  }

  Future<void> updateSavingsGoal(SavingsGoalModel goal) async {
    try {
      await _db.collection('savings_goals').doc(goal.id).update(goal.toFirestore());
    } catch (e) {
      debugPrint('Error updating savings goal: $e');
      rethrow;
    }
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    try {
      await _db.collection('savings_goals').doc(goalId).delete();
    } catch (e) {
      debugPrint('Error deleting savings goal: $e');
      rethrow;
    }
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

  // Contribution Management
  Future<void> addContribution(String goalId, double amount) async {
    try {
      final batch = _db.batch();
      final goalRef = _db.collection('savings_goals').doc(goalId);

      // Update goal's current amount and last contribution date
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(amount),
        'lastContributionDate': FieldValue.serverTimestamp(),
      });

      // Get the goal to check for achievements
      final goalDoc = await goalRef.get();
      final goal = SavingsGoalModel.fromFirestore(goalDoc);

      // Check and update achievements
      final updatedAchievements = Map<String, bool>.from(goal.achievements);
      if (amount >= goal.recommendedContributionAmount) {
        updatedAchievements['consistent_saver'] = true;
      }
      if (goal.currentAmount + amount >= goal.targetAmount) {
        updatedAchievements['goal_achieved'] = true;
      }

      batch.update(goalRef, {'achievements': updatedAchievements});
      await batch.commit();
    } catch (e) {
      debugPrint('Error adding contribution: $e');
      rethrow;
    }
  }

  // Automated Savings Rules
  Future<void> updateAutomationRules(
    String goalId,
    Map<String, dynamic> rules,
  ) async {
    try {
      await _db.collection('savings_goals').doc(goalId).update({
        'automationRules': rules,
        'isAutomatedSavingEnabled': true,
      });
    } catch (e) {
      debugPrint('Error updating automation rules: $e');
      rethrow;
    }
  }

  Future<void> toggleAutomatedSaving(String goalId, bool enabled) async {
    try {
      await _db.collection('savings_goals').doc(goalId).update({
        'isAutomatedSavingEnabled': enabled,
      });
    } catch (e) {
      debugPrint('Error toggling automated saving: $e');
      rethrow;
    }
  }

  // Milestone Management
  Future<void> addMilestone(String goalId, String milestone) async {
    try {
      await _db.collection('savings_goals').doc(goalId).update({
        'milestones': FieldValue.arrayUnion([milestone]),
      });
    } catch (e) {
      debugPrint('Error adding milestone: $e');
      rethrow;
    }
  }

  Future<void> removeMilestone(String goalId, String milestone) async {
    try {
      await _db.collection('savings_goals').doc(goalId).update({
        'milestones': FieldValue.arrayRemove([milestone]),
      });
    } catch (e) {
      debugPrint('Error removing milestone: $e');
      rethrow;
    }
  }

  // Analytics and Progress Tracking
  Future<Map<String, dynamic>> getSavingsAnalytics(String userId) async {
    try {
      final goalsQuery = await _db
          .collection('savings_goals')
          .where('userId', isEqualTo: userId)
          .get();

      double totalSaved = 0;
      double totalTarget = 0;
      int activeGoals = 0;
      int completedGoals = 0;

      for (var doc in goalsQuery.docs) {
        final goal = SavingsGoalModel.fromFirestore(doc);
        totalSaved += goal.currentAmount;
        totalTarget += goal.targetAmount;

        if (goal.status == SavingsGoalStatus.active) {
          activeGoals++;
        } else if (goal.status == SavingsGoalStatus.completed) {
          completedGoals++;
        }
      }

      return {
        'totalSaved': totalSaved,
        'totalTarget': totalTarget,
        'savingsRate': totalTarget > 0 ? totalSaved / totalTarget : 0,
        'activeGoals': activeGoals,
        'completedGoals': completedGoals,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      debugPrint('Error getting savings analytics: $e');
      rethrow;
    }
  }
}