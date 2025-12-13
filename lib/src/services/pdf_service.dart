// lib/src/services/pdf_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../features/inventory/data/inventory_repository.dart';
import '../models/order_model.dart';
import '../core/constants.dart';

class PdfService {
  Future<Uint8List> generateInvoice(OrderModel order) async {
    final pdf = pw.Document();

    // Use a default font if needed, or Printing will handle it
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer width usually
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ZAMZAM ERP', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.Divider(),
              pw.Text('Order #: ${order.id.substring(0, 5).toUpperCase()}'),
              pw.Text('Date: ${order.date.toString().substring(0, 16)}'),
              if (order.courierName != null) pw.Text('Courier: ${order.courierName}'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Item', 'Qty', 'Total'],
                  ...order.items.map((e) => [e.productName, e.qty.toString(), e.total.toString()])
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:'),
                  pw.Text('${order.totalAmount}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text('Thank you!', style: const pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printInvoice(OrderModel order) async {
    final pdfData = await generateInvoice(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData, 
      name: 'Invoice_${order.id}'
    );
  }
}
