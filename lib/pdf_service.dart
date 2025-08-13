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
    try {
      print('Starting PDF generation...');
      
      // Request storage permission
      await _requestStoragePermission();
      print('Permissions granted');

      // Generate PDF
      final pdf = await _generateBoletaPDF(boletaProvider, businessName);
      print('PDF generated successfully');
      
      // Save to device
      final filePath = await _savePDFToDevice(pdf, boletaProvider);
      print('PDF saved successfully to: $filePath');
      
      // Return file path
      return filePath;
      
    } catch (e) {
      print('Error in PDF generation: $e');
      throw Exception('Error generando PDF: $e');
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
      throw Exception('Error previsualizando PDF: $e');
    }
  }

  static Future<pw.Document> _generateBoletaPDF(
    BoletaProvider boletaProvider,
    String businessName,
  ) async {
    final pdf = pw.Document();
    final agrupados = boletaProvider.groupedItems;
    final agrupadosList = agrupados.entries.toList();
    final now = DateTime.now();
    
    // Load fonts with error handling
    pw.Font? font;
    pw.Font? fontBold;
    
    try {
      font = await PdfGoogleFonts.nunitoRegular();
      fontBold = await PdfGoogleFonts.nunitoBold();
    } catch (e) {
      print('Error loading fonts, using default: $e');
      // Will use default fonts if Google Fonts fail
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      businessName,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'BOLETA DE VENTA',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 18,
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
                  pw.Text(
                    'Fecha: ${_getFormattedDate(now)}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                  pw.Text(
                    'Hora: ${_getFormattedTime(now)}',
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'N° Transacción: BOL-${now.millisecondsSinceEpoch}',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Products table header
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'PRODUCTO',
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'CANTIDAD',
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'P. UNIT',
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'SUBTOTAL',
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Products list
              pw.Column(
                children: agrupadosList.map((entry) {
                  final producto = entry.key;
                  final cantidad = entry.value;
                  final subtotal = producto.precio * cantidad;

                  return pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.grey400),
                        right: pw.BorderSide(color: PdfColors.grey400),
                        bottom: pw.BorderSide(color: PdfColors.grey400),
                      ),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 4,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    producto.nombre,
                                    style: pw.TextStyle(font: fontBold, fontSize: 11),
                                  ),
                                  pw.Text(
                                    '${producto.tipo} (${producto.detalle})',
                                    style: pw.TextStyle(font: font, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                cantidad.toString(),
                                style: pw.TextStyle(font: font, fontSize: 11),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                'S/ ${producto.precio.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font, fontSize: 11),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                'S/ ${subtotal.toStringAsFixed(2)}',
                                style: pw.TextStyle(font: font, fontSize: 11),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.SizedBox(height: 20),

              // Totals
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green200),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL DE ITEMS:',
                          style: pw.TextStyle(font: font, fontSize: 14),
                        ),
                        pw.Text(
                          '${boletaProvider.itemCount}',
                          style: pw.TextStyle(font: fontBold, fontSize: 14),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.green300),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL A PAGAR:',
                          style: pw.TextStyle(font: fontBold, fontSize: 18),
                        ),
                        pw.Text(
                          'S/ ${boletaProvider.total.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 20,
                            color: PdfColors.green700,
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
                      style: pw.TextStyle(font: fontBold, fontSize: 16),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'PDF generado el ${_getFormattedDateTime()}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<String> _savePDFToDevice(
    pw.Document pdf,
    BoletaProvider boletaProvider,
  ) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try multiple approaches for Android
        try {
          // First, try to use Downloads directory (most accessible)
          directory = Directory('/storage/emulated/0/Download/Boletas');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } catch (e) {
          print('Could not access Downloads, trying external storage: $e');
          // Fallback to external storage directory
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Boletas');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        }
      } else {
        // For iOS
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
      
      print('Attempting to save PDF to: ${file.path}');
      
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      
      print('PDF saved successfully to: ${file.path}');
      return file.path;
      
    } catch (e) {
      print('Error in _savePDFToDevice: $e');
      throw Exception('Error guardando PDF: $e');
    }
  }

  static Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 11+ (API 30+), request different permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      print('Permission statuses: $statuses');

      // Check if we have at least one permission granted
      bool hasPermission = statuses[Permission.storage]?.isGranted == true ||
          statuses[Permission.manageExternalStorage]?.isGranted == true;

      if (!hasPermission) {
        // Try requesting photos permission as fallback
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied) {
          throw Exception('Se necesitan permisos de almacenamiento para guardar el PDF');
        }
      }
    }
  }

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