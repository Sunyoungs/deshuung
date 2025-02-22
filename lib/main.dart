import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),
      home: const TabView(),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Screen"),
      ),
      body: const Center(
        child: Text("This is the Search Screen."),
      ),
    );
  }
}

class TabView extends StatefulWidget {
  const TabView({super.key});
  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with SingleTickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {setState(() {_index = _tabController.index;});});
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onTap: (int index) {
          _tabController.animateTo(index);
        },
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'pay'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'my favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'my car'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'my page'),
        ],
      ),
      /*child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          PayPage(),
          FavoritePage(),
          HomePage(),
          CarPage(),
          PagePage(),
        ],
      ),*/
    );
  }
}