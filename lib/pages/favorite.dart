import 'package:flutter/material.dart';
import 'order.dart';

List<String> resitems = ['식당 1', '식당 2', '식당 3', '식당 4'];

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  void cardClickEvent(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite List'),
      ),
      body: ListView.builder(
        itemCount: resitems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
            child: Card(
              elevation: 3,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.elliptical(10, 10)),
              ),
              child: ListTile(
                title: Text(resitems[index]),
                onTap: () => cardClickEvent(context, index),
              ),
            ),
          );
        }
      )
    );
  }
}