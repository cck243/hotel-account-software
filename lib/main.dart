import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:business_tracker/providers/auth_provider.dart';
import 'package:business_tracker/providers/sales_provider.dart';
import 'package:business_tracker/providers/expense_provider.dart';
import 'package:business_tracker/screens/login_screen.dart';
import 'package:business_tracker/screens/dashboard_screen.dart';
import 'package:business_tracker/screens/sales_screen.dart';
import 'package:business_tracker/screens/expenses_screen.dart';
import 'package:business_tracker/screens/reports_screen.dart';
import 'package:business_tracker/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Business Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        home: AuthWrapper(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/sales': (context) => SalesScreen(),
          '/expenses': (context) => ExpensesScreen(),
          '/reports': (context) => ReportsScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return authProvider.isAuthenticated ? DashboardScreen() : LoginScreen();
  }
}
