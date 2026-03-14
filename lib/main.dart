import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các file vừa tạo
import 'screens/home/home_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'providers/cart_providers.dart';

void main() {
  runApp(
    // Bao bọc toàn bộ App bằng Provider để chia sẻ dữ liệu
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini E-commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // Thiết lập bảng điều hướng (Routing)
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const ProductDetailScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
