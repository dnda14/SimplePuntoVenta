import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'producto.dart';

class ProductoService {
  // ADD THIS: Static variable to keep data in memory
  static List<Producto>? _cachedProducts;
  
  // ADD THIS: Check if we already have data loaded
  static bool get hasData => _cachedProducts != null && _cachedProducts!.isNotEmpty;

  // Method 1: Read from specific Downloads path (with permissions)
  static Future<List<Producto>> loadProductsFromDownloads() async {
    try {
      // Request storage permission
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final path = '/storage/emulated/0/Download/productos.json';
      final file = File(path);

      if (!await file.exists()) {
        throw Exception('El archivo productos.json no existe en $path');
      }

      final String response = await file.readAsString();
      final List<dynamic> data = json.decode(response);
      
      debugPrint('Parsed JSON: $data');
      
      final products = data.map((json) => Producto.fromJson(json)).toList();
      debugPrint('Number of products loaded: ${products.length}');
      
      // CACHE THE RESULTS
      _cachedProducts = products;
      
      return products;
    } catch (e, stackTrace) {
      debugPrint('Error loading products from Downloads: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Method 2: Let user pick the file (NO PERMISSIONS NEEDED)
  static Future<List<Producto>> loadProductsWithFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecciona el archivo productos.json',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String response = await file.readAsString();
        final List<dynamic> data = json.decode(response);
        
        final products = data.map((json) => Producto.fromJson(json)).toList();
        debugPrint('Number of products loaded: ${products.length}');
        
        // CACHE THE RESULTS
        _cachedProducts = products;
        
        return products;
      } else {
        throw Exception('No file selected');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading products with file picker: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Method 3: Read from app's documents directory (NO PERMISSIONS NEEDED)
  static Future<List<Producto>> loadProductsFromAppDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/productos.json';
      final file = File(path);

      if (!await file.exists()) {
        throw Exception('El archivo productos.json no existe en el directorio de la app');
      }

      final String response = await file.readAsString();
      final List<dynamic> data = json.decode(response);
      
      final products = data.map((json) => Producto.fromJson(json)).toList();
      debugPrint('Number of products loaded from app directory: ${products.length}');
      
      // CACHE THE RESULTS
      _cachedProducts = products;
      
      return products;
    } catch (e, stackTrace) {
      debugPrint('Error loading products from app directory: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // MODIFIED: Method 4 - Now checks cache first
  static Future<List<Producto>> loadProducts() async {
    // CHECK CACHE FIRST
    if (hasData) {
      debugPrint('Using cached products: ${_cachedProducts!.length}');
      return _cachedProducts!;
    }

    // No cached data, load from file
    debugPrint('No cached data, loading from external sources...');

    // Try app directory first (no permissions needed)
    try {
      return await loadProductsFromAppDirectory();
    } catch (e) {
      debugPrint('Failed to load from app directory: $e');
    }

    // Try file picker as fallback
    try {
      return await loadProductsWithFilePicker();
    } catch (e) {
      debugPrint('Failed to load with file picker: $e');
    }

    // Last resort: try Downloads folder
    try {
      return await loadProductsFromDownloads();
    } catch (e) {
      debugPrint('Failed to load from Downloads: $e');
      rethrow;
    }
  }

  // ADD THIS: Force reload from file (optional)
  static Future<List<Producto>> reloadFromFile() async {
    debugPrint('Force reloading from external file...');
    _cachedProducts = null; // Clear cache
    return await loadProducts();
  }

  // ADD THIS: Clear cached data (optional)
  static void clearCache() {
    _cachedProducts = null;
    debugPrint('Cache cleared - next load will ask for file');
  }

  // Helper method to copy file to app directory
  static Future<bool> copyFileToAppDirectory(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return false;

      final directory = await getApplicationDocumentsDirectory();
      final targetPath = '${directory.path}/productos.json';
      
      await sourceFile.copy(targetPath);
      return true;
    } catch (e) {
      debugPrint('Error copying file: $e');
      return false;
    }
  }

  // Helper method to request storage permission
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      // For Android 13+ (API 33+)
      if (!status.isGranted) {
        var mediaStatus = await Permission.manageExternalStorage.status;
        if (!mediaStatus.isGranted) {
          mediaStatus = await Permission.manageExternalStorage.request();
        }
        return mediaStatus.isGranted;
      }
      
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for app directories
  }
}