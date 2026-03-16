import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  bool isSelected; // THÊM: Trạng thái tick chọn để tính tiền
  String? selectedSize; // THÊM: Kích thước được chọn (S, M, L)
  String? selectedColor; // THÊM: Màu sắc được chọn

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true, // Mặc định khi thêm vào là đã chọn
    this.selectedSize,
    this.selectedColor,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _userId;

  static const String cartCollection = 'carts';

  Future<void> saveCartToFirestore(String userId) async {
    _userId = userId;
    final cartData = _items
        .map((item) => {
              'product': item.product.toJson(),
              'quantity': item.quantity,
              'isSelected': item.isSelected,
              'selectedSize': item.selectedSize,
              'selectedColor': item.selectedColor,
            })
        .toList();
    try {
      await FirebaseFirestore.instance
          .collection(cartCollection)
          .doc(userId)
          .set({
        'items': cartData,
      });
    } catch (e) {
      debugPrint('Lỗi lưu giỏ hàng: $e');
    }
  }

  Future<void> loadCartFromFirestore(String userId) async {
    _userId = userId;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(cartCollection)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        final items = doc.data()!['items'] as List<dynamic>?;
        _items.clear();
        if (items != null) {
          for (final item in items) {
            final productJson = item['product'] as Map<String, dynamic>;
            _items.add(CartItem(
              product: ProductModel.fromJson(productJson),
              quantity: item['quantity'] ?? 1,
              isSelected: item['isSelected'] ?? true,
              selectedSize: item['selectedSize'],
              selectedColor: item['selectedColor'],
            ));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi tải giỏ hàng: $e');
    }
  }

  void syncCart() {
    if (_userId != null) {
      saveCartToFirestore(_userId!);
    }
  }

  List<CartItem> get items => _items;

  int get totalItems {
    return _items.fold<int>(0, (total, item) => total + item.quantity);
  }

  int get totalProductTypes {
    return _items.map((item) => item.product.id).toSet().length;
  }

  // 1. LOGIC TÍNH TIỀN ĐỘNG (Chỉ tính sản phẩm được tick)
  double get totalPrice {
    return _items.fold<double>(
      0,
      (total, item) => item.isSelected
          ? total + (item.product.price * item.quantity)
          : total,
    );
  }

  // 2. LOGIC CHỌN TẤT CẢ (Phục vụ checkbox ở Bottom Bar)
  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  void toggleAll(bool value) {
    for (var item in _items) {
      item.isSelected = value;
    }
    syncCart();
    notifyListeners();
  }

  // 3. THAY ĐỔI TRẠNG THÁI TICK CỦA TỪNG MÓN
  void toggleItemSelection(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      syncCart();
      notifyListeners();
    }
  }

  // XÓA CÁC SẢN PHẨM ĐÃ CHỌN SAU KHI ĐẶT HÀNG
  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    syncCart();
    notifyListeners();
  }

  int _findVariantIndex(CartItem target) {
    return _items.indexWhere(
      (item) =>
          item.product.id == target.product.id &&
          item.selectedSize == target.selectedSize &&
          item.selectedColor == target.selectedColor,
    );
  }

  void toggleItemSelectionByVariant(CartItem target) {
    final index = _findVariantIndex(target);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      syncCart();
      notifyListeners();
    }
  }

  void addToCart(ProductModel product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
      syncCart();
      notifyListeners();
      return;
    }

    _items.add(CartItem(product: product));
    syncCart();
    notifyListeners();
  }

  void addToCartWithSelection(
    ProductModel product, {
    required int quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        ),
      );
    }

    syncCart();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    syncCart();
    notifyListeners();
  }

  void removeFromCartByVariant(CartItem target) {
    _items.removeWhere(
      (item) =>
          item.product.id == target.product.id &&
          item.selectedSize == target.selectedSize &&
          item.selectedColor == target.selectedColor,
    );
    syncCart();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      syncCart();
      notifyListeners();
    }
  }

  void updateQuantityByVariant(CartItem target, int quantity) {
    final index = _findVariantIndex(target);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      syncCart();
      notifyListeners();
    }
  }

  // 4. XÓA CÁC MÓN ĐÃ MUA (Dùng cho trang Checkout sau khi bấm Đặt hàng)
  void clearOrderedItems() {
    _items.removeWhere((item) => item.isSelected);
    syncCart();
    notifyListeners();
  }
}
