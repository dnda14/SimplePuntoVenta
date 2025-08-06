import 'package:flutter/foundation.dart';
class Producto {
  final String nombre;
  final double precioUnidad;
  final double? precioPaquete;
  final double? precioCaja;
  final int? unidXPaquete; // New: Items per pack (optional)
  final int? paqueteXCja; 


  Producto({
    required this.nombre, 
    required this.precioUnidad,
    this.precioPaquete,
    this.precioCaja,
    this.unidXPaquete,
    this.paqueteXCja,
});
bool get hasPack => precioPaquete != null;
  bool get hasBox => precioCaja != null;
  
  String get priceDisplay {
    String display = 'S/ $precioUnidad (unit)';
    if (hasPack) display += ' | S/ $precioPaquete (pack of ${unidXPaquete ?? 1})';
    if (hasBox) display += ' | S/ $precioCaja (box of ${paqueteXCja ?? 1} packs)';
    return display;
  }
  // Factory constructor for JSON parsing
  factory Producto.fromJson(Map<String, dynamic> json) {
  try {
    return Producto(
      nombre: json['nombre'] as String,
      precioUnidad: (json['precioUnidad'] as num).toDouble(),
      precioPaquete: json['precioPaquete'] != null 
          ? (json['precioPaquete'] as num).toDouble() 
          : null,
      precioCaja: json['precioCaja'] != null 
          ? (json['precioCaja'] as num).toDouble() 
          : null,
      unidXPaquete: json['unidXPaquete'] as int?,
      paqueteXCja: json['paqueteXCja'] as int?,
    );
  } catch (e, stackTrace) {
    debugPrint('Error parsing product: $e');
    debugPrint('JSON data: $json');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

  // Optional: Add a toJson method if you need to save data
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precioUnidad': precioUnidad,
      'precioPaquete': precioPaquete,
      'precioCaja': precioCaja,
      'unidXPaquete': unidXPaquete,
      'paqueteXCja': paqueteXCja,
    };
  }
}
