import 'package:cloud_firestore/cloud_firestore.dart';

class Seat {
  final String id; // e.g., "A1", "B5"
  final String type; // standard | vip
  final bool isAvailable;
  
  // ✅ Optional: For detailed layout (can be parsed from id)
  String get row => id.substring(0, 1); // "A1" → "A"
  int get column => int.parse(id.substring(1)); // "A1" → 1

  Seat({
    required this.id,
    required this.type,
    required this.isAvailable,
  });

  factory Seat.fromMap(Map<String, dynamic> data) {
    return Seat(
      id: data['id'] ?? '',
      type: data['type'] ?? 'standard',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'isAvailable': isAvailable,
    };
  }
}

class Screen {
  final String id;
  final String theaterId;
  final String name;
  final String type; // ✅ NEW: 'standard' | 'vip' | 'imax'
  final int totalSeats;
  final int rows;
  final int columns;
  final List<Seat> seats;

  Screen({
    required this.id,
    required this.theaterId,
    required this.name,
    this.type = 'standard', // ✅ Default to standard
    required this.totalSeats,
    required this.rows,
    required this.columns,
    required this.seats,
  });

  factory Screen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> seatsData = data['seats'] ?? [];
    return Screen(
      id: doc.id,
      theaterId: data['theaterId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'standard', // ✅ Read from Firestore
      totalSeats: (data['totalSeats'] ?? 0).toInt(),
      rows: (data['rows'] ?? 0).toInt(),
      columns: (data['columns'] ?? 0).toInt(),
      seats: seatsData.map((e) => Seat.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theaterId': theaterId,
      'name': name,
      'type': type, // ✅ Save to Firestore
      'totalSeats': totalSeats,
      'rows': rows,
      'columns': columns,
      'seats': seats.map((e) => e.toMap()).toList(),
    };
  }
}
