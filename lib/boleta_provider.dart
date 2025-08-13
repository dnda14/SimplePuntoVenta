import 'package:flutter/foundation.dart';
import 'item_boleta.dart';
import 'producto.dart';

class BoletaProvider with ChangeNotifier {
  List<ItemBoleta> _items = [];

  List<ItemBoleta> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  // Add item to boleta
  void addItem(Producto producto, String tipo, double cantidad) {
    final index = _items.indexWhere(
      (item) => item.producto.nombre == producto.nombre && item.tipo == tipo,
    );

    if (index != -1) {
      // Item already exists, update quantity
      _items[index] = ItemBoleta(
        producto: producto,
        tipo: tipo,
        cantidad: _items[index].cantidad + cantidad,
      );
    } else {
      // New item
      _items.add(
        ItemBoleta(producto: producto, tipo: tipo, cantidad: cantidad),
      );
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, double newQuantity) {
    if (index >= 0 && index < _items.length) {
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        final item = _items[index];
        _items[index] = ItemBoleta(
          producto: item.producto,
          tipo: item.tipo,
          cantidad: newQuantity,
        );
        notifyListeners();
      }
    }
  }

  void clearBoleta() {
    _items.clear();
    notifyListeners();
  }

  Map<_ProductoAgrupado, double> get groupedItems {
    final Map<_ProductoAgrupado, double> agrupados = {};

    for (var item in _items) {
      final key = _ProductoAgrupado(
        nombre: item.nombre,
        tipo: item.tipo,
        precio: item.precioUnitario,
        detalle: item.detalle,
      );
      agrupados.update(
        key,
        (cantidad) => cantidad + item.cantidad,
        ifAbsent: () => item.cantidad,
      );
    }

    return agrupados;
  }
}

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