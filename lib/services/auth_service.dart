// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> registerUser(String email, String password, String name) async {
  try {
    // Firebase Authentication을 사용하여 사용자 등록
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore에 사용자 정보 추가
    await FirebaseFirestore.instance.collection('accounts').doc(userCredential.user?.uid).set({
      'createdAt': FieldValue.serverTimestamp(),
      'email': email,
      'name': name,
      'password': password,  // 암호는 보안상 다른 방법으로 저장하는 것이 좋습니다.
      'paymentMethods': [],  // 기본값으로 빈 리스트 (추후 추가할 결제 수단 정보)
      'registeredCars': [],  // 기본값으로 빈 리스트 (추후 추가할 차량 정보)
      'favorite': []
    });
  } catch (e) {
    print('Error registering user: $e');
  }
}