import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.business_center,
                  size: 80,
                  color: Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  _isLogin ? 'Welcome Back' : 'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  _isLogin 
                    ? 'Sign in to your business account'
                    : 'Setup your business account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                ],
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                if (authProvider.error != null) ...[
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                
                SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      if (_isLogin) {
                        authProvider.loginWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      } else {
                        authProvider.registerWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          _businessNameController.text.trim(),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                
                SizedBox(height: 20),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      authProvider.clearError();
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Sign up'
                        : 'Already have an account? Sign in',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }
}
