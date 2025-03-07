import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'order.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> _favorite = [];

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  void _loadFavorite() {
    _favorite = [
      {'name': '스타벅스 00점', 'id': 'starbucks1'},
      {'name': '이디야 00점', 'id': 'ediya1'},
      {'name': '투썸플레이스 00점', 'id': 'twosome1'},
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주가는 가게'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _favorite.length,
                itemBuilder: (context, index) {
                  final store = _favorite[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    color: const Color(0xFFF5F5F5),
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
                                  const Icon(Icons.favorite, color: Colors.red, size: 16)
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderPage(storeId: store['id'])
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