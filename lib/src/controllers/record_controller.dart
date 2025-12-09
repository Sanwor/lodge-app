import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_home/src/controllers/room_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GuestRecordController extends GetxController {
  RoomController roomController = Get.put(RoomController());

  RxBool isLoading = false.obs;
  RxList<GuestRecordModel> records = <GuestRecordModel>[].obs;
  RxList<String> availableRooms = <String>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // GET AVAILABLE ROOMS
  Future<void> getAvailableRooms() async {
    try {
      var roomsSnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .orderBy('roomNumber')
          .get();

      var activeGuests = await recordsCollection
          .where('checkoutDate', isNull: true) // only guests NOT checked out
          .get();

      // Extract occupied rooms
      List<String> occupiedRooms = activeGuests.docs
          .map((doc) => doc['roomNo'] as String)
          .where((room) => room.isNotEmpty)
          .toList();

      // All rooms
      List<String> allRooms = roomsSnapshot.docs
          .map((doc) => doc['roomNumber'] as String)
          .where((room) => room.isNotEmpty)
          .toList();

      // Filter available rooms
      List<String> available = allRooms
          .where((room) => !occupiedRooms.contains(room))
          .toList()
        ..sort();

      // Update observable list
      if (available.isEmpty) {
        availableRooms.value = ["No Rooms Available"];
      } else {
        availableRooms.value = available;
      }
    } catch (e) {
      log("Error fetching available rooms: $e");
      availableRooms.clear();
    }
  }


  // Collection reference
  CollectionReference get recordsCollection => _firestore.collection('guest_records');

  /// GET ALL RECORDS
  Future<void> getAllRecords() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await recordsCollection
          .orderBy('createdAt', descending: true)
          .get();

      records.value = querySnapshot.docs.map((doc) {
        return GuestRecordModel(
          id: doc.id,
          name: doc['name'],
          address: doc['address'],
          checkinDate: doc['checkinDate'],
          checkinTime: doc['checkinTime'],
          citizenshipNo: doc['citizenshipNo'],
          occupation: doc['occupation'],
          noPeople: doc['noPeople'],
          relation: doc['relation'],
          reason: doc['reason'],
          contact: doc['contact'],
          roomNo: doc['roomNo'],
          checkoutDate: doc['checkoutDate'],
          checkoutTime: doc['checkoutTime'],
        );
      }).toList();
      
    } catch (e) {
      log("Error fetching records: $e");
      records.clear();
      showErrorToast("Failed to load records",);
    } finally {
      isLoading.value = false;
    }
  }

  /// GET RECORDS BY DATE (Now with ordering since index is created)
  Future<void> getRecordsByDate(String date) async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await recordsCollection
          .where('checkinDate', isEqualTo: date)
          .orderBy('createdAt', descending: true)
          .get();

      records.value = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Convert checkinDate if it's Timestamp
        String checkinDate;
        if (data['checkinDate'] is Timestamp) {
          checkinDate = (data['checkinDate'] as Timestamp).toDate().toString().split(' ')[0];
        } else {
          checkinDate = data['checkinDate'].toString();
        }
        
        // Convert checkoutDate if it's Timestamp
        String? checkoutDate;
        if (data['checkoutDate'] != null) {
          if (data['checkoutDate'] is Timestamp) {
            checkoutDate = (data['checkoutDate'] as Timestamp).toDate().toString();
          } else {
            checkoutDate = data['checkoutDate'].toString();
          }
        }
        
        return GuestRecordModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          address: data['address']?.toString() ?? '',
          checkinDate: checkinDate,
          checkinTime: data['checkinTime']?.toString() ?? '',
          citizenshipNo: data['citizenshipNo']?.toString() ?? '',
          occupation: data['occupation']?.toString() ?? '',
          noPeople: data['noPeople']?.toString() ?? '',
          relation: data['relation']?.toString() ?? '',
          reason: data['reason']?.toString() ?? '',
          contact: data['contact']?.toString() ?? '',
          roomNo: data['roomNo']?.toString() ?? '',
          checkoutDate: checkoutDate,
          checkoutTime: data['checkoutTime']?.toString(),
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
          updatedAt: data['updatedAt'] != null 
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
      
    } catch (e) {
      log("Error fetching records by date: $e");
      records.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET RECORDS BY ROOM NUMBER
  Future<List<GuestRecordModel>> getRecordsByRoom(String roomNo) async {
    try {
      QuerySnapshot querySnapshot = await recordsCollection
          .where('roomNo', isEqualTo: roomNo)
          .orderBy('checkinDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return GuestRecordModel(
          id: doc.id,
          name: doc['name'],
          address: doc['address'],
          checkinDate: doc['checkinDate'],
          checkinTime: doc['checkinTime'],
          citizenshipNo: doc['citizenshipNo'],
          occupation: doc['occupation'],
          noPeople: doc['noPeople'],
          relation: doc['relation'],
          reason: doc['reason'],
          contact: doc['contact'],
          roomNo: doc['roomNo'],
          checkoutDate: doc['checkoutDate'],
          checkoutTime: doc['checkoutTime'],
        );
      }).toList();
      
    } catch (e) {
      log("Error fetching records by room: $e");
      return [];
    }
  }

  /// GET ACTIVE RECORDS
