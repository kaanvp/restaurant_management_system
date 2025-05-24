import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/table_provider.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  // Helper method to format time ago
  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return "";
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return "Az önce";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} dk önce";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} saat önce";
    } else {
      return "${difference.inDays} gün önce";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TableProvider>(
      builder: (context, tableProvider, child) {
        final tables = List.generate(12, (i) => 'Masa ${i + 1}');
        
        return Scaffold(          appBar: AppBar(
            title: const Text('Masa Yönetimi'),
            backgroundColor: const Color(0xFF2D4599),
            foregroundColor: Colors.white,
            actions: [
              // Add a button to free all tables at once
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Tüm Masaları Boşalt',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Tüm Masaları Boşalt'),
                      content: const Text(
                        'Tüm masalar müsait olarak işaretlenecek. Bu işlem geri alınamaz! Devam etmek istiyor musunuz?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            tableProvider.freeAllTables();
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tüm masalar müsait olarak işaretlendi'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Tüm Masaları Boşalt'),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Durum özeti
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${tableProvider.availableTables.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Müsait'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${tableProvider.occupiedTables.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text('Dolu'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Masa grid'i
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (ctx, i) {
                      final tableName = tables[i];
                      final isOccupied = tableProvider.isTableOccupied(tableName);
                        return Card(
                        elevation: 4,
                        color: isOccupied ? Colors.red[100] : Colors.green[100],
                        child: InkWell(
                          onTap: () {
                            if (isOccupied) {
                              _showTableActionDialog(context, tableProvider, tableName, true);
                            } else {
                              _showTableActionDialog(context, tableProvider, tableName, false);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isOccupied ? Icons.no_food : Icons.table_restaurant,
                                  color: isOccupied ? Colors.red[700] : Colors.green[700],
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tableName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isOccupied ? Colors.red[700] : Colors.green[700],
                                  ),
                                ),
                                Text(
                                  isOccupied ? 'DOLU' : 'MÜSAİT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isOccupied ? Colors.red[700] : Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Show occupied time if table is occupied
                                if (isOccupied) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTimeAgo(tableProvider.getTableOccupiedTime(tableName)),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showTableActionDialog(BuildContext context, TableProvider tableProvider, String tableName, bool isOccupied) {
    final DateTime? occupiedTime = isOccupied ? tableProvider.getTableOccupiedTime(tableName) : null;
    final String occupiedTimeStr = occupiedTime != null 
        ? '${occupiedTime.hour.toString().padLeft(2, '0')}:${occupiedTime.minute.toString().padLeft(2, '0')}'
        : '';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isOccupied ? Icons.no_food : Icons.table_restaurant,
              color: isOccupied ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(tableName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOccupied
                  ? 'Bu masa şu anda dolu. Masayı müsait olarak işaretlemek istiyor musunuz?'
                  : 'Bu masa şu anda müsait. Masayı dolu olarak işaretlemek istiyor musunuz?',
            ),
            if (isOccupied && occupiedTime != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Dolu İşaretlenme Zamanı:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${occupiedTime.day}/${occupiedTime.month}/${occupiedTime.year} - $occupiedTimeStr',
              ),
              const SizedBox(height: 4),
              Text(
                'Geçen Süre: ${_formatTimeAgo(occupiedTime)}',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isOccupied) {
                tableProvider.freeTable(tableName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tableName müsait olarak işaretlendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                tableProvider.occupyTable(tableName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tableName dolu olarak işaretlendi'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D4599),
              foregroundColor: Colors.white,
            ),
            child: Text(isOccupied ? 'Müsait Yap' : 'Dolu Yap'),
          ),
        ],
      ),
    );
  }
}
