import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'producto.dart';
import 'boleta_screen.dart';
import 'producto_service.dart';

final logger = Logger();

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Producto> productos = [];
  List<Producto> boleta = [];
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
      return Center(child: CircularProgressIndicator());
    }

    final filtrados = productos
        .where((p) => fuzzyMatch(p.nombre, query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Boleta de productos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final producto = filtrados[index];
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text(producto.priceDisplay),
                    trailing: _buildAddButton(producto),
                    onTap: () => _addToBoleta(producto, 'unidad'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: boleta.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BoletaScreen(productos: boleta),
                        ),
                      );
                    },
              child: Text('Generar boleta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(Producto producto) {
    if (!producto.hasPack && !producto.hasBox) {
      return IconButton(
        icon: Icon(Icons.add),
        onPressed: () => _showCantidadDialog(producto, 'unidad'),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.add),
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

        // Agregar opción cancelar
        options.add(const PopupMenuDivider());
        options.add(
          const PopupMenuItem(value: 'cancelar', child: Text('❌ Cancelar')),
        );

        return options;
      },
    );
  }

  void _addToBoleta(Producto originalProduct, String tipo) {
    final productoParaBoleta = Producto(
      nombre: originalProduct.nombre,
      precioUnidad: originalProduct.precioUnidad,
      precioPaquete: tipo == 'paquete' ? originalProduct.precioPaquete : null,
      precioCaja: tipo == 'caja' ? originalProduct.precioCaja : null,
      unidXPaquete: originalProduct.unidXPaquete,
      paqueteXCja: originalProduct.paqueteXCja,
    );

    setState(() => boleta.add(productoParaBoleta));
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Ingrese cantidad',
            hintText: 'Ej: 2',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Volver
            child: Text('🔙 Atrás'),
          ),
          TextButton(
            onPressed: () {
              final cantidad = int.tryParse(_cantidadController.text);
              if (cantidad == null || cantidad <= 0) return;

              for (int i = 0; i < cantidad; i++) {
                _addToBoleta(producto, tipo);
              }

              Navigator.of(context).pop(); // Cierra diálogo
            },
            child: Text('✔️ Aceptar'),
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
