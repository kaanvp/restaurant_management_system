import 'package:flutter/foundation.dart';
import 'dart:async';
import '../helpers/db_helper.dart';
import '../models/order.dart';

class OrderService {  // Sipariş kaydetme - optimized for web
  static Future<int> saveOrder(Order order) async {
    try {
      debugPrint('Sipariş kayıt işlemi başladı: ${order.orderNumber}');
      
      // Get database with timeout
      final db = await Future.any([
        DBHelper.database(),
        Future.delayed(const Duration(seconds: 5), () => throw TimeoutException('Database connection timeout'))
      ]);
      
      // Transaction içinde işlemleri gerçekleştir with timeout
      return await Future.any([
        db.transaction((txn) async {
          try {
            // Siparişi kaydet ve null değerleri kontrol et
            final orderMap = {...order.toMap()};
            
            // Null değerleri kontrol et
            orderMap.forEach((key, value) {
              if (value == null) {
                if (key == 'tableName' || key == 'customerName' || key == 'customerPhone' || key == 'customerAddress') {
                  orderMap[key] = '';
                }
              }
            });
            
            debugPrint('Sipariş verileri: $orderMap');
            final orderId = await txn.insert('orders', orderMap);
            
            debugPrint('Sipariş ID: $orderId');
            if (orderId <= 0) {
              throw Exception('Sipariş veritabanına eklenirken hata oluştu');
            }
            
            // Sonra sipariş kalemlerini kaydet
            for (var item in order.items) {
              try {
                // Temiz bir map oluştur, foreign key olarak orderId'yi ekle
                final orderItemMap = {
                  'orderId': orderId,
                  'productName': item.productName,
                  'category': item.category,
                  'price': item.price,
                  'quantity': item.quantity,
                  'total': item.total
                };
                
                debugPrint('Sipariş kalemi: $orderItemMap');
                final itemId = await txn.insert('order_items', orderItemMap);
                
                if (itemId <= 0) {
                  debugPrint('Sipariş kalemi eklenemedi: $orderItemMap');
                  throw Exception('Sipariş kalemi kaydedilirken hata: ID=$itemId');
                }
              } catch (itemError) {
                debugPrint('Sipariş kalemi eklenirken hata: $itemError');
                throw Exception('Sipariş kalemi işlemi başarısız: $itemError');
              }
            }
            
            return orderId;
          } catch (e) {
            debugPrint('Transaction içinde hata: $e');
            throw e;
          }
        }),
        Future.delayed(const Duration(seconds: 8), () => throw TimeoutException('Transaction timeout'))
      ]);
    } catch (e) {
      debugPrint('Sipariş kaydedilirken hata: $e');
      return -1;
    }
  }
  // Tüm siparişleri getirme
  static Future<List<Order>> getAllOrders() async {
    try {
      debugPrint('getAllOrders başlıyor');
      final orderMaps = await DBHelper.getData('orders');
      debugPrint('Toplam ${orderMaps.length} sipariş bulundu');
      
      List<Order> orders = [];
      
      for (var orderMap in orderMaps) {
        try {
          debugPrint('Sipariş işleniyor: ID=${orderMap['id']}');
          
          // Önce siparişi oluştur
          final order = Order.fromMap(orderMap);
          
          if (order.id == null) {
            debugPrint('HATA: Sipariş ID null');
            continue;
          }
          
          // Sipariş kalemlerini getir
          final itemMaps = await getOrderItems(order.id!);
          debugPrint('Sipariş #${order.orderNumber} için ${itemMaps.length} kalem bulundu');
          
          // Tüm verileri içeren siparişi oluştur
          final orderWithItems = Order(
            id: order.id,
            orderNumber: order.orderNumber,
            date: order.date,
            total: order.total,
            status: order.status,
            orderType: order.orderType,
            tableName: order.tableName,
            paymentMethod: order.paymentMethod,
            customerName: order.customerName,
            customerPhone: order.customerPhone,
            customerAddress: order.customerAddress,
            items: itemMaps,
          );
          
          orders.add(orderWithItems);
        } catch (itemError) {
          debugPrint('Sipariş işlenirken hata: $itemError');
          // Bu siparişi atla ama diğerlerine devam et
          continue;
        }
      }
      
      // En yeni siparişler önce gelsin
      orders.sort((a, b) => b.date.compareTo(a.date));
      debugPrint('Getirilen toplam sipariş sayısı: ${orders.length}');
      return orders;
    } catch (e) {
      debugPrint('Siparişler getirilirken hata: $e');
      return [];
    }
  }
  // Sipariş kalemlerini getirme
  static Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      debugPrint('getOrderItems çağrıldı: orderId=$orderId');
      final db = await DBHelper.database();
      
      // Sorguyu doğru formatta oluştur
      final itemMaps = await db.query(
        'order_items', 
        where: 'orderId = ?', 
        whereArgs: [orderId]
      );
      
      debugPrint('Sipariş kalemleri bulundu: ${itemMaps.length}');
      if (itemMaps.isEmpty) {
        debugPrint('Uyarı: Bu sipariş için kalem bulunamadı (orderId=$orderId)');
      }
      
      return itemMaps.map((map) => OrderItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Sipariş kalemleri getirilirken hata: $e');
      return [];
    }
  }

  // Sipariş silme
  static Future<bool> deleteOrder(int orderId) async {
    try {
      // Önce sipariş kalemlerini sil (CASCADE ile otomatik silinmeli ama emin olmak için)
      await DBHelper.delete('order_items', 'orderId = ?', [orderId]);
      
      // Sonra siparişi sil
      final result = await DBHelper.delete('orders', 'id = ?', [orderId]);
      
      return result > 0;
    } catch (e) {
      debugPrint('Sipariş silinirken hata: $e');
      return false;
    }
  }

  // Sipariş durumu güncelleme
  static Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final result = await DBHelper.update(
        'orders', 
        {'status': status}, 
        'id = ?', 
        [orderId]
      );
        return result > 0;
    } catch (e) {
      debugPrint('Sipariş durumu güncellenirken hata: $e');
      return false;
    }
  }

  // Belirli bir siparişi getirme
  static Future<Order?> getOrderById(int orderId) async {
    try {
      final db = await DBHelper.database();
      final orderMaps = await db.query(
        'orders', 
        where: 'id = ?', 
        whereArgs: [orderId],
        limit: 1
      );
      
      if (orderMaps.isEmpty) return null;
      
      final order = Order.fromMap(orderMaps.first);
      final items = await getOrderItems(orderId);
      
      return Order(
        id: order.id,
        orderNumber: order.orderNumber,
        date: order.date,
        total: order.total,
        status: order.status,
        orderType: order.orderType,
        tableName: order.tableName,
        paymentMethod: order.paymentMethod,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerAddress: order.customerAddress,
        items: items,      );
    } catch (e) {
      debugPrint('Sipariş getirilirken hata: $e');
      return null;
    }
  }
}
