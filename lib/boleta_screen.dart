import 'package:flutter/material.dart';
import 'producto.dart';

class BoletaScreen extends StatelessWidget {
  final List<Producto> productos;

  const BoletaScreen({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = productos.fold(0, (suma, p) => suma + p.precio);

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
