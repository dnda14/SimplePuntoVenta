import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Producto {
  final String nombre;
  final double precio;

  Producto(this.nombre, this.precio);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boleta de productos',
      home: HomeScreen(),
    );
  }
}

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
        .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
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
}

class BoletaScreen extends StatelessWidget {
  final List<Producto> productos;

  const BoletaScreen({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total =
        productos.fold(0, (suma, p) => suma + p.precio);

    return Scaffold(
      appBar: AppBar(title: Text('Boleta Generada')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: productos.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return ListTile(
                    title: Text(p.nombre),
                    trailing: Text('S/ ${p.precio.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
