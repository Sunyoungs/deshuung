import 'package:flutter/material.dart';
import 'pages/payments.dart';
import 'pages/favorite.dart';
import 'pages/home.dart';
import 'pages/car.dart';
import 'pages/mypage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deshuung',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const TabView(),
    );
  }
}

class TabView extends StatefulWidget {
  const TabView({super.key});
  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  int _currentIndex = 2; // 홈 페이지가 기본

  final List<Widget> _pages = const [
    PayPage(),
    FavoritePage(),
    HomePage(), // 검색창 포함
    CarPage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Deshuung'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
=======
      appBar: AppBar(title: const Text('Deshuung')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SearchBar(
          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 239, 239)),
          trailing: const [Icon(Icons.search)], hintText: "검색어를 입력하세요",
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black, // 선택된 아이템의 색
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템의 색 (여기서는 둘이 같게 함)
        type: BottomNavigationBarType.fixed, // 아이콘과 텍스트가 항상 함께 보임
>>>>>>> a9ffa703ed755f2e12114dabc1c0c656939a05df
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'pay'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'car'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'my page'),
        ],
      ),
    );
  }
}