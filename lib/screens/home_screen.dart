// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../models/food_item.dart';
import '../widgets/sidebar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/food_card.dart';
import '../widgets/cart_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Hepsi';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1000;    final products = Provider.of<ProductProvider>(context).products;
    
    // Önce kategoriye göre filtrele
    List<FoodItem> filteredItems = _selectedCategory == 'Hepsi'
        ? products
        : products.where((item) => item.category == _selectedCategory).toList();
    
    // Sonra arama sorgusuna göre filtrele
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) => 
        item.name.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),

          Expanded(
            flex: 7,
            child: Column(
              children: [
                // App bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      Row(
                        children: [
                          // Logo next to restaurant name
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/logo.jpg',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KARDEŞLER KEBAP SALONU',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'yemek, içecek vb. ara',
                                  prefixIcon: const Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Siparişler #${cartProvider.orderNumber}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CategoryTabs(
                        selectedCategory: _selectedCategory,
                        onSelectCategory: _selectCategory,
                      ),
                    ],
                  ),
                ),

                // Food items & cart
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: isWideScreen ? 7 : 6,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[100],
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWideScreen ? 3 : 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (ctx, i) => FoodCard(
                              foodItem: filteredItems[i],
                            ),
                          ),
                        ),
                      ),
                      if (isWideScreen)
                        const Expanded(
                          flex: 3,
                          child: CartWidget(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isWideScreen)
            const Expanded(
              flex: 3,
              child: CartWidget(),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return monthNames[month - 1];
  }
}
