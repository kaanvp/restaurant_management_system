import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _products = []; // Made final

  List<Map<String, dynamic>> get products => _products;

  void addProduct(String name, String category, double price, String imageUrl) {
    _products.add({
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    });
    notifyListeners();
  }

  // Ensure this method exists and is saved.
  void updateProduct(String name, String category, double price, String imageUrl) {
    final index = _products.indexWhere((prod) => prod['name'] == name);
    if (index != -1) {
      _products[index] = {
        'name': name,
        'category': category,
        'price': price,
        'imageUrl': imageUrl,
      };
      notifyListeners();
    }
  }
}