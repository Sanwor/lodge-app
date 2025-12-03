import 'package:cloud_firestore/cloud_firestore.dart';

class GuestRecordModel {
  bool? hasCheckedOut;
  String? id;
  final String name;
  final String address;
  final String checkinDate;
  final String checkinTime;
  final String citizenshipNo;
  final String occupation;
  final String noPeople;
  final String relation;
  final String reason;
  final String contact;
  final String roomNo;
  final String? checkoutDate;
  final String? checkoutTime;
  final DateTime? createdAt; 
  final DateTime? updatedAt;

  GuestRecordModel({
    this.id,
    this.hasCheckedOut = false,
    required this.name,
    required this.address,
    required this.checkinDate,
    required this.checkinTime,
    required this.citizenshipNo,
    required this.occupation,
    required this.noPeople,
    required this.relation,
    required this.reason,
    required this.contact,
    required this.roomNo,
    this.checkoutDate,
    this.checkoutTime,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "hasCheckedOut": hasCheckedOut,
      "address": address,
      "checkinDate": checkinDate,
      "checkinTime": checkinTime,
      "citizenshipNo": citizenshipNo,
      "occupation": occupation,
      "noPeople": noPeople,
      "relation": relation,
      "reason": reason,
      "contact": contact,
      "roomNo": roomNo,
      "checkoutDate": checkoutDate,
      "checkoutTime": checkoutTime,
      "createdAt": createdAt ?? DateTime.now(),
      "updatedAt": DateTime.now(),
    };
  }

  // Add fromMap factory constructor for easier deserialization
  factory GuestRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return GuestRecordModel(
      hasCheckedOut: map["hasCheckedOut"],
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      checkinDate: map['checkinDate'] ?? '',
      checkinTime: map['checkinTime'] ?? '',
      citizenshipNo: map['citizenshipNo'] ?? '',
      occupation: map['occupation'] ?? '',
      noPeople: map['noPeople'] ?? '',
      relation: map['relation'] ?? '',
      reason: map['reason'] ?? '',
      contact: map['contact'] ?? '',
      roomNo: map['roomNo'] ?? '',
      checkoutDate: map['checkoutDate'],
      checkoutTime: map['checkoutTime'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
