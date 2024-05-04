import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> promptForSmsCode(
      BuildContext context, String verificationId) async {
    TextEditingController smsCodeController = TextEditingController();
    String? smsCode;

    try {
      smsCode = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter SMS Code'),
            content: TextField(
              autofocus: true,
              controller: smsCodeController,
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(smsCodeController.text);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    } finally {
      smsCodeController.dispose();
    }

    if (smsCode != null) {
      try {
        final userCredential = await _authService.signInWithCredential(
          PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          ),
        );
        // Handle successful sign in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in successful')),
        );
        // Navigate to the next screen or perform other actions
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in')),
        );
      }
    } else {
      // Handle user cancellation or other cases
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sign in to your accounts',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              // const SizedBox(height: 16.0),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     // Implement Google Sign-In functionality
              //   },
              //   icon: Icon(Icons.google), // 使用 Icons.google
              //   label: const Text('Continue with Google'),
              // ),
              const SizedBox(height: 16.0),
              const Text('or Sign in with an email'),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+65 ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final phoneNumber =
                        '+65${_phoneNumberController.text.trim()}';
                    try {
                      await _authService.verifyPhoneNumber(
                        phoneNumber,
                        context,
                      );
                      // Handle login success logic here if needed
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message ?? 'Sign-in failed'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text('Sign Up Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
