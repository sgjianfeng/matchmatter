import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchmatter/data/user.dart';
import 'auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerAccount(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Creating user...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating user...')),
        );
        // final UserCredential userCredential =
        //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //   email: _emailController.text,
        //   password: _passwordController.text,
        // );

        // final User? user = userCredential.user;

        User? user = await _authService.signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        if (user != null) {
          print('User created, updating user data...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User created, updating user data...')),
          );
          await UserDatabaseService(uid: user.uid).updateUserData(
            _nameController.text,
            _phoneController.text,
            _emailController.text, 
          );
          print('User data updated, navigating to home page...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User data updated, navigating to home page...')),
          );
          Navigator.of(context).pushReplacementNamed('/');
        }
      } on FirebaseAuthException catch (e) {
        print('Failed with error code: ${e.code}');
        print(e.message);
        if (e.code == 'email-already-in-use') {
          setState(() {
            _emailError = 'This email is already in use.';
          });
           _formKey.currentState!.validate(); // 触发表单的重新验证
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed with error code: ${e.code}')),
        );
        // ...
      } catch (e) {
        print('Failed with error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed with error: $e')),
        );
        // ...
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value != null && value.isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value != null && value.isEmpty
                      ? 'Please enter your phone number'
                      : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value != null && !value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    if (_emailError != null) {
                      return _emailError;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value != null && value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _registerAccount(context),
                  child: const Text('Sign Up'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
