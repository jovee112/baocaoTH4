import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';
import 'dart:ui'; // Thêm dòng này vào trên cùng của file detail_screen.dart

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- State Variables ---
  int quantity = 1;
  String selectedSize = 'M';
  String selectedColor = 'Trắng';
  bool isExpandedDescription = false;
  int _currentImageIndex = 0;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Trắng', 'Đen', 'Đỏ', 'Xanh'];
  final List<Color> colorValues = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue
  ];

  // LOGC LỌC SẠCH SẼ: Chỉ cho phép hiển thị Size/Màu với danh mục Quần áo
  bool get _shouldShowVariations {
    final category = widget.product.category.toLowerCase();
    return category.contains('clothing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Slider Ảnh & Hero Animation
                _buildImageSlider(),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Tên & Giá (Có gạch bỏ)
                      _buildHeader(),
                      const SizedBox(height: 25),

                      // 3. Khối Phân loại (Chỉ hiện nếu là quần áo)
                      if (_shouldShowVariations) _buildVariationCard(),

                      const SizedBox(height: 30),

                      // 4. Mô tả (Xem thêm/Thu gọn)
                      const Text("Mô tả sản phẩm",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildDescriptionText(),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          // 5. Bottom Bar cố định
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  // --- HÀM LOGIC TRỌNG TÂM: BOTTOM SHEET ---
  void _showSelectionSheet({bool isBuyNow = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Sheet: Ảnh nhỏ & Giá
              _buildSheetHeader(),
              const Divider(height: 30),

              // Lọc sạch sẽ: Chỉ hiện Size/Color nếu là quần áo
              if (_shouldShowVariations) ...[
                _buildSizeSelector(setSheetState),
                const SizedBox(height: 25),
                _buildColorSelector(setSheetState),
                const SizedBox(height: 25),
              ],

              // Luôn hiện Số lượng
              _buildQuantityRow(setSheetState),

              const SizedBox(height: 30),

              // Nút xác nhận logic Mua ngay / Thêm vào giỏ
              _buildConfirmButton(isBuyNow),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (ĐÃ TỐI ƯU CONST) ---

  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            // Thêm cái này để vuốt được bằng chuột trên trình duyệt
            scrollBehavior: AppScrollBehavior(),
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemCount: 3,
            itemBuilder: (context, index) {
              // Kiểm tra: Chỉ tấm ảnh đầu tiên mới dùng Hero tag
              if (index == 0) {
                return Hero(
                  tag: 'product-image-${widget.product.id}',
                  child:
                      Image.network(widget.product.image, fit: BoxFit.contain),
                );
              }
              // Các ảnh tiếp theo trả về Image bình thường, không bọc Hero
              return Image.network(widget.product.image, fit: BoxFit.contain);
            },
          ),
        ),
        const SizedBox(height: 10), // Khoảng cách nhỏ giữa ảnh và dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentImageIndex == index
                    ? Colors.black
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('\$${widget.product.price}',
                style: const TextStyle(
                    fontSize: 28,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 15),
            Text('\$${(widget.product.price * 1.5).toStringAsFixed(2)}',
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 18)),
          ],
        ),
      ],
    );
  }

  Widget _buildVariationCard() {
    return InkWell(
      onTap: () => _showSelectionSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Text("Chọn Kích cỡ, Màu sắc",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const Spacer(),
            Text("$selectedSize, $selectedColor",
                style: const TextStyle(color: Colors.red)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.description,
            maxLines: isExpandedDescription ? null : 5,
            style: const TextStyle(fontSize: 15, height: 1.5)),
        GestureDetector(
          onTap: () =>
              setState(() => isExpandedDescription = !isExpandedDescription),
          child: Text(isExpandedDescription ? "Thu gọn ▲" : "Xem thêm ▼",
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSheetHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.product.image, fit: BoxFit.contain)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$${widget.product.price}',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              if (_shouldShowVariations)
                Text('Đã chọn: $selectedColor, $selectedSize',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildSizeSelector(StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kích cỡ", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: sizes
              .map((s) => ChoiceChip(
                    label: Text(s),
                    selected: selectedSize == s,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                        color: selectedSize == s ? Colors.white : Colors.black),
                    onSelected: (val) => setSheetState(() => selectedSize = s),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector(StateSetter setSheetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Màu sắc", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 20,
          children: List.generate(
              colors.length,
              (i) => GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = colors[i]),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: selectedColor == colors[i]
                          ? Colors.red
                          : Colors.grey.shade300,
                      child: CircleAvatar(
                          radius: 16, backgroundColor: colorValues[i]),
                    ),
                  )),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(StateSetter setSheetState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              IconButton(
                  onPressed: () =>
                      setSheetState(() => quantity > 1 ? quantity-- : null),
                  icon: const Icon(Icons.remove)),
              Text('$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => setSheetState(() => quantity++),
                  icon: const Icon(Icons.add)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildConfirmButton(bool isBuyNow) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isBuyNow ? Colors.orange : Colors.red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: () {
          context.read<CartProvider>().addToCartWithSelection(
                widget.product,
                quantity: quantity,
                selectedSize: _shouldShowVariations ? selectedSize : null,
                selectedColor: _shouldShowVariations ? selectedColor : null,
              );
          Navigator.pop(context);
          if (isBuyNow) {
            Navigator.pushNamed(context, '/cart');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã thêm thành công!'),
                backgroundColor: Colors.green));
          }
        },
        child: Text(isBuyNow ? "MUA NGAY" : "XÁC NHẬN",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))
      ]),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 28)),
          const SizedBox(width: 5),
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              icon: const Icon(Icons.shopping_cart_outlined, size: 28)),
          const SizedBox(width: 15),
          Expanded(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => _showSelectionSheet(isBuyNow: false),
            child: const Text("THÊM VÀO GIỎ",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(width: 10),
          Expanded(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => _showSelectionSheet(isBuyNow: true),
            child: const Text("MUA NGAY",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }
}

// Class chuẩn để fix lỗi vuốt chuột trên Web/Edge
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // Sửa thành dòng này
        PointerDeviceKind.trackpad,
      };
}
