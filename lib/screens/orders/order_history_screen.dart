import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user?.uid)
        .get();
    orders = snapshot.docs.map((doc) {
      final data = doc.data();
      OrderStatus status;
      switch (data['status']) {
        case 'pending':
          status = OrderStatus.pending;
          break;
        case 'shipping':
          status = OrderStatus.shipping;
          break;
        case 'delivered':
          status = OrderStatus.delivered;
          break;
        case 'cancelled':
          status = OrderStatus.cancelled;
          break;
        default:
          status = OrderStatus.pending;
      }
      return Order(
        id: doc.id,
        status: status,
        products: (data['products'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        address: data['address'] ?? '',
        payment: data['payment'] ?? '',
        total: (data['total'] ?? 0).toDouble(),
        createdAt: data['createdAt'] ?? '',
      );
    }).toList();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchOrders,
                child: TabBarView(
                  children: [
                    OrderList(
                      orders
                          .where((o) => o.status == OrderStatus.pending)
                          .toList(),
                      onOrderChanged: _fetchOrders,
                    ),
                    OrderList(
                      orders
                          .where((o) => o.status == OrderStatus.shipping)
                          .toList(),
                      onOrderChanged: _fetchOrders,
                    ),
                    OrderList(
                      orders
                          .where((o) => o.status == OrderStatus.delivered)
                          .toList(),
                      onOrderChanged: _fetchOrders,
                    ),
                    OrderList(
                      orders
                          .where((o) => o.status == OrderStatus.cancelled)
                          .toList(),
                      onOrderChanged: _fetchOrders,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

enum OrderStatus { pending, shipping, delivered, cancelled }

class Order {
  final String id;
  final OrderStatus status;
  final List<Map<String, dynamic>> products;
  final String address;
  final String payment;
  final double total;
  final String createdAt;

  Order({
    required this.id,
    required this.status,
    required this.products,
    required this.address,
    required this.payment,
    required this.total,
    required this.createdAt,
  });
}

class OrderList extends StatelessWidget {
  final List<Order> orders;
  final VoidCallback? onOrderChanged;
  const OrderList(this.orders, {this.onOrderChanged, super.key});

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final TextEditingController reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận huỷ đơn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn huỷ đơn hàng này?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do huỷ đơn',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Huỷ đơn'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'cancelled',
        'cancelReason': reasonController.text.trim(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã huỷ đơn hàng!')),
      );
      onOrderChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng nào.'));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text('Đơn #${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày: ${order.createdAt}'),
                Text('Địa chỉ: ${order.address}'),
                Text('Thanh toán: ${order.payment}'),
                Text('Tổng tiền: ${order.total}₫'),
                _statusText(order.status),
                if (order.status == OrderStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _cancelOrder(context, order.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 36),
                      ),
                      child: const Text('Huỷ đơn'),
                    ),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chi tiết sản phẩm:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...order.products.map((prod) => ListTile(
                          title: Text(prod['title']),
                          subtitle: Text(
                              'SL: ${prod['quantity']} - Giá: ${prod['price']}₫'),
                        )),
                    if (order.status == OrderStatus.cancelled)
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('orders')
                            .doc(order.id)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final data = snapshot.data!.data();
                          final reason = data?['cancelReason'] ?? '';
                          if (reason.isEmpty) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Lý do huỷ: $reason',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500)),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Text('Chờ xác nhận',
            style: TextStyle(color: Colors.orange));
      case OrderStatus.shipping:
        return const Text('Đang giao', style: TextStyle(color: Colors.blue));
      case OrderStatus.delivered:
        return const Text('Đã giao', style: TextStyle(color: Colors.green));
      case OrderStatus.cancelled:
        return const Text('Đã hủy', style: TextStyle(color: Colors.red));
      default:
        return const Text('Chờ xác nhận');
    }
  }
}
