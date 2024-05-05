import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 注册新用户（邮箱+密码）
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      // Handle any errors that occur during the sign-in process
      rethrow;
    }
  }

  // 使用手机号注册新用户
  Future<UserCredential?> signUpWithPhoneNumber(
    String phoneNumber,
    BuildContext context,
  ) async {
    final completer = Completer<UserCredential?>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          completer.complete(userCredential);
        } catch (e) {
          completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        final smsCode = await promptForSmsCode(context, verificationId);
        if (smsCode != null) {
          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            final userCredential = await _auth.signInWithCredential(credential);
            completer.complete(userCredential);
          } catch (e) {
            completer.completeError(e);
          }
        } else {
          completer.completeError(Exception('No SMS code entered'));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        completer.completeError(Exception('Timeout'));
      },
    );

    return completer.future;
  }

  Future<UserCredential?> verifyPhoneNumber(
    String phoneNumber,
    BuildContext context,
  ) async {
    final completer = Completer<UserCredential?>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 自动验证完成时自动调用此回调
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          completer.complete(userCredential);
        } catch (e) {
          completer.completeError(e);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        // 验证失败
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        // 验证码已发送到用户手机，提示用户输入验证码
        final smsCode = await promptForSmsCode(context, verificationId);
        if (smsCode != null) {
          try {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            final userCredential = await _auth.signInWithCredential(credential);
            completer.complete(userCredential);
          } catch (e) {
            completer.completeError(e);
          }
        } else {
          completer.completeError(Exception('No SMS code entered'));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // 自动检索超时
        completer.completeError(Exception('Timeout'));
      },
    );

    return completer.future;
  }

  Future<String?> promptForSmsCode(
    BuildContext context,
    String verificationId,
  ) {
    TextEditingController smsCodeController = TextEditingController();
    // 显示对话框提示用户输入短信验证码
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter SMS Code'),
          content: TextField(
            autofocus: true,
            controller: smsCodeController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Optionally handle SMS code changes
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 返回输入的短信验证码
                Navigator.of(context).pop(smsCodeController.text);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signUpWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // Handle any errors that occur during the sign-up process
      rethrow;
    }
  }

// 更新用户的手机号
  Future<void> updateUserPhoneNumber(User? user, String phoneNumber) async {
    if (user != null) {
      // Verify the phone number and get the PhoneAuthCredential
      final verificationCompleter = Completer<PhoneAuthCredential>();
      await _auth.verifyPhoneNumber(
        phoneNumber: '+65$phoneNumber',
        verificationCompleted: (credential) {
          verificationCompleter.complete(credential);
        },
        verificationFailed: (e) {
          verificationCompleter.completeError(e);
        },
        codeSent: (_, __) {},
        codeAutoRetrievalTimeout: (_) {},
      );
      final phoneCredential = await verificationCompleter.future;
      await user.updatePhoneNumber(phoneCredential);
    }
  }
}
