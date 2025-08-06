import 'package:flutter/material.dart';
import 'producto.dart';
import 'boleta_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Producto> productos = [
    Producto('Arroz', 4.50),
    Producto('Azúcar', 3.20),
    Producto('Aceite', 7.80),
    Producto('Pan', 1.00),
    Producto('Huevos', 6.00),
    Producto('Leche', 3.80),
    Producto('Fideos', 2.90),
    Producto('Atún', 5.50),
    Producto('Mantequilla', 3.60),
    Producto('Cereal', 8.90),
  ];

  List<Producto> boleta = [];
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtrados = productos
        .where((p) => fuzzyMatch(p.nombre, query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Boleta de productos'),
      ),
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
                    subtitle: Text('S/ ${producto.precio.toStringAsFixed(2)}'),
                    trailing: Icon(Icons.add),
                    onTap: () {
                      setState(() => boleta.add(producto));
                    },
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
