import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 임포트
import 'package:deshuung/pages/login.dart'; // 로그인 페이지 임포트
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoggingIn = false; // 로그인 여부 확인
  String errorMessage = ''; // 에러 메시지 저장

  @override
  Widget build(BuildContext context) {
    // 로그인 상태 확인
    User? user = FirebaseAuth.instance.currentUser;

    // 로그인 상태가 아니라면 로그인 페이지로 이동 (로그인 폼 표시)
    if (user == null && !isLoggingIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoggingIn = true;
                    errorMessage = ''; // 초기화
                  });

                  try {
                    // Firebase 로그인 시도
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);

                    // 로그인 성공 시 MyPage로 이동
                    if (userCredential.user != null) {
                      setState(() {
                        isLoggingIn = false;
                      });
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      isLoggingIn = false;
                      // FirebaseAuthException의 오류 코드에 따라 에러 메시지 처리
                      if (e.code == 'user-not-found') {
                        errorMessage = '회원가입된 사용자가 아닙니다.';
                      } else if (e.code == 'wrong-password') {
                        errorMessage = '잘못된 비밀번호입니다.';
                      } else if (e.code == 'invalid-email') {
                        errorMessage = '잘못된 이메일 형식입니다.';
                      } else if (e.code == 'network-request-failed') {
                        errorMessage = '네트워크에 문제가 발생했습니다. 다시 시도해주세요.';
                      } else {
                        errorMessage = '로그인 실패: ${e.message}';
                      }
                    });
                  }
                },
                child: const Text('Login'),
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (isLoggingIn) const CircularProgressIndicator(),
              // 회원가입 버튼 추가
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('accounts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var account = data[index].data();
              return ListTile(
                title: Text(account['name']),
                subtitle: Text(account['email']),
              );
            },
          );
        },
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRegistering = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isRegistering = true;
                  errorMessage = '';
                });

                try {
                  // Firebase 회원가입 시도
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text);

                  if (userCredential.user != null) {
                    setState(() {
                      isRegistering = false;
                    });
                    Navigator.pop(context); // 회원가입 후 로그인 화면으로 돌아가기
                  }
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    isRegistering = false;
                    if (e.code == 'email-already-in-use') {
                      errorMessage = '이 이메일은 이미 사용 중입니다.';
                    } else if (e.code == 'invalid-email') {
                      errorMessage = '잘못된 이메일 형식입니다.';
                    } else if (e.code == 'weak-password') {
                      errorMessage = '비밀번호는 6자 이상이어야 합니다.';
                    } else {
                      errorMessage = '회원가입 실패: ${e.message}';
                    }
                  });
                }
              },
              child: const Text('회원가입'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (isRegistering) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
