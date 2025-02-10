import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  CategoryRepository(this.userId);

  // Get user's categories collection reference
  CollectionReference get _categoriesCollection => 
      _firestore.collection('users').doc(userId).collection('categories');

  // Stream all categories
  Stream<List<CategoryModel>> getCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Stream categories by type
  Stream<List<CategoryModel>> getCategoriesByType(CategoryType type) {
    return _categoriesCollection
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  // Add new category
  Future<DocumentReference> addCategory(CategoryModel category) {
    return _categoriesCollection.add(category.toMap());
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) {
    return _categoriesCollection.doc(category.id).update(category.toMap());
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) {
    return _categoriesCollection.doc(categoryId).delete();
  }

  // Update category budget
  Future<void> updateCategoryBudget(String categoryId, double budget) {
    return _categoriesCollection.doc(categoryId).update({'budget': budget});
  }

  // Add subcategory
  Future<void> addSubcategory(String categoryId, SubcategoryModel subcategory) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final updatedSubcategories = [...categoryData.subcategories, subcategory];
    
    return _categoriesCollection.doc(categoryId).update({
      'subcategories': updatedSubcategories.map((e) => e.toMap()).toList(),
    });
  }

  // Update subcategory
  Future<void> updateSubcategory(
    String categoryId, 
    SubcategoryModel subcategory
  ) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final updatedSubcategories = categoryData.subcategories.map((e) {
      if (e.id == subcategory.id) return subcategory;
      return e;
    }).toList();
    
    return _categoriesCollection.doc(categoryId).update({
      'subcategories': updatedSubcategories.map((e) => e.toMap()).toList(),
    });
  }

  // Delete subcategory
  Future<void> deleteSubcategory(String categoryId, String subcategoryId) async {
    final category = await _categoriesCollection.doc(categoryId).get();
    final categoryData = CategoryModel.fromFirestore(category);
    
    final updatedSubcategories = categoryData.subcategories
        .where((e) => e.id != subcategoryId)
        .toList();
    
    return _categoriesCollection.doc(categoryId).update({
      'subcategories': updatedSubcategories.map((e) => e.toMap()).toList(),
    });
  }

  // Get category spending for a time period
  Future<Map<String, double>> getCategorySpending(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .where('type', isEqualTo: 'expense')
        .get();

    final spending = <String, double>{};
    
    for (var doc in transactions.docs) {
      final data = doc.data();
      final categoryId = data['categoryId'] as String;
      final amount = (data['amount'] as num).toDouble();
      
      spending[categoryId] = (spending[categoryId] ?? 0) + amount;
    }
    
    return spending;
  }

  // Initialize default categories for new user
  Future<void> initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        icon: 'restaurant',
        color: Colors.green,
        type: CategoryType.expense,
        userId: userId,
        isDefault: true,
        subcategories: [
          SubcategoryModel(
            id: 'groceries',
            name: 'Groceries',
            icon: 'shopping_cart',
          ),
          SubcategoryModel(
            id: 'restaurants',
            name: 'Restaurants',
            icon: 'restaurant',
          ),
        ],
        lastUpdated: DateTime.now(),
      ),
      // Add more default categories...
    ];

    final batch = _firestore.batch();
    
    for (var category in defaultCategories) {
      final docRef = _categoriesCollection.doc(category.id);
      batch.set(docRef, category.toMap());
    }

    return batch.commit();
  }
} 