import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final price = widget.product.price;
        final total = price * quantity;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thanh toán mua ngay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sản phẩm: ' + widget.product.title),
              if (_isClothing) ...[
                Text('Kích cỡ: ' + size),
                Text('Màu sắc: ' + color),
              ],
              Text('Số lượng: ' + quantity.toString()),
              Text('Đơn giá: ' + '4' + price.toStringAsFixed(2)),
              Text('Tổng tiền: ' + '4' + total.toStringAsFixed(2)),
              const SizedBox(height: 16),
              const Text('Nhập thông tin giao hàng:'),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel, do not save anything
              },
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();
                if (address.isEmpty || phone.isEmpty || phone.length < 9) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đầy đủ thông tin hợp lệ!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                // Tạo đơn hàng tạm thời (chưa lưu vào giỏ)
                final order = {
                  'productId': widget.product.id,
                  'title': widget.product.title,
                  'size': _isClothing ? size : null,
                  'color': _isClothing ? color : null,
                  'quantity': quantity,
                  'address': address,
                  'phone': phone,
                  'price': '4' + price.toStringAsFixed(2),
                  'total': '4' + total.toStringAsFixed(2),
                  'timestamp': DateTime.now().toIso8601String(),
                };
                // TODO: Gửi order lên server hoặc Firestore
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Đặt mua ngay thành công!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Thanh toán'),
            ),
          ],
        );
      },
    );
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => currentImageIndex = index);
            },
            itemCount: productImages.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product-image-${widget.product.id}',
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.grey[100],
                    child: Image.network(
                      productImages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (productImages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                productImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentImageIndex == index ? 12 : 8,
                  height: currentImageIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex == index
                        ? Colors.red
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.category.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final rate = widget.product.rate ?? 0.0;
    final count = widget.product.count ?? 0;

    return Row(
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rate.toInt() ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${rate.toStringAsFixed(1)} ⭐',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(
          '($count lượt)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final currentPrice = widget.product.price;
    final originalPrice = currentPrice * 1.3;
    final discount = ((1 - (currentPrice / originalPrice)) * 100).toInt();

    return Row(
      children: [
        Text(
          '\$${currentPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '\$${originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                Container(
                  height: 1,
                  width: 40,
                  color: Colors.grey[500],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-$discount%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô tả sản phẩm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product.description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          secondChild: Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          crossFadeState: isExpandedDescription
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() => isExpandedDescription = !isExpandedDescription);
          },
          child: Text(
            isExpandedDescription ? 'Thu gọn' : 'Xem thêm',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariationSection() {
    return InkWell(
      onTap: () => _showAddToCartBottomSheet(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _isClothing
                    ? 'Chọn Kích cỡ, Màu sắc'
                    : 'Chọn số lượng sản phẩm',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    tooltip: 'Chat',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng Chat sẽ được cập nhật'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    tooltip: 'Giỏ hàng',
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showAddToCartBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thêm vào giỏ hàng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đang phát triển'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Mua ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartBottomSheet(BuildContext context) {
    String tempSelectedSize = selectedSize;
    String tempSelectedColor = selectedColor;
    int tempQuantity = quantity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chọn tùy chọn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isClothing) ...[
                      const Text(
                        'Kích thước',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: sizes.map((size) {
                          final isSelected = tempSelectedSize == size;
                          return GestureDetector(
                            onTap: () {
                              setStateSheet(() => tempSelectedSize = size);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                color: isSelected
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Màu sắc',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: List.generate(colors.length, (index) {
                          final color = colors[index];
                          final colorValue = colorValues[index];
                          final isSelected = tempSelectedColor == color;

                          return GestureDetector(
                            onTap: () {
                              setStateSheet(() => tempSelectedColor = color);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorValue,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.grey[300]!,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  color,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const Text(
                      'Số lượng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: tempQuantity > 1
                                ? () {
                                    setStateSheet(() => tempQuantity--);
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.remove,
                                size: 20,
                                color: tempQuantity > 1
                                    ? Colors.black
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                tempQuantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: tempQuantity < 10
                                ? () {
                                    setStateSheet(() => tempQuantity++);
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: tempQuantity < 10
                                    ? Colors.black
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedSize = tempSelectedSize;
                            selectedColor = tempSelectedColor;
                            quantity = tempQuantity;
                          });

                          final cartProvider =
                              Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addToCartWithSelection(
                            widget.product,
                            quantity: tempQuantity,
                            selectedSize: _isClothing ? tempSelectedSize : null,
                            selectedColor:
                                _isClothing ? tempSelectedColor : null,
                          );

                          Navigator.pop(context);
                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isClothing
                                    ? 'Đã thêm $tempQuantity x ${widget.product.title} (Size: $tempSelectedSize, Màu: $tempSelectedColor) vào giỏ'
                                    : 'Đã thêm $tempQuantity x ${widget.product.title} vào giỏ',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Xem giỏ',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.of(
                                    this.context,
                                    rootNavigator: true,
                                  ).pushNamed('/cart');
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

  // Buy Now logic and dead code removed

