import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'producto.dart';
import 'boleta_screen.dart';
import 'producto_service.dart';
import 'boleta_provider.dart';

final logger = Logger();

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Producto> productos = [];
  String query = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final loadedProducts = await ProductoService.loadProducts();
      setState(() {
        productos = loadedProducts;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      logger.e("Error cargando productos", error: e, stackTrace: stackTrace);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtrados = productos
        .where((p) => fuzzyMatch(p.nombre, query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Boleta de productos'),
        actions: [
          Consumer<BoletaProvider>(
            builder: (context, boletaProvider, child) {
              return boletaProvider.isEmpty
                  ? Container()
                  : Badge(
                      label: Text('${boletaProvider.itemCount}'),
                      child: IconButton(
                        icon: Icon(Icons.receipt),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoletaScreen(),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ],
      ),
      // Use SafeArea with bottom: false to handle bottom padding manually
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar producto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            
            // Products list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  // Add padding to avoid content being hidden behind navigation bar
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: filtrados.length,
                  itemBuilder: (context, index) {
                    final producto = filtrados[index];
                    return Card(
                      child: ListTile(
                        title: Text(producto.nombre),
                        subtitle: Text(producto.priceDisplay),
                        trailing: _buildAddButton(producto),
                        onTap: () => _addToBoleta(producto, 'unidad', 1),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Bottom section with Consumer and buttons
            Container(
              padding: EdgeInsets.fromLTRB(
                12, // left
                10, // top
                12, // right
                MediaQuery.of(context).padding.bottom + 20, // bottom with safe area
              ),
              child: Consumer<BoletaProvider>(
                builder: (context, boletaProvider, child) {
                  return Column(
                    children: [
                      // Summary container
                      if (!boletaProvider.isEmpty)
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!boletaProvider.isEmpty) SizedBox(height: 10),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: boletaProvider.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BoletaScreen(),
                                        ),
                                      );
                                    },
                              child: Text('Ver boleta'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                          ),
                          if (!boletaProvider.isEmpty) ...[
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _showClearDialog(boletaProvider),
                              child: Icon(Icons.clear_all),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: Size(50, 50),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(Producto producto) {
    if (!producto.hasPack && !producto.hasBox) {
      return IconButton(
        icon: Icon(Icons.add_circle, color: Colors.green),
        onPressed: () => _showCantidadDialog(producto, 'unidad'),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.add_circle, color: Colors.green),
      onSelected: (value) {
        if (value == 'cancelar') return;
        _showCantidadDialog(producto, value);
      },
      itemBuilder: (context) {
        final options = <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'unidad',
            child: Text('Unidad: S/${producto.precioUnidad}'),
          ),
        ];

        if (producto.hasPack) {
          options.add(
            PopupMenuItem(
              value: 'paquete',
              child: Text(
                'Paquete: S/${producto.precioPaquete} (${producto.unidXPaquete} unid)',
              ),
            ),
          );
        }

        if (producto.hasBox) {
          options.add(
            PopupMenuItem(
              value: 'caja',
              child: Text(
                'Caja: S/${producto.precioCaja} (${producto.paqueteXCja} paq)',
              ),
            ),
          );
        }

        options.add(const PopupMenuDivider());
        options.add(
          const PopupMenuItem(value: 'cancelar', child: Text('✖ Cancelar')),
        );

        return options;
      },
    );
  }

  void _addToBoleta(Producto producto, String tipo, double cantidad) {
    context.read<BoletaProvider>().addItem(producto, tipo, cantidad);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado a la boleta'),
        duration: Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BoletaScreen()),
            );
          },
        ),
      ),
    );
  }

  void _showCantidadDialog(Producto producto, String tipo) {
    final TextEditingController _cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cantidad - ${producto.nombre}'),
          content: TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Ingrese cantidad',
              hintText: 'Ej: 2 o 0.5',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final cantidad = double.tryParse(_cantidadController.text);
                if (cantidad == null || cantidad <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ingrese una cantidad válida')),
                  );
                  return;
                }

                _addToBoleta(producto, tipo, cantidad);
                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(BoletaProvider boletaProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Limpiar boleta'),
          content: Text('¿Está seguro de eliminar todos los productos de la boleta?'),
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
              child: Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }

  bool fuzzyMatch(String producto, String query) {
    int j = 0;
    for (int i = 0; i < producto.length && j < query.length; i++) {
      if (producto[i].toLowerCase() == query[j].toLowerCase()) {
        j++;
      }
    }
    return j == query.length;
  }
}