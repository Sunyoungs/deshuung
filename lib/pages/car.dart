import 'package:flutter/material.dart';

List<String> items = ['관심 매장 1', '관심 매장 2', '관심 매장 3', '관심 매장 4', '이거근데DB에서가져와야되죠'];
List<String> itemContents = ['공릉동 스타벅스', '묵동 이디야', '태릉입구 스타벅스', '컴포즈서울여대점', '어렵다'];

class CarPage extends StatelessWidget {
  const CarPage({super.key});

  void cardClickEvent(BuildContext context, int index) {
    String content = itemContents[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentPage(content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car List'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.elliptical(10, 10))
            ),
            child: ListTile(
              title: Text(items[index]),
              onTap: () => cardClickEvent(context, index),
            ),
          );
        },
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  final String content;
  const ContentPage({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content'),
      ),
      body: Center(
        child: Text(content),
      ),
    );
  }
}