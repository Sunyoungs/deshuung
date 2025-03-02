// lib/pages/signup.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';  // auth_service.dart를 import

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void _signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String name = nameController.text;

    // 회원가입 처리 함수 호출
    await registerUser(email, password, name);

    // 회원가입 후 로그인 페이지로 이동하거나 다른 작업 수행
    Navigator.pop(context);  // 예시로 회원가입 후 이전 페이지로 돌아갑니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
