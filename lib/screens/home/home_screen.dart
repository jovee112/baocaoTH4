import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TH4 - Nhóm 4")),
      body: const Center(child: Text("Màn hình Trang chủ")),
    );
  }
}
