import 'package:cloud_firestore/cloud_firestore.dart';

class Theater {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final List<String> screens; // Danh sách ID phòng chiếu

  Theater({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.screens,
  });

  factory Theater.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Theater(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      screens: List<String>.from(data['screens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'screens': screens,
    };
  }
}
