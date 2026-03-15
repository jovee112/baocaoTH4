import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Hàm lấy danh sách sản phẩm có hỗ trợ phân trang (Pagination)
  // limit: số lượng sản phẩm muốn lấy
  Future<List<ProductModel>> getProducts({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi tải dữ liệu từ API');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến Server: $e');
    }
  }

  // Hàm lấy chi tiết 1 sản phẩm (nếu cần)
  Future<ProductModel> getProductDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Lỗi khi tải chi tiết sản phẩm');
    }
  }
}
