import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _firstName = '';
  String _lastName = '';
  String _error = '';
  bool _isLogin = true;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _error = '';
      });

      try {
        if (_isLogin) {
          await _signIn();
        } else {
          await _signUp();
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _navigateToSplashScreen(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _error = 'No user found for that email. Please sign up.';
          _isLogin = false;
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _error = 'Wrong password provided.';
        });
      } else {
        setState(() {
          _error = 'Error: ${e.message}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      
      // Save user details to Realtime Database
      await _database.child('users').child(userCredential.user!.uid).set({
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
      });

      _navigateToSplashScreen(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _error = 'An account already exists for that email. Please sign in.';
          _isLogin = true;
        });
      } else {
        setState(() {
          _error = 'Error: ${e.message}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSplashScreen(String uid) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SplashScreen(uid: uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 50),
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  if (!_isLogin) ...[
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      onSaved: (value) => _firstName = value!,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      onSaved: (value) => _lastName = value!,
                    ),
                  ],
                  SizedBox(height: 24),
                  ElevatedButton(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                    onPressed: _isLoading ? null : _submitForm,
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    child: Text(_isLogin
                        ? 'Create an account'
                        : 'Already have an account? Sign In'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _error = '';
                      });
                    },
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        _error,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
