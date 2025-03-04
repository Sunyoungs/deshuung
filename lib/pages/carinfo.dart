import 'package:flutter/material.dart';

List<String> caritems = ['등록된 차량 1', '등록된 차량 2'];

class CarinfoPage extends StatelessWidget {
  const CarinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite List'),
      ),
      body: ListView.builder(
        itemCount: caritems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
            child: Card(
              elevation: 3,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
              ),
              child: ListTile(
                title: Text(caritems[index]),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}