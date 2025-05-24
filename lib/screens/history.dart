// lib/screens/history.dart

import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }
  Future<void> _loadOrders() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      debugPrint('Siparişler yükleniyor...');
      final allOrders = await OrderService.getAllOrders();
      debugPrint('${allOrders.length} sipariş yüklendi.');
      
      if (mounted) {
        setState(() {
          orders = allOrders;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Siparişler yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          orders = [];
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Siparişler yüklenirken hata oluştu: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      await OrderService.updateOrderStatus(order.id!, 'İptal Edildi');
      _loadOrders(); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş iptal edildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş iptal edilirken hata oluştu: $e')),
        );
      }
    }
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sipariş Detayları - #${order.orderNumber}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Sipariş No:', '#${order.orderNumber}'),
                _buildDetailRow('Tarih:', _formatDate(order.date)),
                _buildDetailRow('Sipariş Türü:', order.orderType),
                if (order.tableName?.isNotEmpty == true) 
                  _buildDetailRow('Masa:', order.tableName!),
                if (order.customerName?.isNotEmpty == true)
                  _buildDetailRow('Müşteri Adı:', order.customerName!),
                if (order.customerPhone?.isNotEmpty == true)
                  _buildDetailRow('Telefon:', order.customerPhone!),
                if (order.customerAddress?.isNotEmpty == true)
                  _buildDetailRow('Adres:', order.customerAddress!),
                _buildDetailRow('Ödeme Yöntemi:', order.paymentMethod),
                _buildDetailRow('Durum:', order.status),
                const Divider(),
                const Text('Sipariş Ürünleri:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.productName} x${item.quantity}')),
                      Text('${item.total.toStringAsFixed(2)} TL'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Toplam:', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${order.total.toStringAsFixed(2)} TL',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Geçmişi'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2D4599),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Henüz sipariş geçmişi yok',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final isCompleted = order.status == 'Tamamlandı';
                      final isCancelled = order.status == 'İptal Edildi';
                      
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '#${order.orderNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!isCancelled && isCompleted)
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _showCancelDialog(order),
                                      tooltip: 'Siparişi İptal Et',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tarih: ${_formatDate(order.date)}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tür: ${order.orderType}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              if (order.tableName?.isNotEmpty == true)
                                Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Masa: ${order.tableName}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Toplam: ${order.total.toStringAsFixed(2)} TL',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Durum: ${order.status}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCompleted 
                                      ? Colors.green 
                                      : isCancelled 
                                          ? Colors.red 
                                          : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showOrderDetails(order),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF2D4599),
                                ),
                                child: const Text('Detayları Gör'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showCancelDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Siparişi İptal Et'),
          content: Text('#${order.orderNumber} numaralı siparişi iptal etmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder(order);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Evet, İptal Et'),
            ),
          ],
        );
      },
    );
  }
}

