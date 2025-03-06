import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'order_page.dart'; // 주문 페이지를 import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _stores = [];
  bool _isSearching = false;
  Position? _currentPosition;  // 위치 정보를 저장할 변수

  // Firestore에서 매장을 검색하는 함수
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

    // Firestore에서 stores 컬렉션 가져오기
    final snapshot = await FirebaseFirestore.instance.collection('stores').get();

    setState(() {
      _stores = snapshot.docs.where((store) {
        final storeName = store['name'].toLowerCase();
        return storeName.contains(query.toLowerCase()); // 대소문자 구분 없이 검색
      }).toList();
      _isSearching = false;
    });
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // 페이지 초기화 시 위치 정보 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매장 검색'),
      ),
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

            // 현재 위치 정보 표시
            if (_currentPosition != null)
              Text(
                '현재 위치: 위도: ${_currentPosition!.latitude}, 경도: ${_currentPosition!.longitude}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),

            // 검색 결과 및 로딩 인디케이터
            if (_isSearching)
              const Center(child: CircularProgressIndicator()),
            if (_stores.isEmpty && !_isSearching)
              const Center(child: Text('검색 결과가 없습니다.')),
            if (!_isSearching && _stores.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _stores.length,
                  itemBuilder: (context, index) {
                    final store = _stores[index];
                    return ListTile(
                      title: Text(store['name']),
                      onTap: () {
                        // 매장 클릭 시 해당 매장의 주문 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(storeId: store.id),
                          ),
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