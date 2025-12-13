// lib/src/models/courier.dart
class Courier {
  final String id;
  final String name;
  final String phone;
  final double fixedFee;
  final double percentFee;

  Courier({
    required this.id,
    required this.name,
    required this.phone,
    required this.fixedFee,
    required this.percentFee,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'fixedFee': fixedFee,
      'percentFee': percentFee,
    };
  }

  factory Courier.fromMap(String id, Map<String, dynamic> map) {
    return Courier(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      fixedFee: (map['fixedFee'] ?? 0).toDouble(),
      percentFee: (map['percentFee'] ?? 0).toDouble(),
    );
  }
}
