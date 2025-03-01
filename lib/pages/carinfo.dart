import 'package:flutter/material.dart';

class CarinfoPage extends StatelessWidget {
  const CarinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Info Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 기능
          },
        ),
      ),
      body: const Center(
        child: Text('This is Car Info Page.'),
      ),
    );
  }
}