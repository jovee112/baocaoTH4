import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  String? _profileAddress;
  String _paymentMethod = 'COD';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileAddress();
  }

  Future<void> _loadProfileAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null &&
        data['address'] != null &&
        data['address'].toString().isNotEmpty) {
      _profileAddress = data['address'];
      _addressController.text = _profileAddress!;
    }
  }

  void _placeOrder(List<CartItem> selectedItems, double totalPrice) async {
    if (_addressController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng!')),
        );
      }
      return;
    }
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final address = _addressController.text.trim();

    // Nếu địa chỉ mới khác địa chỉ profile, lưu lại vào Firestore
    if (user != null && (address.isNotEmpty && address != _profileAddress)) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'address': address,
      }, SetOptions(merge: true));
    }

    final orderData = {
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'pending',
      'products': selectedItems
          .map((e) => {
                'id': e.product.id,
                'title': e.product.title,
                'quantity': e.quantity,
                'price': e.product.price,
              })
          .toList(),
      'address': address,
      'payment': _paymentMethod,
      'total': totalPrice,
      'userId': user?.uid,
      'userEmail': user?.email,
    };

    try {
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).removeSelectedItems();
        setState(() => _loading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Đặt hàng thành công!'),
            content: const Text('Đơn hàng của bạn đã được ghi nhận.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      // Xử lý lỗi nếu cần
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final selectedItems =
        cartProvider.items.where((item) => item.isSelected).toList();
    final totalPrice = cartProvider.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).pushNamed('/profile');
              } else if (value == 'orders') {
                Navigator.of(context).pushNamed('/orders');
              } else if (value == 'logout') {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'profile', child: Text('Thông tin tài khoản')),
              const PopupMenuItem(value: 'orders', child: Text('Đơn mua')),
              const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Địa chỉ nhận hàng:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _addressController,
              decoration:
                  const InputDecoration(hintText: 'Nhập địa chỉ của bạn'),
            ),
            const SizedBox(height: 16),
            const Text('Sản phẩm đã chọn:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (ctx, i) {
                  final item = selectedItems[i];
                  return ListTile(
                    leading: Image.network(item.product.image,
                        width: 40, height: 40),
                    title: Text(item.product.title),
                    subtitle: Text('SL: ${item.quantity}'),
                    trailing: Text(
                        '${(item.product.price * item.quantity).toStringAsFixed(2)}₫'),
                  );
                },
              ),
            ),
            const Divider(),
            const Text('Phương thức thanh toán:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<String>(
                  value: 'COD',
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                const Text('COD'),
                Radio<String>(
                  value: 'Momo',
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                const Text('Momo'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${totalPrice.toStringAsFixed(2)}₫',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading || selectedItems.isEmpty
                    ? null
                    : () => _placeOrder(selectedItems, totalPrice),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Đặt Hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
