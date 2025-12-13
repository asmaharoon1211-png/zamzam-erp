// lib/src/models/cart_item.dart
class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int qty;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
  });

  double get total => price * qty;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'qty': qty,
      'total': total,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      qty: (map['qty'] ?? 0).toInt(),
    );
  }
}
