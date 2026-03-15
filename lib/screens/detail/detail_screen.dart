import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ===== STATE VARIABLES =====
  late int currentImageIndex;
  bool isExpandedDescription = false;
  
  // BottomSheet selection
  String selectedSize = 'M';
  String selectedColor = 'Đen';
  int quantity = 1;
  
  // Constants
  final List<String> sizes = ['S', 'M', 'L'];
  final List<String> colors = ['Đen', 'Trắng', 'Đỏ', 'Xanh'];
  final List<Color> colorValues = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
  ];
  
  // Mock images list (khi backend không cung cấp multiple images)
  late List<String> productImages;

  @override
  void initState() {
    super.initState();
    currentImageIndex = 0;
    // Tạo danh sách ảnh từ ảnh chính (lặp lại nếu chỉ có 1 ảnh)
    productImages = [
      widget.product.image,
      widget.product.image,
      widget.product.image,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết sản phẩm"),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== IMAGE SLIDER + HERO =====
                _buildImageSlider(),
                
                // ===== PRODUCT INFO =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductTitle(),
                      const SizedBox(height: 12),
                      _buildRatingSection(),
                      const SizedBox(height: 16),
                      _buildPriceSection(),
                      const SizedBox(height: 16),
                      _buildDescriptionSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ===== BOTTOM BAR =====
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  // ===== 1. IMAGE SLIDER + HERO EFFECT =====
  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() => currentImageIndex = index);
            },
            itemCount: productImages.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product-${widget.product.id}',
                child: GestureDetector(
                  onTap: () {
                    // Có thể mở full screen image viewer
                  },
                  child: Container(
                    color: Colors.grey[100],
                    child: Image.network(
                      productImages[index],
                      fit: BoxFit.contain,
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
        // Slider indicator dots
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

  // ===== 2. PRODUCT TITLE + CATEGORY =====
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

  // ===== 3. RATING SECTION =====
  Widget _buildRatingSection() {
    final rate = widget.product.rate ?? 0.0;
    final count = widget.product.count ?? 0;

    return Row(
      children: [
        // Stars
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

  // ===== 4. PRICE SECTION =====
  Widget _buildPriceSection() {
    final currentPrice = widget.product.price;
    final originalPrice = (currentPrice * 1.3).toStringAsFixed(0); // Mock giá gốc
    final discount =
        ((1 - (currentPrice / double.parse(originalPrice))) * 100).toInt();

    return Row(
      children: [
        // Giá hiện tại
        Text(
          '${currentPrice.toStringAsFixed(0)}₫',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        // Giá gốc gạch ngang
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${originalPrice}₫',
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
            // Discount badge
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

  // ===== 5. DESCRIPTION WITH EXPAND/COLLAPSE =====
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
            maxLines: 3,
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

  // ===== 6. BOTTOM BAR (2 BUTTONS) =====
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
          // Thêm vào giỏ
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showAddToCartBottomSheet(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thêm vào giỏ',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mua ngay
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng Mua ngay sẽ được cập nhật')),
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

  // ===== 7. BOTTOM SHEET - SELECT SIZE, COLOR, QUANTITY =====
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
                    // Title
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

                    // ===== SIZE SELECTION =====
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
                                color: isSelected ? Colors.red : Colors.grey[300]!,
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

                    // ===== COLOR SELECTION =====
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
                                    color: isSelected ? Colors.red : Colors.grey[300]!,
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

                    // ===== QUANTITY SELECTION =====
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
                          // Nút giảm
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
                          // Số lượng
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
                          // Nút tăng
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

                    // ===== CONFIRM BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Update state
                          setState(() {
                            selectedSize = tempSelectedSize;
                            selectedColor = tempSelectedColor;
                            quantity = tempQuantity;
                          });

                          // Get CartProvider
                          final cartProvider =
                              context.read<CartProvider>();

                          // Add to cart
                          cartProvider.addToCart(widget.product);

                          Navigator.pop(context);

                          // Show success SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã thêm $tempQuantity x ${widget.product.title} vào giỏ',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Xem giỏ',
                                textColor: Colors.white,
                                onPressed: () {
                                  // Navigate to cart screen
                                  // Navigator.pushNamed(context, '/cart');
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
