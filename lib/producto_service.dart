import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'producto.dart';

class ProductoService {
  static Future<List<Producto>> loadProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/productos.json');
      
      final List<dynamic> data = json.decode(response);
      debugPrint('Parsed JSON: $data'); // Debug print
      
      final products = data.map((json) => Producto.fromJson(json)).toList();
      debugPrint('Number of products loaded: ${products.length}');
      
      return products;
    } catch (e, stackTrace) {
      debugPrint('Error loading products: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}