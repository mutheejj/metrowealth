import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final String userId;
  final CollectionReference _categoriesCollection;

  CategoryRepository(this.userId)
      : _categoriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('categories');

  // Initialize default categories for a new user
  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await _categoriesCollection.limit(1).get();
      if (existingCategories.docs.isNotEmpty) {
        print('Categories already exist for user');
        return;
      }

      final defaultCategories = CategoryModel.getDefaultCategories(userId);
      final batch = FirebaseFirestore.instance.batch();
      
      for (var category in defaultCategories) {
        final docRef = _categoriesCollection.doc();
        batch.set(docRef, category.toMap());
      }
      
      await batch.commit();
      print('Successfully initialized default categories');
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  // Get categories by type
  Stream<List<CategoryModel>> getCategoriesByType(CategoryType type) {
    return _categoriesCollection
        .where('type', isEqualTo: type.toString().split('.').last)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all categories
  Stream<List<CategoryModel>> getCategories() {
    return _categoriesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  // Add a new category
  Future<DocumentReference> addCategory(CategoryModel category) async {
    try {
      // Create a new document reference
      final docRef = _categoriesCollection.doc();
      
      // Create a complete category with the user ID
      final categoryWithUser = category.copyWith(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
      
      // Set the document data
      await docRef.set(categoryWithUser.toMap());
      return docRef;
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  // Update a category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      // Ensure the category belongs to the current user
      if (category.userId != userId) {
        throw Exception('Cannot update category: Permission denied');
      }
      
      await _categoriesCollection.doc(category.id).update(category.toMap());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Verify ownership before deletion
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) {
        throw Exception('Category not found');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception('Cannot delete category: Permission denied');
      }
      
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Get a single category
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;
      
      final category = CategoryModel.fromFirestore(doc);
      if (category.userId != userId) {
        throw Exception('Cannot access category: Permission denied');
      }
      
      return category;
    } catch (e) {
      print('Error getting category: $e');
      rethrow;
    }
  }

  // Get total spent amount for a category
  Future<double> getCategorySpentAmount(String categoryId) async {
    final doc = await _categoriesCollection.doc(categoryId).get();
    if (!doc.exists) return 0.0;
    final data = doc.data() as Map<String, dynamic>;
    return (data['spent'] ?? 0.0).toDouble();
  }

  // Update category spent amount
  Future<void> updateCategorySpentAmount(String categoryId, double amount) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) {
        throw Exception('Category not found');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception('Cannot update category: Permission denied');
      }
      
      await _categoriesCollection.doc(categoryId).update({
        'spent': FieldValue.increment(amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating category spent amount: $e');
      rethrow;
    }
  }

  // Get total budget for user
  Future<double> getTotalBudget() async {
    try {
      final snapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.fold<double>(
        0.0,
        (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['budget'] ?? 0.0),
      );
    } catch (e) {
      print('Error getting total budget: $e');
      rethrow;
    }
  }

  // Get total spent for user
  Future<double> getTotalSpent() async {
    try {
      final snapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.fold<double>(
        0.0,
        (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['spent'] ?? 0.0),
      );
    } catch (e) {
      print('Error getting total spent: $e');
      rethrow;
    }
  }

  // Reset monthly spent amounts
  Future<void> resetMonthlySpent() async {
    try {
      final snapshot = await _categoriesCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'spent': 0.0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error resetting monthly spent: $e');
      rethrow;
    }
  }
} 