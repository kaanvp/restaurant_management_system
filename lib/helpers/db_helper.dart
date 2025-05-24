import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

// Web platform için gerekli eklentiler
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// Mobil/masaüstü platform için gerekli eklentiler
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart' as path_provider;

class DBHelper {  
  static Database? _db;
  static const _dbName = 'restaurant.db';
  static const _dbVersion = 3; // Veritabanı versiyonunu artırdık, web desteği için

  static Future<Database> database() async {
    if (_db != null) return _db!;
    
    // Web platformu için
    if (kIsWeb) {
      debugPrint('Web platformu için veritabanı oluşturuluyor...');
      
      // Web için databaseFactoryFfiWeb kullanılıyor
      var factory = databaseFactoryFfiWeb;
      _db = await factory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      ).timeout(const Duration(seconds: 15)); 
      debugPrint('Web veritabanı başarıyla oluşturuldu');
      return _db!;
    } 
    // Mobil veya masaüstü platformları için
    else {
      debugPrint('Mobil/masaüstü platformu için veritabanı oluşturuluyor...');
      io.Directory docDir = await path_provider.getApplicationDocumentsDirectory();
      String path = p.join(docDir.path, _dbName);
      _db = await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      debugPrint('Mobil/masaüstü veritabanı başarıyla oluşturuldu');
      return _db!;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 1. tabloları oluştur
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        price REAL,
        imageUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tablesData(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        status TEXT,
        time TEXT
      )
    ''');    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderNumber INTEGER NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        orderType TEXT NOT NULL,
        tableName TEXT DEFAULT '',
        paymentMethod TEXT NOT NULL,
        customerName TEXT DEFAULT '',
        customerPhone TEXT DEFAULT '',
        customerAddress TEXT DEFAULT ''
      )
    ''');
      await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // 2. constants.dart içindeki örnek ürünleri ekle
    for (var item in foodItems) {
      await db.insert('products', {
        'name': item.name,
        'category': item.category,
        'price': item.price,
        'imageUrl': item.imageUrl,
      });
    }
  }
  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // versiyon yükseldiğinde tablovarı silip baştan oluştur ve seed et
    if (oldV < newV) {
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS tablesData');
      await db.execute('DROP TABLE IF EXISTS orders');
      await db.execute('DROP TABLE IF EXISTS order_items');
      await _onCreate(db, newV);
    }
  }  static Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database();
      // Null değerleri boş dize veya varsayılan değerlerle değiştir
      final cleanData = Map<String, dynamic>.from(data);
      
      // ID null ise kaldır, veritabanı otomatik ID ataması yapacak
      cleanData.removeWhere((key, value) => key == 'id' && value == null);
      
      // Null değerleri işle
      cleanData.forEach((key, value) {
        if (value == null) {
          if (['orderNumber', 'quantity', 'orderId'].contains(key)) {
            cleanData[key] = 0;
          } else if (['total', 'price'].contains(key)) {
            cleanData[key] = 0.0;
          } else if (value is String?) {
            cleanData[key] = '';
          }
        }
      });
      
      debugPrint('$table tablosuna veri ekleniyor: $cleanData');
      
      int insertId = await db.insert(
        table, 
        cleanData, 
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      
      if (insertId > 0) {
        debugPrint('$table tablosuna veri eklendi: ID=$insertId');
      } else {
        debugPrint('$table tablosuna veri eklenemedi!');
      }
      
      return insertId;
    } catch (e) {
      debugPrint('Veritabanı insert işleminde hata: $e');
      // Stack trace'i de yazdır
      debugPrintStack();
      return -1;
    }
  }
  static Future<List<Map<String,dynamic>>> getData(String table) async {
    try {
      final db = await database();
      final results = await db.query(table);
      debugPrint('$table tablosundan ${results.length} kayıt getirildi');
      return results;
    } catch (e) {
      debugPrint('$table tablosundan veri getirilirken hata: $e');
      return []; // Hata durumunda boş liste döndür
    }
  }

  static Future<int> update(String table, Map<String,dynamic> data, String where, List<dynamic> args) async {
    final db = await database();
    return db.update(table, data, where: where, whereArgs: args);
  }

  static Future<int> delete(String table, String where, List<dynamic> args) async {
    final db = await database();
    return db.delete(table, where: where, whereArgs: args);
  }
}
