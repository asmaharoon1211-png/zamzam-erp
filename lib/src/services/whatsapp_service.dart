// lib/src/services/whatsapp_service.dart
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';

class WhatsAppService {
  Future<void> shareOrder(OrderModel order) async {
    // Construct message
    final buffer = StringBuffer();
    buffer.writeln('*ZAMZAM ERP Receipt*');
    buffer.writeln('Order #: ${order.id.substring(0, 5).toUpperCase()}');
    buffer.writeln('Date: ${order.date.toString().substring(0, 16)}');
    buffer.writeln('----------------');
    for (var item in order.items) {
      buffer.writeln('${item.productName} x${item.qty} - ${item.total}');
    }
    buffer.writeln('----------------');
    buffer.writeln('*Total: ${order.totalAmount}*');
    if (order.courierName != null) {
      buffer.writeln('Courier: ${order.courierName}');
    }
    buffer.writeln('Thank you!');

    final message = Uri.encodeComponent(buffer.toString());
    // Use a generic URL scheme that asks user to pick app if multiple, or direct to whatsapp
    // 'https://wa.me/?text=$message' is broad share
    final url = Uri.parse('https://wa.me/?text=$message');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }
}
