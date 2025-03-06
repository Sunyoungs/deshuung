import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritePage extends StatelessWidget {
  final String? userEmail; // 이메일이 null일 수도 있음
  const FavoritePage({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
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
            return const Center(child: Text('즐겨찾기 목록이 비어 있습니다.'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> favorites = List<String>.from(userData['favorite'] ?? []);

          if (favorites.isEmpty) {
            return const Center(child: Text('즐겨찾기한 매장이 없습니다.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(favorites[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
