import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 관련 import 추가
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
  String? _userEmail;  // 사용자 이메일을 저장하는 변수

  // 페이지 목록
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // 로그인 상태 초기화 (예시로 true로 설정, 실제 로그인 상태 관리 필요)
    _isLoggedIn = true;  

    // Firestore에서 사용자 이메일을 가져옴
    _getUserEmail().then((email) {
      setState(() {
        _userEmail = email; // Firestore에서 이메일 가져오기
      });
    });

    // 페이지 목록 초기화
    _pages = [
      PayPage(),
      FavoritePage(),  // 로그인 상태에 따라 email 전달
      HomePage(),
      CarPage(),
      MyPage(),  // 로그인 상태 관리 MyPage로 변경
    ];
  }

  // Firestore에서 이메일을 가져오는 함수
  Future<String?> _getUserEmail() async {
    // Firestore에서 현재 사용자의 이메일을 가져오는 로직
    var userSnapshot = await FirebaseFirestore.instance
        .collection('accounts')  // 사용자 정보를 저장한 'accounts' 컬렉션
        .doc('userID')  // 사용자 ID로 문서 조회, 실제로는 로그인된 사용자의 ID를 가져와야 함
        .get();

    if (userSnapshot.exists) {
      return userSnapshot.data()?['email'];  // 이메일 반환
    } else {
      return null;  // 이메일을 찾을 수 없을 경우 null 반환
    }
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
        title: const Text('드슝', style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: const Icon(Icons.car_crash),
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