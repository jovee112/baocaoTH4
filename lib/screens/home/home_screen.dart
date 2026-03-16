import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  static const int _pageSize = 8;

  final List<Map<String, String>> _banners = const [
    {
      'title': 'Siêu Sale 3.3',
      'subtitle': 'Giá từ 19k - Freeship toàn quốc',
      'color': '0xFFEE4D2D',
    },
    {
      'title': 'Deal thương hiệu',
      'subtitle': 'Giảm tới 50% cho Mall chính hãng',
      'color': '0xFFFF7A00',
    },
    {
      'title': 'Voucher mỗi ngày',
      'subtitle': 'Đơn đầu từ 99k là có voucher',
      'color': '0xFF0F9D58',
    },
    {
      'title': 'Khung giờ vàng',
      'subtitle': '12h - 14h săn deal cực sốc',
      'color': '0xFF1E88E5',
    },
  ];

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.grid_view_rounded, 'label': 'Tất cả', 'filters': <String>[]},
    {
      'icon': Icons.checkroom,
      'label': 'Thời trang',
      'filters': <String>['clothing'],
    },
    {
      'icon': Icons.phone_android,
      'label': 'Điện thoại',
      'filters': <String>['electronics', 'phone'],
    },
    {
      'icon': Icons.face_retouching_natural,
      'label': 'Mỹ phẩm',
      'filters': <String>['jewelery', 'beauty', 'cosmetic'],
    },
    {
      'icon': Icons.kitchen,
      'label': 'Gia dụng',
      'filters': <String>['electronics', 'home', 'kitchen'],
    },
    {
      'icon': Icons.watch,
      'label': 'Phụ kiện',
      'filters': <String>['jewelery', 'watch', 'accessory'],
    },
    {
      'icon': Icons.sports_esports,
      'label': 'Giải trí',
      'filters': <String>['electronics', 'gaming'],
    },
    {
      'icon': Icons.menu_book,
      'label': 'Sách',
      'filters': <String>['book']
    },
    {
      'icon': Icons.sports_basketball,
      'label': 'Thể thao',
      'filters': <String>['sport'],
    },
  ];

  List<ProductModel> products = <ProductModel>[];
  List<ProductModel> filteredProducts = <ProductModel>[];
  int _currentPage = 1;
  int _currentBanner = 0;
  String _selectedCategory = 'Tất cả';

  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isScrolled = false;

  List<ProductModel> _filterProducts(List<ProductModel> source) {
    final searchText = searchController.text.trim().toLowerCase();
    final selectedCategory = _categories.firstWhere(
      (category) => category['label'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    final filters = List<String>.from(
      selectedCategory['filters'] as List<dynamic>? ?? <dynamic>[],
    );

    return source.where((product) {
      final titleMatch = searchText.isEmpty ||
          product.title.toLowerCase().contains(searchText);
      final categoryText = product.category.toLowerCase();
      final categoryMatch =
          filters.isEmpty || filters.any((key) => categoryText.contains(key));
      return titleMatch && categoryMatch;
    }).toList();
  }

  void _onCategorySelected(String label) {
    if (_selectedCategory == label) {
      return;
    }
    setState(() {
      _selectedCategory = label;
      filteredProducts = _filterProducts(products);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialProducts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isInitialLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final products = await _productService.fetchProducts(
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        this.products = products;
        filteredProducts = _filterProducts(products);
        _hasMoreData = products.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải sản phẩm: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData || _isInitialLoading) {
      return;
    }

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      final moreProducts = await _productService.fetchProducts(
        page: nextPage,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPage = nextPage;
        products.addAll(moreProducts);
        filteredProducts = _filterProducts(products);
        _hasMoreData = moreProducts.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải thêm sản phẩm: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _refreshProducts() async {
    await _loadInitialProducts();
  }

  void _onSearchChanged(String searchText) {
    setState(() {
      filteredProducts = _filterProducts(products);
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      filteredProducts = _filterProducts(products);
    });
  }

  void _onScroll() {
    final scrolledNow = _scrollController.hasClients &&
        _scrollController.offset > (kToolbarHeight / 2);
    if (scrolledNow != _isScrolled) {
      setState(() => _isScrolled = scrolledNow);
    }

    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 320) {
      _loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(child: _buildBannerSection()),
            SliverToBoxAdapter(child: _buildCategorySection()),
            if (_isInitialLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Không tìm thấy sản phẩm nào')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/detail',
                            arguments: product,
                          );
                        },
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.64,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: _isLoadingMore ? 56 : 24,
                alignment: Alignment.center,
                child: _isLoadingMore
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : (!_hasMoreData && filteredProducts.isNotEmpty
                        ? const Text(
                            'Đã hiển thị tất cả sản phẩm',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: _banners.length,
            itemBuilder: (context, index, realIndex) {
              final banner = _banners[index];
              final bannerColor =
                  Color(int.parse(banner['color'] ?? '0xFFEE4D2D'));
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      bannerColor,
                      bannerColor.withOpacity(0.84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bannerColor.withOpacity(0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner['subtitle'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: 142,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() => _currentBanner = index);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_banners.length, (index) {
              final selected = index == _currentBanner;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color:
                      selected ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    const spacing = 8.0;
    const sectionHeight = 140.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SizedBox(
        height: sectionHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalColumns = (_categories.length / 2).ceil();
            const int visibleColumns = 4;
            final cardWidth =
                (constraints.maxWidth - spacing * (visibleColumns - 1)) /
                    visibleColumns;
            final contentWidth =
                totalColumns * cardWidth + (totalColumns - 1) * spacing;
            final canScroll = contentWidth > constraints.maxWidth;

            final row = Row(
              children: List.generate(totalColumns, (columnIndex) {
                final topIndex = columnIndex;
                final bottomIndex = columnIndex + totalColumns;

                return Padding(
                  padding: EdgeInsets.only(
                    right: columnIndex == totalColumns - 1 ? 0 : spacing,
                  ),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(_categories[topIndex]),
                        ),
                        const SizedBox(height: spacing),
                        Expanded(
                          child: bottomIndex < _categories.length
                              ? _buildCategoryCard(_categories[bottomIndex])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );

            if (canScroll) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(width: contentWidth, child: row),
              );
            }

            return row;
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final label = category['label'] as String;
    final isSelected = label == _selectedCategory;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onCategorySelected(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEE4D2D).withOpacity(0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFFEE4D2D) : Colors.grey.shade200,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category['icon'] as IconData,
                size: 20,
                color: isSelected
                    ? const Color(0xFFEE4D2D)
                    : const Color(0xFFEE4D2D),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFFEE4D2D)
                        : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final baseColor =
        _isScrolled ? const Color(0xFFEE4D2D) : Colors.transparent;
    final iconColor = _isScrolled ? Colors.white : const Color(0xFF222222);
    final hintColor =
        _isScrolled ? Colors.white.withOpacity(0.95) : Colors.grey.shade700;

    return SliverAppBar(
      title: Text(
        'TH4 - Nhóm 4',
        style: TextStyle(color: iconColor, fontWeight: FontWeight.w700),
      ),
      pinned: true,
      floating: false,
      snap: false,
      toolbarHeight: 48,
      elevation: _isScrolled ? 2 : 0,
      backgroundColor: baseColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isScrolled
                        ? Colors.white.withOpacity(0.18)
                        : const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    cursorColor:
                        _isScrolled ? Colors.white : const Color(0xFFEE4D2D),
                    style: TextStyle(
                      color: _isScrolled ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tìm kiếm sản phẩm...',
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: hintColor,
                        size: 20,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 20,
                        minWidth: 36,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: Icon(
                                Icons.close,
                                color: hintColor,
                                size: 18,
                              ),
                              tooltip: 'Xóa tìm kiếm',
                            )
                          : null,
                      contentPadding: const EdgeInsets.only(top: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Selector<CartProvider, int>(
                selector: (_, cart) => cart.totalProductTypes,
                builder: (context, totalItems, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Giỏ hàng',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/cart');
                        },
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                      if (totalItems > 0)
                        Positioned(
                          right: 4,
                          top: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _isScrolled
                                  ? Colors.white
                                  : const Color(0xFFEE4D2D),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            constraints: const BoxConstraints(minWidth: 18),
                            child: Text(
                              totalItems > 99 ? '99+' : '$totalItems',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isScrolled
                                    ? const Color(0xFFEE4D2D)
                                    : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.black),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.of(context).pushNamed('/profile');
                  } else if (value == 'orders') {
                    Navigator.of(context).pushNamed('/orders');
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('Thông tin tài khoản'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'orders',
                    child: Text('Đơn mua'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Đăng xuất'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
