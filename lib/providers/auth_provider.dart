import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  Future<void> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      await _fetchUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An error occurred during login';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> registerWithEmail(String email, String password, String businessName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      
      // Create user document in Firestore
      final newUser = User(
        uid: userCredential.user!.uid,
        email: email,
        businessName: businessName,
        role: 'owner',
      );
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());
      
      _user = newUser;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An error occurred during registration';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        _user = User.fromMap(doc.data()!);
      }
    } catch (e) {
      _error = 'Failed to fetch user data';
    }
  }
  
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
