class Order {
  final int? id;
  final int orderNumber;
  final DateTime date;
  final double total;
  final String status; // 'Tamamlandı', 'İptal Edildi'
  final String orderType; // 'Restoranda', 'Paket'
  final String? tableName; // Masa adı (sadece restoranda yemek için)
  final String paymentMethod; // Ödeme yöntemi
  final String? customerName; // Müşteri adı (paket servis için)
  final String? customerPhone; // Müşteri telefonu (paket servis için)
  final String? customerAddress; // Müşteri adresi (paket servis için)
  final List<OrderItem> items; // Sipariş kalemleri

  Order({
    this.id,
    required this.orderNumber,
    required this.date,
    required this.total,
    required this.status,
    required this.orderType,
    this.tableName,
    required this.paymentMethod,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.items,
  });  Map<String, dynamic> toMap() {
    // Tüm alanları güvenli bir şekilde dönüştür
    final map = <String, dynamic>{
      'orderNumber': orderNumber,
      'date': date.toIso8601String(),
      'total': total,
      'status': status,
      'orderType': orderType,
      'tableName': tableName ?? '',
      'paymentMethod': paymentMethod,
      'customerName': customerName ?? '',
      'customerPhone': customerPhone ?? '',
      'customerAddress': customerAddress ?? '',
    };
    
    // ID varsa ekle
    if (id != null && id! > 0) {
      map['id'] = id;
    }
    
    return map;
  }
  factory Order.fromMap(Map<String, dynamic> map) {
    try {
      // Tarih dönüşümünde ekstra güvenlik kontrolü
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(map['date'] ?? '');
      } catch (e) {
        parsedDate = DateTime.now(); // Geçersiz tarih durumunda şimdiki zamanı kullan
      }
      
      return Order(
        id: map['id'] is int ? map['id'] : (map['id'] is String ? int.tryParse(map['id']) : null),
        orderNumber: map['orderNumber'] is int ? map['orderNumber'] : int.tryParse(map['orderNumber']?.toString() ?? '') ?? 0,
        date: parsedDate,
        total: map['total'] is double ? map['total'] : double.tryParse(map['total']?.toString() ?? '') ?? 0.0,
        status: map['status']?.toString() ?? '',
        orderType: map['orderType']?.toString() ?? '',
        tableName: map['tableName']?.toString(),
        paymentMethod: map['paymentMethod']?.toString() ?? '',
        customerName: map['customerName']?.toString(),
        customerPhone: map['customerPhone']?.toString(),
        customerAddress: map['customerAddress']?.toString(),
        items: [], // Başlangıçta boş, ayrı olarak yüklenecek
      );
    } catch (e) {
      // Herhangi bir hata durumunda varsayılan değerlerle bir sipariş döndür
      return Order(
        id: 0,
        orderNumber: 0,
        date: DateTime.now(),
        total: 0.0,
        status: 'Hata',
        orderType: 'Bilinmiyor',
        paymentMethod: 'Bilinmiyor',
        items: [],
      );
    }
  }
}

class OrderItem {
  final int? id;
  final int orderId;
  final String productName;
  final String category;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productName,
    required this.category,
    required this.price,
    required this.quantity,
    required this.total,
  });  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'orderId': orderId,
      'productName': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
    
    if (id != null && id! > 0) {
      map['id'] = id;
    }
    
    return map;
  }
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    try {
      return OrderItem(
        id: map['id'] is int ? map['id'] : (map['id'] is String ? int.tryParse(map['id']) : null),
        orderId: map['orderId'] is int ? map['orderId'] : int.tryParse(map['orderId']?.toString() ?? '') ?? 0,
        productName: map['productName']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
        price: map['price'] is double ? map['price'] : double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
        quantity: map['quantity'] is int ? map['quantity'] : int.tryParse(map['quantity']?.toString() ?? '') ?? 0,
        total: map['total'] is double ? map['total'] : double.tryParse(map['total']?.toString() ?? '') ?? 0.0,
      );
    } catch (e) {
      // Hata durumunda varsayılan değerlerle döndür
      return OrderItem(
        id: 0,
        orderId: 0,
        productName: 'Hatalı Ürün',
        category: 'Bilinmiyor',
        price: 0.0,
        quantity: 0,
        total: 0.0,
      );
    }
  }
}
