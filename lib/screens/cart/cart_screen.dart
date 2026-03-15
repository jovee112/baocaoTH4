import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_providers.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<bool> _confirmRemoveItem(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa sản phẩm'),
          content:
              const Text('Bạn có muốn xóa sản phẩm này khỏi giỏ hàng không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _buildVariantText(CartItem item) {
    final hasSize = item.selectedSize != null && item.selectedSize!.isNotEmpty;
    final hasColor =
        item.selectedColor != null && item.selectedColor!.isNotEmpty;

    if (hasSize && hasColor) {
      return 'Size ${item.selectedSize} / Màu ${item.selectedColor}';
    }
    if (hasSize) {
      return 'Size ${item.selectedSize}';
    }
    if (hasColor) {
      return 'Màu ${item.selectedColor}';
    }
    return 'Mặc định';
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Giỏ hàng")),
      body: cartProvider.items.isEmpty
          ? const Center(
              child: Text(
                'Giỏ hàng đang trống',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                final product = item.product;
                final itemKey =
                    '${product.id}-${item.selectedSize ?? '-'}-${item.selectedColor ?? '-'}';

                return Dismissible(
                  key: ValueKey(itemKey),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    cartProvider.removeFromCartByVariant(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã xóa ${product.title}')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: item.isSelected,
                            onChanged: (value) {
                              if (value != null && value != item.isSelected) {
                                cartProvider.toggleItemSelectionByVariant(item);
                              }
                            },
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phân loại: ${_buildVariantText(item)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đơn giá: \$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        if (item.quantity == 1) {
                                          final isConfirmed =
                                              await _confirmRemoveItem(
                                            context,
                                          );
                                          if (!isConfirmed) {
                                            return;
                                          }
                                        }

                                        cartProvider.updateQuantityByVariant(
                                          item,
                                          item.quantity - 1,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        cartProvider.updateQuantityByVariant(
                                          item,
                                          item.quantity + 1,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                value: cartProvider.isAllSelected,
                onChanged: cartProvider.items.isEmpty
                    ? null
                    : (value) {
                        cartProvider.toggleAll(value ?? false);
                      },
              ),
              const Text('Chọn tất cả'),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tổng thanh toán'),
                  Text(
                    '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: cartProvider.totalPrice <= 0 ? null : () {},
                child: const Text('Thanh toán'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
