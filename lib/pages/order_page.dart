import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {
  final String storeId;

  const OrderPage({super.key, required this.storeId});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  late Future<DocumentSnapshot> _storeDetails;
  List<String> _selectedMenu = [];

  @override
  void initState() {
    super.initState();
    // storeId를 사용하여 해당 매장의 상세 정보를 가져옴
    _storeDetails = FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .get(); // 매장 정보 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주문 페이지')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _storeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('매장 정보를 찾을 수 없습니다.'));
          }

          final store = snapshot.data!;
          // menu 필드가 List로 존재하는지 확인하고 List<Map<String, dynamic>>로 변환
          List<Map<String, dynamic>> menu = [];
          if (store['menu'] is List) {
            menu = List<Map<String, dynamic>>.from(store['menu']);
          } else {
            menu = [];
            print("Menu is not a list.");
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('메뉴 선택', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: menu.length,
                    itemBuilder: (context, index) {
                      final menuItem = menu[index];
                      return CheckboxListTile(
                        title: Text(menuItem['name']), // 메뉴 이름
                        subtitle: Text('${menuItem['price']} 원'), // 가격
                        value: _selectedMenu.contains(menuItem['name']),
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedMenu.add(menuItem['name']);
                            } else {
                              _selectedMenu.remove(menuItem['name']);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 선택한 메뉴 확인
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('선택한 메뉴'),
                        content: Text(_selectedMenu.join('\n')),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('선택한 메뉴 확인'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}