Future<void> getActiveRecords() async {
  try {
    isLoading.value = true;
    records.clear();

    // Fetch only guests who have NOT checked out
    QuerySnapshot querySnapshot = await recordsCollection
        .where('hasCheckedOut', isEqualTo: false)
        .orderBy('checkinDate', descending: true)
        .get();

    records.value = querySnapshot.docs.map((doc) {
      return GuestRecordModel(
        id: doc.id,
        hasCheckedOut: doc['hasCheckedOut'],
        name: doc['name'],
        address: doc['address'],
        checkinDate: doc['checkinDate'],
        checkinTime: doc['checkinTime'],
        citizenshipNo: doc['citizenshipNo'],
        occupation: doc['occupation'],
        noPeople: doc['noPeople'],
        relation: doc['relation'],
        reason: doc['reason'],
        contact: doc['contact'],
        roomNo: doc['roomNo'],
        checkoutDate: doc['checkoutDate'],
        checkoutTime: doc['checkoutTime'],
        createdAt: doc['createdAt'] != null
            ? (doc['createdAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();

  } catch (e) {
    log("Error fetching active records: $e");

    // Fix for Firestore index error
    if (e.toString().contains('index')) {
      await _getActiveRecordsWithoutOrdering();
    } else {
      records.clear();
    }
  } finally {
    isLoading.value = false;
  }
}

  // Fallback for active records
  Future<void> _getActiveRecordsWithoutOrdering() async {
    try {
      QuerySnapshot querySnapshot = await recordsCollection
          .where('checkoutDate', isEqualTo: null)
          .get();

      List<GuestRecordModel> tempRecords = querySnapshot.docs.map((doc) {
        return GuestRecordModel(
          id: doc.id,
          name: doc['name'],
          address: doc['address'],
          checkinDate: doc['checkinDate'],
          checkinTime: doc['checkinTime'],
          citizenshipNo: doc['citizenshipNo'],
          occupation: doc['occupation'],
          noPeople: doc['noPeople'],
          relation: doc['relation'],
          reason: doc['reason'],
          contact: doc['contact'],
          roomNo: doc['roomNo'],
          checkoutDate: doc['checkoutDate'],
          checkoutTime: doc['checkoutTime'],
          createdAt: doc['createdAt'] != null 
              ? (doc['createdAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
      
      // Sort locally by checkinDate
      tempRecords.sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
      
      records.value = tempRecords;
      
    } catch (e) {
      log("Fallback active records error: $e");
      records.clear();
    }
  }

  /// ADD NEW RECORD
  Future<String?> addRecord(GuestRecordModel record) async {
    try {
      isLoading.value = true;
      
      DocumentReference docRef = await recordsCollection.add(record.toMap());
      
      
      // Refresh the list
      await getAllRecords();
      
      showToast("Record added successfully");
      
      return docRef.id;
    } catch (e) {
      log("Error adding record: $e");
      showErrorToast("Failed to add record: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE RECORD
  Future<bool> updateRecord(String id, GuestRecordModel record) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Record ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      // Create update map excluding createdAt (we'll update updatedAt instead)
      Map<String, dynamic> updateData = {
        "name": record.name,
        "address": record.address,
        "checkinDate": record.checkinDate,
        "checkinTime": record.checkinTime,
        "citizenshipNo": record.citizenshipNo,
        "occupation": record.occupation,
        "noPeople": record.noPeople,
        "relation": record.relation,
        "reason": record.reason,
        "contact": record.contact,
        "roomNo": record.roomNo,
        "checkoutDate": record.checkoutDate,
        "checkoutTime": record.checkoutTime,
        "updatedAt": DateTime.now(),
      };
      
      await recordsCollection.doc(id).update(updateData);

      Get.back();
      
      // Refresh the list
      await getAllRecords();
      
      showToast("Record updated successfully");
      
      return true;
    } catch (e) {
      log("Error updating record: $e");
      showErrorToast("Failed to update record: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE RECORD
  Future<bool> deleteRecord(String id) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Record ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await recordsCollection.doc(id).delete();
      
      // Remove from local list
      records.removeWhere((record) => record.id == id);

      Get.back();

      // Refresh the list
      await getAllRecords();
      
      showToast("Record deleted successfully");
      
      return true;
    } catch (e) {
      log("Error deleting record: $e");
      showErrorToast("Failed to delete record: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// CHECKOUT GUEST
  Future<bool> checkoutGuest(String guestId, String checkoutDate, String checkoutTime) async {
    try {
      if (guestId.isEmpty) return false;
      
      // Update guest record
      await recordsCollection.doc(guestId).update({
        'checkoutDate': checkoutDate,
        'checkoutTime': checkoutTime,
        'hasCheckedOut': true, // Add this field
        'updatedAt': DateTime.now(),
      });
      
      // Refresh data
      await getAllRecords();
      
      return true;
    } catch (e) {
      log("Checkout error: $e");
      return false;
    }
  }


  /// SEARCH RECORDS
  Future<void> searchRecords(String query) async {
    try {
      if (query.isEmpty) {
        await getAllRecords(); // Reset to all records
        return;
      }
      
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await recordsCollection.get();
      
      List<GuestRecordModel> allRecords = querySnapshot.docs.map((doc) {
        return GuestRecordModel(
          id: doc.id,
          name: doc['name'],
          address: doc['address'],
          checkinDate: doc['checkinDate'],
          checkinTime: doc['checkinTime'],
          citizenshipNo: doc['citizenshipNo'],
          occupation: doc['occupation'],
          noPeople: doc['noPeople'],
          relation: doc['relation'],
          reason: doc['reason'],
          contact: doc['contact'],
          roomNo: doc['roomNo'],
          checkoutDate: doc['checkoutDate'],
          checkoutTime: doc['checkoutTime'],
        );
      }).toList();
      
      // Filter records based on query (search in multiple fields)
      final filtered = allRecords.where((record) =>
          record.name.toLowerCase().contains(query.toLowerCase()) ||
          record.address.toLowerCase().contains(query.toLowerCase()) ||
          record.roomNo.toLowerCase().contains(query.toLowerCase()) ||
          record.citizenshipNo.toLowerCase().contains(query.toLowerCase()) ||
          record.contact.toLowerCase().contains(query.toLowerCase()))
        .toList();
      
      records.value = filtered;
      
    } catch (e) {
      log("Error searching records: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// GET SINGLE RECORD BY ID
  Future<GuestRecordModel?> getRecordById(String id) async {
    try {
      if (id.isEmpty) return null;
      
      DocumentSnapshot doc = await recordsCollection.doc(id).get();
      
      if (!doc.exists) return null;
      
      return GuestRecordModel(
        id: doc.id,
        name: doc['name'],
        address: doc['address'],
        checkinDate: doc['checkinDate'],
        checkinTime: doc['checkinTime'],
        citizenshipNo: doc['citizenshipNo'],
        occupation: doc['occupation'],
        noPeople: doc['noPeople'],
        relation: doc['relation'],
        reason: doc['reason'],
        contact: doc['contact'],
        roomNo: doc['roomNo'],
        checkoutDate: doc['checkoutDate'],
        checkoutTime: doc['checkoutTime'],
      );
    } catch (e) {
      log("Error getting record by ID: $e");
      return null;
    }
  }

  //GET BOOKINGS FOR CALENDAR
  Future<Map<DateTime, List<GuestRecordModel>>> getCalendarBookings() async {
    try {
      QuerySnapshot querySnapshot = await recordsCollection.get();
      
      Map<DateTime, List<GuestRecordModel>> events = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final record = GuestRecordModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          address: data['address']?.toString() ?? '',
          checkinDate: data['checkinDate']?.toString() ?? '',
          checkinTime: data['checkinTime']?.toString() ?? '',
          citizenshipNo: data['citizenshipNo']?.toString() ?? '',
          occupation: data['occupation']?.toString() ?? '',
          noPeople: data['noPeople']?.toString() ?? '',
          relation: data['relation']?.toString() ?? '',
          reason: data['reason']?.toString() ?? '',
          contact: data['contact']?.toString() ?? '',
          roomNo: data['roomNo']?.toString() ?? '',
          status: data['status']?.toString() ?? '',
          checkoutDate: data['checkoutDate']?.toString(),
          checkoutTime: data['checkoutTime']?.toString(),
        );
        
        // Parse checkin date
        try {
          final checkinDate = DateFormat('yyyy-MM-dd').parse(record.checkinDate);
          final dateKey = DateTime(checkinDate.year, checkinDate.month, checkinDate.day);
          
          if (!events.containsKey(dateKey)) {
            events[dateKey] = [];
          }
          events[dateKey]!.add(record);
        } catch (e) {
          continue;
        }
      }
      
      return events;
    } catch (e) {
      log("Error fetching calendar bookings: $e");
      return {};
    }
  }

  /// CLEAR CONTROLLER DATA
  void clearData() {
    records.clear();
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}