import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'order.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _stores = [];
  bool _isSearching = false;
  Position? _currentPosition;
  //List<DocumentSnapshot> _nearbyDT = [];
  List<Map<String, dynamic>> _nearbyDT = [];

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

  /*Future<void> _getNearDT() async {
    if (_currentPosition == null) return;
    final snapshot = await FirebaseFirestore.instance.collection('stores').where('hasDriveThru', isEqualTo: true).get();
    setState(() {
      _nearbyDT = snapshot.docs;
    });
  }*/

  // 미리 정의된 데이터 사용
  void _loadMockData() {
    _nearbyDT = [
      {'name': '이디야 00점', 'id': 'ediya1'},
      {'name': '스타벅스 DT 0000점', 'id': 'starbucks1'},
      {'name': '컴포즈 0000점 ', 'id': 'compose1'},
    ];
  }

  // Firebase에서 데이터를 가져오는 대신 미리 정의된 데이터를 사용하도록 수정
  Future<void> _getNearDT() async {
    _loadMockData();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) => _getNearDT());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매장 검색'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      //backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        hintText: "검색어를 입력하세요",
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
            const Text(
              '근처 매장 DT',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _nearbyDT.length,
                itemBuilder: (context, index) {
                  final store = _nearbyDT[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    color: const Color(0xFFF5F5F5),
                    /*shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                        bottom: Radius.circular(20),
                      ),
                    ),*/
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    store['name'] ?? '이름 없음',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.favorite_border, color: Color.fromARGB(255, 0, 0, 0), size: 16),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderPage(storeId: store['id']),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '주문하기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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