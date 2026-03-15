import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  bool isSelected; // THÊM: Trạng thái tick chọn để tính tiền

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true, // Mặc định khi thêm vào là đã chọn
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // 1. LOGIC TÍNH TIỀN ĐỘNG (Chỉ tính sản phẩm được tick)
  double get totalPrice {
    return _items.fold<double>(
      0,
      (sum, item) =>
          item.isSelected ? sum + (item.product.price * item.quantity) : sum,
    );
  }

  // 2. LOGIC CHỌN TẤT CẢ (Phục vụ checkbox ở Bottom Bar)
  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  void toggleAll(bool value) {
    for (var item in _items) {
      item.isSelected = value;
    }
    notifyListeners();
  }

  // 3. THAY ĐỔI TRẠNG THÁI TICK CỦA TỪNG MÓN
  void toggleItemSelection(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void addToCart(ProductModel product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
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
      notifyListeners();
    }
  }

  // 4. XÓA CÁC MÓN ĐÃ MUA (Dùng cho trang Checkout sau khi bấm Đặt hàng)
  void clearOrderedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }
}
