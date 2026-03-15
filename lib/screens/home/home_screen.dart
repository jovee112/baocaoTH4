import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_screen.dart';
import '../detail/detail_screen.dart';

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
      'title': 'Sieu Sale 3.3',
      'subtitle': 'Gia tu 19k - Freeship toan quoc',
      'color': '0xFFEE4D2D',
    },
    {
      'title': 'Deal thuong hieu',
      'subtitle': 'Giam toi 50% cho Mall chinh hang',
      'color': '0xFFFF7A00',
    },
    {
      'title': 'Voucher moi ngay',
      'subtitle': 'Don dau tu 99k la co voucher',
      'color': '0xFF0F9D58',
    },
    {
      'title': 'Khung gio vang',
      'subtitle': '12h - 14h san deal cuc soc',
      'color': '0xFF1E88E5',
    },
  ];

  List<ProductModel> products = <ProductModel>[];
  List<ProductModel> filteredProducts = <ProductModel>[];
  int _currentPage = 1;
  int _currentBanner = 0;

  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _isScrolled = false;

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
        filteredProducts = products;
        _hasMoreData = products.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong the tai san pham: $e')),
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
        filteredProducts = products
            .where(
              (product) => product.title.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
            )
            .toList();
        _hasMoreData = moreProducts.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong the tai them san pham: $e')),
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
      filteredProducts = products
          .where(
            (product) => product.title.toLowerCase().contains(
                  searchText.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      filteredProducts = products;
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

    final threshold = _scrollController.position.maxScrollExtent - 280;
    if (_scrollController.position.pixels >= threshold) {
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
            if (_isInitialLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredProducts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Khong tim thay san pham nao')),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                product: product,
                              ),
                            ),
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
                    : null,
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
                      bannerColor.withValues(alpha: 0.84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bannerColor.withValues(alpha: 0.28),
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final baseColor = _isScrolled ? const Color(0xFFEE4D2D) : Colors.white;
    final iconColor = _isScrolled ? Colors.white : const Color(0xFF222222);
    final hintColor = _isScrolled
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.grey.shade700;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      expandedHeight: 90,
      elevation: _isScrolled ? 2 : 0,
      backgroundColor: baseColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isScrolled
                          ? Colors.white.withValues(alpha: 0.18)
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
                        hintText: 'Tim kiem san pham...',
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
                                tooltip: 'Xoa tim kiem',
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
                  selector: (_, cart) => cart.totalItems,
                  builder: (context, totalItems, _) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          tooltip: 'Gio hang',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
