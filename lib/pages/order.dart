import 'package:flutter/material.dart';
import 'payment.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 기능
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('결제 페이지로 이동'),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentPage()),
            );
          },
        )
      ),
    );
  }
}