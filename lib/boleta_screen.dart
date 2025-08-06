import 'package:flutter/material.dart';
import 'producto.dart';

class BoletaScreen extends StatelessWidget {
  final List<Producto> productos;

  const BoletaScreen({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total considering package/box prices
    double total = productos.fold(0, (suma, p) {
      if (p.precioCaja != null && p.precioCaja! > 0) {
        return suma + p.precioCaja!;
      } else if (p.precioPaquete != null && p.precioPaquete! > 0) {
        return suma + p.precioPaquete!;
      }
      return suma + p.precioUnidad;
    });

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
                    subtitle: _buildQuantityType(p),
                    trailing: Text(
                      'S/ ${_getPrice(p).toStringAsFixed(2)}',
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

  Widget _buildQuantityType(Producto p) {
    if (p.precioCaja != null && p.precioCaja! > 0) {
      return Text('1 caja (${p.paqueteXCja} paq. x ${p.unidXPaquete} unid.)');
    } else if (p.precioPaquete != null && p.precioPaquete! > 0) {
      return Text('1 paquete (${p.unidXPaquete} unid.)');
    }
    return Text('1 unidad');
  }

  double _getPrice(Producto p) {
    if (p.precioCaja != null && p.precioCaja! > 0) return p.precioCaja!;
    if (p.precioPaquete != null && p.precioPaquete! > 0) return p.precioPaquete!;
    return p.precioUnidad;
  }
}