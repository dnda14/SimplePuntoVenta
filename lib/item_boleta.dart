import 'package:producto_calculador/producto.dart';

class ItemBoleta {
  final Producto producto;
  final String tipo; // 'unidad', 'paquete', 'caja'
  final double cantidad;

  ItemBoleta({
    required this.producto,
    required this.tipo,
    required this.cantidad,
  });

  double get precioUnitario {
    switch (tipo) {
      case 'caja':
        return producto.precioCaja ?? 0;
      case 'paquete':
        return producto.precioPaquete ?? 0;
      default:
        return producto.precioUnidad;
    }
  }

  double get subtotal => precioUnitario * cantidad;

  String get detalle {
    if (tipo == 'caja') {
      return '${producto.paqueteXCja} paq. x ${producto.unidXPaquete} unid.';
    } else if (tipo == 'paquete') {
      return '${producto.unidXPaquete} unid.';
    }
    return '1 unid.';
  }

  String get nombre => producto.nombre;
}
