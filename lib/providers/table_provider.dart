import 'package:flutter/foundation.dart';

class TableProvider with ChangeNotifier {
  final Map<String, bool> _tableStatus = {};
  final Map<String, DateTime> _tableOccupiedTimes = {};
  
  // Initialize all tables as available
  TableProvider() {
    for (int i = 1; i <= 12; i++) {
      _tableStatus['Masa $i'] = false; // false = müsait, true = dolu
    }
  }
  
  Map<String, bool> get tableStatus => {..._tableStatus};
  Map<String, DateTime> get tableOccupiedTimes => {..._tableOccupiedTimes};
  
  bool isTableOccupied(String tableName) {
    return _tableStatus[tableName] ?? false;
  }
  
  DateTime? getTableOccupiedTime(String tableName) {
    return _tableOccupiedTimes[tableName];
  }
  
  void setTableStatus(String tableName, bool isOccupied) {
    _tableStatus[tableName] = isOccupied;
    if (isOccupied) {
      _tableOccupiedTimes[tableName] = DateTime.now();
    } else {
      _tableOccupiedTimes.remove(tableName);
    }
    notifyListeners();
  }
  
  void occupyTable(String tableName) {
    setTableStatus(tableName, true);
  }
  
  void freeTable(String tableName) {
    setTableStatus(tableName, false);
  }
  
  List<String> get availableTables {
    return _tableStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  List<String> get occupiedTables {
    return _tableStatus.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  // Manually free all tables (useful for reset)
  void freeAllTables() {
    for (String tableName in _tableStatus.keys) {
      _tableStatus[tableName] = false;
    }
    _tableOccupiedTimes.clear();
    notifyListeners();
  }
}
