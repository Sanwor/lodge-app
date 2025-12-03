class GuestRecordModel {
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
    };
  }

  // Optional: Create a copyWith method for easier updates
  GuestRecordModel copyWith({
    String? id,
    String? name,
    String? address,
    String? checkinDate,
    String? checkinTime,
    String? citizenshipNo,
    String? occupation,
    String? noPeople,
    String? relation,
    String? reason,
    String? contact,
    String? roomNo,
    String? checkoutDate,
    String? checkoutTime,
  }) {
    return GuestRecordModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      citizenshipNo: citizenshipNo ?? this.citizenshipNo,
      occupation: occupation ?? this.occupation,
      noPeople: noPeople ?? this.noPeople,
      relation: relation ?? this.relation,
      reason: reason ?? this.reason,
      contact: contact ?? this.contact,
      roomNo: roomNo ?? this.roomNo,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      checkoutTime: checkoutTime ?? this.checkoutTime,
    );
  }
}