import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'boleta_provider.dart';

class PDFService {
  static Future<String> generateAndSaveBoleta(
    BoletaProvider boletaProvider,
    String businessName,
  ) async {
    print('=== PDF GENERATION START ===');
    
    try {
      // Step 1: Check if we have data
      print('Step 1: Checking boleta data...');
      if (boletaProvider.groupedItems.isEmpty) {
        throw Exception('No hay productos en la boleta');
      }
      print('✓ Data found: ${boletaProvider.groupedItems.length} product types');
      print('✓ Total items: ${boletaProvider.itemCount}');
      print('✓ Total price: ${boletaProvider.total}');

      // Step 2: Request permissions (with timeout)
      print('Step 2: Requesting permissions...');
      await _requestStoragePermission().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Permission request timed out, continuing anyway');
        },
      );
      print('✓ Permissions handled');

      // Step 3: Generate PDF (with timeout)
      print('Step 3: Generating PDF...');
      final pdf = await _generateBoletaPDF(boletaProvider, businessName).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('PDF generation timed out after 30 seconds');
        },
      );
      print('✓ PDF generated successfully');
      
      // Step 4: Save to device (with timeout)
      print('Step 4: Saving PDF to device...');
      final filePath = await _savePDFToDevice(pdf, boletaProvider).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception('PDF save timed out after 15 seconds');
        },
      );
      print('✓ PDF saved successfully to: $filePath');
      
      print('=== PDF GENERATION SUCCESS ===');
      return filePath;
      
    } catch (e, stackTrace) {
      print('=== PDF GENERATION ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> previewBoleta(
    BoletaProvider boletaProvider,
    String businessName,
  ) async {
    try {
      final pdf = await _generateBoletaPDF(boletaProvider, businessName);
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Boleta_${_getFormattedDateTime()}.pdf',
      );
    } catch (e) {
      print('Error in previewBoleta: $e');
      rethrow;
    }
  }

  static Future<pw.Document> _generateBoletaPDF(
    BoletaProvider boletaProvider,
    String businessName,
  ) async {
    print('  📄 Creating PDF document...');
    final pdf = pw.Document();
    final agrupados = boletaProvider.groupedItems;
    final agrupadosList = agrupados.entries.toList();
    final now = DateTime.now();
    
    // Skip Google Fonts to avoid network issues
    print('  📄 Using default fonts (skipping Google Fonts)...');
    
    try {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header - Simplified
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        businessName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'BOLETA DE VENTA',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Date and transaction info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Fecha: ${_getFormattedDate(now)}'),
                    pw.Text('Hora: ${_getFormattedTime(now)}'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('N° Transacción: BOL-${now.millisecondsSinceEpoch}'),
                pw.SizedBox(height: 20),

                // Products table header - Simplified
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          'PRODUCTO',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'CANT.',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'P. UNIT',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'SUBTOTAL',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                // Products list - Simplified
                pw.Column(
                  children: agrupadosList.map((entry) {
                    final producto = entry.key;
                    final cantidad = entry.value;
                    final subtotal = producto.precio * cantidad;

                    return pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(producto.nombre),
                                pw.Text(
                                  '${producto.tipo} (${producto.detalle})',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              cantidad.toString(),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'S/ ${producto.precio.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'S/ ${subtotal.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                pw.SizedBox(height: 20),

                // Totals - Simplified
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL DE ITEMS:'),
                          pw.Text(
                            '${boletaProvider.itemCount}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TOTAL A PAGAR:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'S/ ${boletaProvider.total.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Gracias por su compra',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('PDF generado el ${_getFormattedDateTime()}'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      print('  📄 PDF page added successfully');
      return pdf;
      
    } catch (e) {
      print('  ❌ Error creating PDF page: $e');
      rethrow;
    }
  }

  static Future<String> _savePDFToDevice(
    pw.Document pdf,
    BoletaProvider boletaProvider,
  ) async {
    try {
      print('  💾 Getting storage directory...');
      
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try simple approach first
        try {
          directory = await getExternalStorageDirectory();
          print('  💾 External storage: ${directory?.path}');
          
          if (directory != null) {
            directory = Directory('${directory.path}/Boletas');
            print('  💾 Creating Boletas directory: ${directory.path}');
            
            if (!await directory.exists()) {
              await directory.create(recursive: true);
              print('  💾 Directory created');
            } else {
              print('  💾 Directory already exists');
            }
          }
        } catch (e) {
          print('  ❌ External storage failed: $e');
          // Try app documents directory as fallback
          directory = await getApplicationDocumentsDirectory();
          directory = Directory('${directory.path}/Boletas');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      } else {
        // iOS
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/Boletas');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }

      if (directory == null) {
        throw Exception('No se pudo acceder al almacenamiento');
      }

      final fileName = 'Boleta_${_getFormattedDateTime()}.pdf';
      final file = File('${directory.path}/$fileName');
      
      print('  💾 Saving PDF to: ${file.path}');
      
      final pdfBytes = await pdf.save();
      print('  💾 PDF bytes generated: ${pdfBytes.length} bytes');
      
      await file.writeAsBytes(pdfBytes);
      print('  💾 File written successfully');
      
      // Verify file was created
      if (await file.exists()) {
        final fileSize = await file.length();
        print('  ✓ File verified - Size: $fileSize bytes');
        return file.path;
      } else {
        throw Exception('File was not created successfully');
      }
      
    } catch (e) {
      print('  ❌ Error in _savePDFToDevice: $e');
      rethrow;
    }
  }

  static Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        print('  🔐 Requesting storage permission...');
        final status = await Permission.storage.request();
        print('  🔐 Storage permission status: $status');
        
        // Don't throw error if permission denied, just log it
        if (status.isDenied) {
          print('  ⚠️ Storage permission denied, will try to save anyway');
        }
      } catch (e) {
        print('  ⚠️ Permission request failed: $e');
        // Continue without throwing error
      }
    }
  }

  // Helper methods remain the same
  static String _getFormattedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _getFormattedTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  static String _getFormattedDateTime() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }
}