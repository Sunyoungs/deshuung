import 'package:flutter/material.dart';
import 'car.dart';

class CarinfoPage extends StatelessWidget {
  const CarinfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('my 차량 정보', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 5),
              const Chip(
                label: Text('🔒 차량 정보 안전하게 보호 중',
                    style: TextStyle(fontSize: 12)),
                backgroundColor: Color.fromARGB(255, 234, 234, 234),
              ),
              const SizedBox(height: 20),
              Image.network('https://cdn.insightkorea.co.kr/news/photo/202107/90394_86238_3429.jpg',
                  height: 300),
              const SizedBox(height: 20),
              const Text('62자 2643',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CarPage()),
                  );
                },
                child: const Text(
                  '현재 탑승 중인 차량이 아니신가요?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
