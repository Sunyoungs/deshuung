import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/pay.dart';
import 'pages/favorite.dart';
import 'pages/home.dart';
import 'pages/car.dart';
import 'pages/mypage.dart';  // MyPage 위젯을 사용하기 위해 import
import 'pages/carinfo.dart';
import 'pages/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  int _currentIndex = 2;
  bool _isLoggedIn = false;  // 로그인 상태 관리

  // 페이지 목록
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 로그인 상태 초기화
    _isLoggedIn = false; // 로그인 상태를 가져오는 로직을 여기에 추가할 수 있습니다.

    // 페이지 목록 초기화
    _pages = [
      PayPage(),
      FavoritePage(userEmail: _isLoggedIn ? 'example@email.com' : null),
      HomePage(),
      CarPage(),
      MyPage(),  // 로그인 상태 관리 MyPage로 변경
    ];
  }

  void _showSlidingbottom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CarinfoPage(),
    );
  }

  void _showAlertBanner(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [const BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deshuung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_important),
            onPressed: () => _showAlertBanner(context, '차량 GPS와 핸드폰 GPS의 오차가 15M를 벗어났습니다.'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => _showSlidingbottom(context),
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