import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';

class SalesProvider with ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;
  
  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  
  double get todaySales {
    final today = DateTime.now();
    return _sales
        .where((sale) => _isSameDay(sale.date, today))
        .fold(0, (sum, sale) => sum + sale.amount);
  }
  
  double get weeklySales {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _sales
        .where((sale) => sale.date.isAfter(startOfWeek))
        .fold(0, (sum, sale) => sum + sale.amount);
  }
  
  double get monthlySales {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _sales
        .where((sale) => sale.date.isAfter(startOfMonth))
        .fold(0, (sum, sale) => sum + sale.amount);
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  Future<void> fetchSales(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      _sales = querySnapshot.docs
          .map((doc) => Sale.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addSale(Sale sale, String userId) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('sales')
          .add({...sale.toMap(), 'userId': userId});
      
      sale.id = docRef.id;
      _sales.insert(0, sale);
      notifyListeners();
    } catch (e) {
      print('Error adding sale: $e');
      rethrow;
    }
  }
  
  Future<void> updateSale(Sale sale) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales')
          .doc(sale.id)
          .update(sale.toMap());
      
      final index = _sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _sales[index] = sale;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating sale: $e');
      rethrow;
    }
  }
  
  Future<void> deleteSale(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('sales')
          .doc(id)
          .delete();
      
      _sales.removeWhere((sale) => sale.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    }
  }
}
