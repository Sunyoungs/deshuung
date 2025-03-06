import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'signup.dart';  // 회원가입 페이지로 이동하기 위한 import

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  bool isLoggedIn = false; // 로그인 상태
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signIn() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  try {
    // Firebase Authentication을 통한 로그인
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore에서 이메일 기반으로 사용자 찾기
    QuerySnapshot userSnapshot = await _firestore
        .collection('accounts')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 성공')),
      );
      setState(() {
        isLoggedIn = true;
      });
    } else {
      _showErrorDialog('등록된 사용자 정보가 없습니다.');
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      _showErrorDialog('등록된 이메일이 없습니다.');
    } else if (e.code == 'wrong-password') {
      _showErrorDialog('잘못된 비밀번호입니다.');
    } else {
      _showErrorDialog('오류 발생: ${e.message}');
    }
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoggedIn
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('로그인 상태'),
                    SizedBox(height: 16),
                    Text('여기서 로그아웃 기능을 추가할 수 있습니다.'), 
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: Text('로그인'),
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      // 회원가입 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text('회원가입'),
                  ),
                ],
              ),
      ),
    );
  }
}
