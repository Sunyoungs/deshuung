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

  void _showFullScreenBottomSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const carinfoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deshuung'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFullScreenBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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

class carinfoPage extends StatelessWidget {
  const carinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 차 정보 페이지지')),
      body: const Center(child: Text('내차정보')),
    );
  }
}
