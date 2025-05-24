import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/table_provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0: Nakit, 1: Kredi Kartı, 2: QR Kod, 3: Veresiye
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  
  // Paket servis için müşteri bilgileri
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
    double _changeAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Widget oluşturulduktan sonra order type'ı kontrol edelim
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = Provider.of<CartProvider>(context, listen: false);
      if (cart.orderType == OrderType.toGo) {
        setState(() {
          _selectedPaymentMethod = 1; // Kredi kartı
        });
      }
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _creditController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final totalAmount = cart.getFinalTotal(settings.taxRate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ödeme İşlemi'),
        backgroundColor: const Color(0xFF2D4599),
        foregroundColor: Colors.white,
        elevation: 0,
      ),      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(cart, settings, totalAmount),
            
            const SizedBox(height: 20),
              // Table Selection (only for dine-in orders)
            if (cart.orderType == OrderType.dineIn) ...[
              _buildTableSelectionCard(cart),
              const SizedBox(height: 20),
            ],
            
            // Customer Information (only for takeout orders)
            if (cart.orderType == OrderType.toGo) ...[
              _buildCustomerInfoCard(),
              const SizedBox(height: 20),
            ],
            
            // Payment Methods
            _buildPaymentMethodsCard(totalAmount),
            
            const SizedBox(height: 20),
            
            // Process Payment Button
            _buildProcessPaymentButton(context, cart, totalAmount),
            
            const SizedBox(height: 20), // Extra bottom space
          ],
        ),
      ),
    );
  }
  Widget _buildOrderSummaryCard(CartProvider cart, SettingsProvider settings, double totalAmount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sipariş Özeti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4599),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cart.orderType == OrderType.dineIn ? Colors.green[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cart.orderType == OrderType.dineIn ? 'Restoranda' : 'Paket',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cart.orderType == OrderType.dineIn ? Colors.green[700] : Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.foodItem.name}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} TL',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ara Toplam:', style: TextStyle(color: Colors.grey[600])),
                Text('${cart.totalAmount.toStringAsFixed(0)} TL'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KDV ${settings.taxRatePercentage}:', style: TextStyle(color: Colors.grey[600])),
                Text('${cart.getTax(settings.taxRate).toStringAsFixed(0)} TL'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOPLAM:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4599),
                  ),
                ),
                Text(
                  '${totalAmount.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4599),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTableSelectionCard(CartProvider cart) {
    return Consumer<TableProvider>(
      builder: (context, tableProvider, child) {
        // 12 masa oluşturalım
        final List<String> tables = List.generate(12, (index) => 'Masa ${index + 1}');
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masa Seçimi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4599),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final tableName = tables[index];
                    final isSelected = cart.selectedTable == tableName;
                    final isOccupied = tableProvider.isTableOccupied(tableName);
                    
                    return GestureDetector(
                      onTap: isOccupied ? null : () {
                        cart.setSelectedTable(tableName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isOccupied 
                              ? Colors.red[100] 
                              : isSelected 
                                  ? const Color(0xFF2D4599) 
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isOccupied 
                                ? Colors.red[300]! 
                                : isSelected 
                                    ? const Color(0xFF2D4599) 
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isOccupied ? Icons.no_food : Icons.table_restaurant,
                              color: isOccupied 
                                  ? Colors.red[600] 
                                  : isSelected 
                                      ? Colors.white 
                                      : Colors.grey[600],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tableName,
                              style: TextStyle(
                                color: isOccupied 
                                    ? Colors.red[600] 
                                    : isSelected 
                                        ? Colors.white 
                                        : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isOccupied)
                              Text(
                                'DOLU',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (cart.selectedTable != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Seçili Masa: ${cart.selectedTable}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Müşteri Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4599),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon Numarası *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: '0555 123 45 67',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customerAddressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Teslimat Adresi *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Mahalle, Cadde/Sokak, Bina No...',
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPaymentMethodsCard(double totalAmount) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isToGo = cart.orderType == OrderType.toGo;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödeme Yöntemi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4599),
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment method buttons - conditional based on order type
            if (isToGo) ...[
              // Paket servis için sadece kredi kartı
              _buildPaymentMethodButton(1, Icons.credit_card, 'Online Ödeme - Kredi Kartı'),
            ] else ...[
              // Restoranda yemek için tüm seçenekler
              Row(
                children: [
                  Expanded(child: _buildPaymentMethodButton(0, Icons.money, 'Nakit')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildPaymentMethodButton(1, Icons.credit_card, 'Kart')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildPaymentMethodButton(2, Icons.qr_code, 'QR Kod')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildPaymentMethodButton(3, Icons.schedule, 'Veresiye')),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
              // Payment method specific content
            if (_selectedPaymentMethod == 0 && !isToGo) _buildCashPayment(totalAmount),
            if (_selectedPaymentMethod == 1) _buildCardPayment(totalAmount),
            if (_selectedPaymentMethod == 2 && !isToGo) _buildQRPayment(totalAmount),
            if (_selectedPaymentMethod == 3 && !isToGo) _buildCreditPayment(totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(int index, IconData icon, String label) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
          _changeAmount = 0.0;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D4599) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D4599) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPayment(double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nakit Ödeme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cashController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Alınan Tutar (TL)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.money),
          ),
          onChanged: (value) {
            final receivedAmount = double.tryParse(value) ?? 0;
            setState(() {
              _changeAmount = receivedAmount - totalAmount;
            });
          },
        ),
        if (_changeAmount > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Para Üstü:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_changeAmount.toStringAsFixed(0)} TL',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardPayment(double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kredi Kartı Ödemesi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            children: [
              Icon(Icons.credit_card, size: 48, color: Colors.blue[700]),
              const SizedBox(height: 8),
              Text(
                'POS Cihazını Hazırlayın',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ödenecek Tutar: ${totalAmount.toStringAsFixed(0)} TL',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRPayment(double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Kod ile Ödeme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[300]!),
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code, size: 48, color: Colors.purple[700]),
              const SizedBox(height: 8),
              Text(
                'QR Kodu Okutun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ödenecek Tutar: ${totalAmount.toStringAsFixed(0)} TL',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditPayment(double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Veresiye Ödeme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Column(
            children: [
              Icon(Icons.schedule, size: 48, color: Colors.orange[700]),
              const SizedBox(height: 8),
              Text(
                'Veresiye Kaydı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Borç Tutarı: ${totalAmount.toStringAsFixed(0)} TL',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Müşteri Adı (İsteğe Bağlı)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }  Widget _buildProcessPaymentButton(BuildContext context, CartProvider cart, double totalAmount) {
    String buttonText = 'Ödemeyi Tamamla';
    bool isEnabled = true;

    // Restoranda yemek seçiliyse masa zorunlu
    if (cart.orderType == OrderType.dineIn && cart.selectedTable == null) {
      buttonText = 'Masa Seçiniz';
      isEnabled = false;
    }
    // Paket servis için müşteri bilgileri zorunlu
    else if (cart.orderType == OrderType.toGo) {
      if (_customerNameController.text.trim().isEmpty) {
        buttonText = 'Müşteri Adı Giriniz';
        isEnabled = false;
      } else if (_customerPhoneController.text.trim().isEmpty) {
        buttonText = 'Telefon Numarası Giriniz';
        isEnabled = false;
      } else if (_customerAddressController.text.trim().isEmpty) {
        buttonText = 'Teslimat Adresi Giriniz';
        isEnabled = false;
      }
    }
    // Nakit ödeme için kontrol (sadece restoranda yemek için)
    else if (_selectedPaymentMethod == 0 && cart.orderType == OrderType.dineIn) {
      final receivedAmount = double.tryParse(_cashController.text) ?? 0;
      isEnabled = receivedAmount >= totalAmount;
      if (!isEnabled) {
        buttonText = 'Yetersiz Tutar';
      }
    }

    return ElevatedButton(
      onPressed: isEnabled ? () => _processPayment(context, cart) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D4599),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }  void _processPayment(BuildContext context, CartProvider cart) async {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    
    String paymentMethod = '';
    switch (_selectedPaymentMethod) {
      case 0:
        paymentMethod = 'Nakit';
        break;
      case 1:
        paymentMethod = cart.orderType == OrderType.toGo ? 'Online Ödeme - Kredi Kartı' : 'Kredi Kartı';
        break;
      case 2:
        paymentMethod = 'QR Kod';
        break;
      case 3:
        paymentMethod = 'Veresiye';
        break;
    }

    String orderLocation = cart.orderType == OrderType.dineIn 
        ? cart.selectedTable! 
        : 'Paket Servis';

    String customerInfo = '';
    if (cart.orderType == OrderType.toGo) {
      customerInfo = '\nMüşteri: ${_customerNameController.text.trim()}\n'
                    'Telefon: ${_customerPhoneController.text.trim()}\n'
                    'Adres: ${_customerAddressController.text.trim()}';
    }

    // Payment processing with better loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('$paymentMethod ödemesi işleniyor...'),
            Text('Sipariş: $orderLocation'),
            if (cart.orderType == OrderType.toGo)
              Text(
                customerInfo,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            const Text(
              'Lütfen bekleyiniz...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );    // Process payment with better error handling and timeout
    try {
      // Simulate processing time but with timeout
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      // Mark table as occupied temporarily for dine-in orders
      if (cart.orderType == OrderType.dineIn && cart.selectedTable != null) {
        tableProvider.occupyTable(cart.selectedTable!);
        
        // Free the table after 2 hours (7200 seconds) for completed orders
        Future.delayed(const Duration(hours: 2), () {
          if (mounted) {
            tableProvider.freeTable(cart.selectedTable!);
          }
        });
      }
      
      // Show immediate success and then process order in background
      await _showSuccessAndProcessOrder(context, cart, paymentMethod, orderLocation);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
          title: const Text('Ödeme Hatası'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ödeme işlemi sırasında hata oluştu!'),
              const SizedBox(height: 8),
              Text('Hata: ${e.toString()}'),
              const SizedBox(height: 16),
              const Text('Lütfen tekrar deneyin.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showSuccessAndProcessOrder(BuildContext context, CartProvider cart, String paymentMethod, String orderLocation) async {
    // Show success dialog immediately
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Ödeme Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$paymentMethod ile ödeme tamamlandı.'),
            const SizedBox(height: 8),
            Text('Sipariş Yeri: $orderLocation'),
            if (cart.orderType == OrderType.dineIn) ...[
              const SizedBox(height: 8),
              Text('Masa ${cart.selectedTable} artık dolu olarak işaretlendi.'),
            ],
            if (cart.orderType == OrderType.toGo) ...[
              const SizedBox(height: 8),
              const Text('Müşteri Bilgileri:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Ad: ${_customerNameController.text.trim()}'),
              Text('Telefon: ${_customerPhoneController.text.trim()}'),
              Text('Adres: ${_customerAddressController.text.trim()}'),
            ],
            if (_selectedPaymentMethod == 0 && _changeAmount > 0) ...[
              const SizedBox(height: 8),
              Text('Para Üstü: ${_changeAmount.toStringAsFixed(0)} TL'),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sipariş kaydediliyor...',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close success dialog
              cart.clearCart(); // Clear the cart
              cart.setSelectedTable(null); // Reset table selection
              // Clear customer information
              _customerNameController.clear();
              _customerPhoneController.clear();
              _customerAddressController.clear();
              if (!mounted) return;
              Navigator.of(context).pop(); // Go back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sipariş ${cart.orderType == OrderType.dineIn ? cart.selectedTable ?? 'masa' : "paket servis"} için başarıyla tamamlandı!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D4599),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );

    // Process order in background (with timeout)
    _saveOrderInBackground(cart, paymentMethod);
  }

  void _saveOrderInBackground(CartProvider cart, String paymentMethod) async {
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      
      // Prepare order items
      final orderItems = cart.items.map((cartItem) => OrderItem(
        orderId: 0, // Will be set to real ID later
        productName: cartItem.foodItem.name,
        category: cartItem.foodItem.category,
        price: cartItem.foodItem.price,
        quantity: cartItem.quantity,
        total: cartItem.totalPrice,
      )).toList();
      
      // Create order object
      final order = Order(
        orderNumber: cart.orderNumber,
        date: DateTime.now(),
        total: cart.getFinalTotal(settings.taxRate),
        status: 'Tamamlandı',
        orderType: cart.orderType == OrderType.dineIn ? 'Restoranda' : 'Paket',
        tableName: cart.selectedTable ?? '',
        paymentMethod: paymentMethod,
        customerName: cart.orderType == OrderType.toGo ? _customerNameController.text.trim() : '',
        customerPhone: cart.orderType == OrderType.toGo ? _customerPhoneController.text.trim() : '',
        customerAddress: cart.orderType == OrderType.toGo ? _customerAddressController.text.trim() : '',
        items: orderItems,
      );
      
      // Save order with timeout
      debugPrint('Background order save başlıyor...');
      
      final savedOrderId = await Future.any([
        OrderService.saveOrder(order),
        Future.delayed(const Duration(seconds: 10), () => -1) // Timeout after 10 seconds
      ]);
      
      debugPrint('Background order save tamamlandı: ID=$savedOrderId');
      
      if (savedOrderId == -1) {
        debugPrint('Sipariş arka planda kaydedilemedi (timeout veya hata)');
        // Don't show error to user since payment was already confirmed
      } else {
        debugPrint('Sipariş arka planda başarıyla kaydedildi: ID=$savedOrderId');
      }
      
    } catch (e) {
      debugPrint('Background order save hatası: $e');
      // Don't show error to user since payment was already confirmed
    }
  }
  }

