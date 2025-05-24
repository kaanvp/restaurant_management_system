import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../utils/constants.dart';

class ProductProvider with ChangeNotifier {
  // Başlangıçta Constants'daki örnek verileri kullan
  final List<FoodItem> _products = List.from(foodItems);

  List<FoodItem> get products => [..._products];

  void addProduct(FoodItem product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(FoodItem updated) {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _products[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
