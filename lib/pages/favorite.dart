import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritePage extends StatelessWidget {
  final String? userEmail; // 이메일이 null일 수도 있음
  const FavoritePage({super.key, this.userEmail});

  // 즐겨찾기 추가 및 삭제 함수
  Future<void> toggleFavorite(String storeName) async {
    if (userEmail == null) return;

    // Firestore에서 사용자 문서를 참조
    var userRef = FirebaseFirestore.instance.collection('users').doc(userEmail);

    // 사용자 문서 가져오기
    var userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      var userData = userSnapshot.data() as Map<String, dynamic>;
      List<String> favorites = List<String>.from(userData['favorite'] ?? []);

      // 즐겨찾기 배열에 매장이 없으면 추가하고, 있으면 제거
      if (favorites.contains(storeName)) {
        favorites.remove(storeName);
      } else {
        favorites.add(storeName);
      }

      // Firestore에 업데이트
      await userRef.update({
        'favorite': favorites,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // userEmail이 null이면 로그인 안 된 상태이므로 "로그인 해주세요" 출력
    if (userEmail == null) {
      return const Center(
        child: Text(
          '로그인을 해주세요.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite List'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userEmail).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('사용자 데이터를 불러오는 중입니다.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> favorites = List<String>.from(userData['favorite'] ?? []);

          if (favorites.isEmpty) {
            return const Center(child: Text('즐겨찾기한 매장이 없습니다.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              String storeName = favorites[index];
              bool isFavorite = favorites.contains(storeName);

              return Card(
                child: ListTile(
                  title: Text(storeName), // 즐겨찾기 매장 이름 표시
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      toggleFavorite(storeName);  // 하트 버튼 클릭 시 이벤트
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
