import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'order_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 추가

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _stores = [];
  bool _isSearching = false;
  Position? _currentPosition;

  // favorite 상태를 관리할 변수 추가
  Map<String, bool> _favoriteStatus = {};

  Future<void> _searchStores(String query) async {
    setState(() {
      _isSearching = true;
    });

    if (query.isEmpty) {
      setState(() {
        _stores.clear();
        _isSearching = false;
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance.collection('stores').get();

    setState(() {
      _stores = snapshot.docs.where((store) {
        final storeName = store['name'].toLowerCase();
        return storeName.contains(query.toLowerCase());
      }).toList();
      _isSearching = false;
    });
  }

  Future<void> _toggleFavorite(String storeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('로그인이 필요합니다.');
    return;
  }

  final userDoc = FirebaseFirestore.instance.collection('accounts').doc(user.uid);

  final userSnapshot = await userDoc.get();
  if (userSnapshot.exists) {
    Map<String, bool> favorites = Map<String, bool>.from(userSnapshot['favorite'] ?? {});

    if (favorites.containsKey(storeId)) {
      // 즐겨찾기에서 제거
      favorites.remove(storeId);
      await userDoc.update({
        'favorite': favorites,
      });
      setState(() {
        _favoriteStatus[storeId] = false; // UI 상태 업데이트
      });
    } else {
      // 즐겨찾기에 추가
      favorites[storeId] = true;
      await userDoc.update({
        'favorite': favorites,
      });
      setState(() {
        _favoriteStatus[storeId] = true; // UI 상태 업데이트
      });
    }
  }
}
  // 즐겨찾기 여부를 체크하는 함수
  bool _isFavorite(String storeId) {
    return _favoriteStatus[storeId] ?? false;
  }

  Future<List> _getUserFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.email);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      return userSnapshot['favorite'] ?? [];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매장 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색창
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "검색어를 입력하세요 (예: Starbucks)",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (text) {
                        _searchStores(text);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchStores(_searchController.text);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_currentPosition != null)
              Text(
                '현재 위치: 위도: ${_currentPosition!.latitude}, 경도: ${_currentPosition!.longitude}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (_isSearching)
              const Center(child: CircularProgressIndicator()),
            if (_stores.isEmpty && !_isSearching)
              const Center(child: Text('검색 결과가 없습니다.')),
            if (!_isSearching && _stores.isNotEmpty)
              Expanded(
                child: FutureBuilder<List>(
                  future: _getUserFavorites(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final favorites = snapshot.data!;
                    return ListView.builder(
                      itemCount: _stores.length,
                      itemBuilder: (context, index) {
                        final store = _stores[index];
                        final isFavorite = _isFavorite(store.id);

                        return ListTile(
                          title: Text(store['name']),
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              _toggleFavorite(store.id); // 즐겨찾기 토글
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(storeId: store.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
