import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductModel>> fetchProducts({
    required int page,
    int pageSize = 8,
  }) async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Lỗi khi tải danh sách sản phẩm');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    final products = data
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final start = (page - 1) * pageSize;
    if (start >= products.length) {
      return <ProductModel>[];
    }

    final end = (start + pageSize).clamp(0, products.length);
    return products.sublist(start, end);
  }
}
