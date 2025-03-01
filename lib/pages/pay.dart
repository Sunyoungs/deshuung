import 'package:flutter/material.dart';
import 'paycard.dart';

class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('가상 카드 등록'),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaycardPage()), 
            );
          },
        )
      ),
    );
  }
}