import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _taxRate = 0.10; // Varsayılan %10 KDV
  
  double get taxRate => _taxRate;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _taxRate = prefs.getDouble('tax_rate') ?? 0.10;
    notifyListeners();
  }
  
  Future<void> setTaxRate(double rate) async {
    _taxRate = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tax_rate', rate);
    notifyListeners();
  }
  
  String get taxRatePercentage => '${(_taxRate * 100).toStringAsFixed(0)}%';
}
