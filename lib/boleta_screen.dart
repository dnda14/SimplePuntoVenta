import 'package:flutter/material.dart';
import 'package:producto_calculador/item_boleta.dart';
import 'producto.dart';
import 'dart:collection';

class BoletaScreen extends StatelessWidget {
  final List<ItemBoleta> items;

  const BoletaScreen({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<_ProductoAgrupado, double> agrupados = {};

    for (var p in items) {
      final key = _ProductoAgrupado(
        nombre: p.nombre,
        tipo: _getTipo(p),
        precio: _getPrecio(p),
        detalle: _getDetalleCantidad(p),
      );
      agrupados.update(key, (cantidad) => cantidad + p.cantidad, ifAbsent: () => p.cantidad);
    }

    double total = agrupados.entries.fold(0, (suma, e) {
      return suma + (e.key.precio * e.value);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Boleta Generada')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: agrupados.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final entry = agrupados.entries.elementAt(index);
                  final producto = entry.key;
                  final cantidad = entry.value;

                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('${cantidad} x ${producto.tipo} (${producto.detalle})'),
                    trailing: Text(
                      'S/ ${(producto.precio * cantidad).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTipo(ItemBoleta p) {
    return p.tipo;
  }

  String _getDetalleCantidad(ItemBoleta p) {
    return p.detalle;
  }

  double _getPrecio(ItemBoleta p) {
    return p.precioUnitario;
  }
}

// Clase auxiliar para agrupar items
class _ProductoAgrupado {
  final String nombre;
  final String tipo;
  final double precio;
  final String detalle;

  _ProductoAgrupado({
    required this.nombre,
    required this.tipo,
    required this.precio,
    required this.detalle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProductoAgrupado &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre &&
          tipo == other.tipo &&
          precio == other.precio &&
          detalle == other.detalle;

  @override
  int get hashCode =>
      nombre.hashCode ^ tipo.hashCode ^ precio.hashCode ^ detalle.hashCode;
}
