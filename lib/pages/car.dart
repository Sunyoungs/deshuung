import 'package:flutter/material.dart';

List<String> items = ['차량 1', '차량 2', '차량 3', '차량 4', '이거근데DB에서가져와야되죠'];
List<String> itemContents = ['차량', '차량', '차량', '차량', '어렵다'];

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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
            child: Card(
              elevation: 3,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
              ),
              child: ListTile(
                title: Text(items[index]),
                onTap: () => cardClickEvent(context, index),
              ),
            ),
          );
        }
      )
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
        title: Text('Car List'),
      ),
      body: Center(
        child: Text(content),
      ),
    );
  }
}