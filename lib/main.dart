import 'package:flutter/material.dart';
import 'package:mini_ecommerce/screens/orders/order_history_screen.dart';
import 'package:mini_ecommerce/screens/checkout/checkout_screen.dart';
import 'package:mini_ecommerce/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'models/product_model.dart';
import 'providers/cart_providers.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrderHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final product = settings.arguments;
          if (product is! ProductModel) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('Không mở được chi tiết: thiếu dữ liệu sản phẩm'),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
