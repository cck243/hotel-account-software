import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  
  final List<String> categories = [
    'Raw Materials',
    'Staff Salary',
    'Electricity',
    'Rent',
    'Transportation',
    'Marketing',
    'Maintenance',
    'Insurance',
    'Taxes',
    'Other'
  ];
  
  double get todayExpenses {
    final today = DateTime.now();
    return _expenses
        .where((expense) => _isSameDay(expense.date, today))
        .fold(0, (sum, expense) => sum + expense.amount);
  }
  
  double get weeklyExpenses {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _expenses
        .where((expense) => expense.date.isAfter(startOfWeek))
        .fold(0, (sum, expense) => sum + expense.amount);
  }
  
  double get monthlyExpenses {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _expenses
        .where((expense) => expense.date.isAfter(startOfMonth))
        .fold(0, (sum, expense) => sum + expense.amount);
  }
  
  Map<String, double> get topExpenseCategories {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final monthlyExpenses = _expenses
        .where((expense) => expense.date.isAfter(startOfMonth))
        .toList();
    
    Map<String, double> categoryTotals = {};
    
    for (var expense in monthlyExpenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    // Sort by amount and take top 5
    var sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(
      sortedEntries.take(5),
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  Future<void> fetchExpenses(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      _expenses = querySnapshot.docs
          .map((doc) => Expense.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addExpense(Expense expense, String userId) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('expenses')
          .add({...expense.toMap(), 'userId': userId});
      
      expense.id = docRef.id;
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }
  
  Future<void> updateExpense(Expense expense) async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toMap());
      
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }
  
  Future<void> deleteExpense(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(id)
          .delete();
      
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }
}
