import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'boleta_provider.dart';
import 'pdf_service.dart';

class BoletaScreen extends StatefulWidget {
  const BoletaScreen({Key? key}) : super(key: key);

  @override
  State<BoletaScreen> createState() => _BoletaScreenState();
}

class _BoletaScreenState extends State<BoletaScreen> {
  final String businessName = "Mi Negocio"; // You can make this configurable
  
  // Store scaffold messenger reference to avoid context issues
  late ScaffoldMessengerState _scaffoldMessenger;
  late NavigatorState _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _navigator = Navigator.of(context);
  }

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
                  : Row(
                      children: [
                        // Preview PDF button
                        IconButton(
                          icon: Icon(Icons.preview),
                          onPressed: () => _previewPDF(boletaProvider),
                          tooltip: 'Vista previa PDF',
                        ),
                        // Clear all button
                        IconButton(
                          icon: Icon(Icons.delete_sweep),
                          onPressed: () => _showClearAllDialog(boletaProvider),
                          tooltip: 'Limpiar todo',
                        ),
                      ],
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
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Volver a productos'),
                    ),
                  ),
                ],
              ),
            );
          }

          final agrupados = boletaProvider.groupedItems;
          final agrupadosList = agrupados.entries.toList();

          return SafeArea(
            // Add bottom: false to let us handle bottom padding manually
            bottom: false,
            child: Column(
              children: [
                // Header info with horizontal padding
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Container(
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
                ),
                
                // Products list
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListView.separated(
                      // Add bottom padding to the ListView
                      padding: EdgeInsets.only(top: 10, bottom: 10),
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
                ),
                
                // Bottom section with proper safe area handling
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12, // left
                    0,  // top
                    12, // right
                    MediaQuery.of(context).padding.bottom + 20, // bottom with safe area
                  ),
                  child: Column(
                    children: [
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
                      SizedBox(height: 16),
                      
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _previewPDF(BoletaProvider boletaProvider) async {
    if (!mounted) return;
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generando PDF...'),
            ],
          ),
        ),
      );

      await PDFService.previewBoleta(boletaProvider, businessName);
      
      // Close loading dialog if still mounted
      if (mounted) {
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      // Close loading dialog if still mounted
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    if (!mounted) return;
    
    final newQuantity = double.tryParse(quantityText);
    if (newQuantity == null || newQuantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese una cantidad válida')),
      );
      return;
    }

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
    if (!mounted) return;
    
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Boleta limpiada')),
                  );
                }
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
      builder: (dialogContext) {
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
              Text('¿Confirmar la venta y generar PDF?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _executeSale(dialogContext, boletaProvider),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Confirmar y guardar PDF'),
            ),
          ],
        );
      },
    );
  }

  void _executeSale(BuildContext dialogContext, BoletaProvider boletaProvider) async {
    // Close confirmation dialog first
    Navigator.of(dialogContext).pop();
    
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Procesando venta...'),
          ],
        ),
      ),
    );

    try {
      // Generate and save PDF
      String filePath = await PDFService.generateAndSaveBoleta(boletaProvider, businessName);
      
      // Clear boleta after successful PDF generation
      boletaProvider.clearBoleta();
      
      // Close loading dialog if still mounted
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Go back to home
        
        // Show success message using stored reference
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('¡Venta procesada y PDF guardado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      
    } catch (e) {
      print('Error in _executeSale: $e');
      
      // Close loading dialog if still mounted
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error using stored reference
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Still clear the boleta and go back
        boletaProvider.clearBoleta();
        Navigator.of(context).pop(); // Go back to home
        
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Venta procesada (PDF no pudo guardarse)'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}