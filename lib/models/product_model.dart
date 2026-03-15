class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  // Bổ sung thêm các field để phục vụ UI nâng cao của đề bài
  final double? rate;
  final int? count;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rate,
    this.count,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      // Lấy thêm rating từ FakeStore API để làm phần "Đã bán" hoặc "Sao"
      rate: json['rating'] != null
          ? (json['rating']['rate'] as num).toDouble()
          : 0.0,
      count: json['rating'] != null ? json['rating']['count'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    };
  }
}
