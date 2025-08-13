import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'boleta_provider.dart';

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({Key? key}) : super(key: key);

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boleta Generada'),
        actions: [
          Consumer<BoletaProvider>(
            builder: (context, boletaProvider, child) {
              return boletaProvider.isEmpty
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.delete_sweep),
                      onPressed: () => _showClearAllDialog(boletaProvider),
                    );
            },
          ),
        ],
      ),
      body: Consumer<BoletaProvider>(
        builder: (context, boletaProvider, child) {
          if (boletaProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No hay productos en la boleta',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Volver a productos'),
                  ),
                ],
              ),
            );
          }

          final agrupados = boletaProvider.groupedItems;
          final agrupadosList = agrupados.entries.toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Header info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items: ${boletaProvider.itemCount}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Total: S/ ${boletaProvider.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                
                // Products list
                Expanded(
                  child: ListView.separated(
                    itemCount: agrupadosList.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = agrupadosList[index];
                      final producto = entry.key;
                      final cantidad = entry.value;
                      final subtotal = producto.precio * cantidad;

                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            producto.nombre,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cantidad} x ${producto.tipo}'),
                              Text(
                                producto.detalle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'S/ ${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'S/ ${producto.precio.toStringAsFixed(2)} c/u',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showEditDialog(
                            context,
                            boletaProvider,
                            producto,
                            cantidad,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Total section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL A PAGAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'S/ ${boletaProvider.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Seguir comprando'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processSale(boletaProvider),
                        child: Text('Procesar venta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    BoletaProvider boletaProvider,
    dynamic producto,
    double currentQuantity,
  ) {
    final TextEditingController quantityController = TextEditingController(
      text: currentQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar: ${producto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${producto.tipo}'),
              Text('Precio unitario: S/ ${producto.precio.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Nueva cantidad',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 2 o 0.5',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _deleteItem(boletaProvider, producto),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
            ElevatedButton(
              onPressed: () => _updateQuantity(
                boletaProvider,
                producto,
                quantityController.text,
              ),
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _updateQuantity(
    BoletaProvider boletaProvider,
    dynamic producto,
    String quantityText,
  ) {
    final newQuantity = double.tryParse(quantityText);
    if (newQuantity == null || newQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese una cantidad válida')),
      );
      return;
    }

    // Find the item in the original list and update it
    final items = boletaProvider.items;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.nombre == producto.nombre && 
          item.tipo == producto.tipo &&
          item.precioUnitario == producto.precio) {
        boletaProvider.updateItemQuantity(i, newQuantity);
        break;
      }
    }

    Navigator.of(context).pop();
    
    if (newQuantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado de la boleta')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad actualizada')),
      );
    }
  }

  void _deleteItem(BoletaProvider boletaProvider, dynamic producto) {
    // Find and remove all items with matching product and type
    final items = boletaProvider.items;
    for (int i = items.length - 1; i >= 0; i--) {
      final item = items[i];
      if (item.nombre == producto.nombre && 
          item.tipo == producto.tipo &&
          item.precioUnitario == producto.precio) {
        boletaProvider.removeItem(i);
        break;
      }
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto.nombre} eliminado de la boleta')),
    );
  }

  void _showClearAllDialog(BoletaProvider boletaProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Limpiar toda la boleta'),
          content: Text(
            '¿Está seguro de eliminar todos los productos de la boleta?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                boletaProvider.clearBoleta();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Boleta limpiada')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Limpiar todo'),
            ),
          ],
        );
      },
    );
  }

  void _processSale(BoletaProvider boletaProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Procesar venta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total a cobrar:'),
              Text(
                'S/ ${boletaProvider.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text('¿Confirmar la venta?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                boletaProvider.clearBoleta();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡Venta procesada exitosamente!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Confirmar venta'),
            ),
          ],
        );
      },
    );
  }
}