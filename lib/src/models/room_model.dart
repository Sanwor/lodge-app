// lib/src/models/room_model.dart (simplified)
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  String? id;
  final String roomNumber;
  final String roomType;
  final double pricePerDay;
  final int capacity;
  final String description;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoomModel({
    this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerDay,
    required this.capacity,
    required this.description,
    this.isAvailable = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'roomType': roomType,
      'pricePerDay': pricePerDay,
      'capacity': capacity,
      'description': description,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      roomNumber: map['roomNumber'] ?? '',
      roomType: map['roomType'] ?? 'Standard',
      pricePerDay: (map['pricePerDay'] as num).toDouble(),
      capacity: map['capacity'] ?? 1,
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  RoomModel copyWith({
    String? roomNumber,
    String? roomType,
    double? pricePerDay,
    int? capacity,
    String? description,
    bool? isAvailable,
  }) {
    return RoomModel(
      id: id,
      roomNumber: roomNumber ?? this.roomNumber,
      roomType: roomType ?? this.roomType,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}