import 'package:flutter/material.dart';
import 'producto.dart';
import 'dart:collection';

class BoletaScreen extends StatelessWidget {
  final List<Producto> productos;

  const BoletaScreen({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<_ProductoAgrupado, int> agrupados = {};

    for (var p in productos) {
      final key = _ProductoAgrupado(
        nombre: p.nombre,
        tipo: _getTipo(p),
        precio: _getPrecio(p),
        detalle: _getDetalleCantidad(p),
      );
      agrupados.update(key, (cantidad) => cantidad + 1, ifAbsent: () => 1);
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

  String _getTipo(Producto p) {
    if (p.precioCaja != null && p.precioCaja! > 0) return 'Caja';
    if (p.precioPaquete != null && p.precioPaquete! > 0) return 'Paquete';
    return 'Unidad';
  }

  String _getDetalleCantidad(Producto p) {
    if (p.precioCaja != null && p.precioCaja! > 0) {
      return '${p.paqueteXCja} paq. x ${p.unidXPaquete} unid.';
    } else if (p.precioPaquete != null && p.precioPaquete! > 0) {
      return '${p.unidXPaquete} unid.';
    }
    return '1 unid.';
  }

  double _getPrecio(Producto p) {
    if (p.precioCaja != null && p.precioCaja! > 0) return p.precioCaja!;
    if (p.precioPaquete != null && p.precioPaquete! > 0) return p.precioPaquete!;
    return p.precioUnidad;
  }
}

// Clase auxiliar para agrupar productos
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
