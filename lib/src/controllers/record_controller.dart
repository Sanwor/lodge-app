import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:get/get.dart';

class GuestRecordController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<GuestRecordModel> records = <GuestRecordModel>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
      Get.snackbar(
        "Error", 
        "Failed to load records",
        snackPosition: SnackPosition.BOTTOM,
      );
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
        .orderBy('createdAt', descending: true) // Now this should work
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
        createdAt: doc['createdAt'] != null 
            ? (doc['createdAt'] as Timestamp).toDate()
            : null,
        updatedAt: doc['updatedAt'] != null 
            ? (doc['updatedAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();
    
  } catch (e) {
    log("Error fetching records by date: $e");
    
    // If still getting index error even after creation
    if (e.toString().contains('index')) {
      Get.snackbar(
        "Index Still Building", 
        "Please wait 1-2 minutes for the index to finish building",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      
      // Fallback: fetch without ordering
      await _getRecordsByDateWithoutOrdering(date);
    } else {
      records.clear();
      Get.snackbar(
        "Error", 
        "Failed to load records",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    isLoading.value = false;
  }
}

// Fallback method without ordering
Future<void> _getRecordsByDateWithoutOrdering(String date) async {
  try {
    QuerySnapshot querySnapshot = await recordsCollection
        .where('checkinDate', isEqualTo: date)
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
    
    // Sort locally
    tempRecords.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
    
    records.value = tempRecords;
    
  } catch (e) {
    log("Fallback fetch error: $e");
    records.clear();
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
    
    QuerySnapshot querySnapshot = await recordsCollection
        .where('checkoutDate', isEqualTo: null)
        .orderBy('checkinDate', descending: true) // This might need an index too
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
        createdAt: doc['createdAt'] != null 
            ? (doc['createdAt'] as Timestamp).toDate()
            : null,
      );
    }).toList();
    
  } catch (e) {
    log("Error fetching active records: $e");
    
    // If index error, fetch without ordering
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
      
      Get.snackbar(
        "Success", 
        "Record added successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return docRef.id;
    } catch (e) {
      log("Error adding record: $e");
      Get.snackbar(
        "Error", 
        "Failed to add record: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE RECORD
  Future<bool> updateRecord(String id, GuestRecordModel record) async {
    try {
      if (id.isEmpty) {
        Get.snackbar("Error", "Record ID is required");
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
      
      // Refresh the list
      await getAllRecords();
      
      Get.snackbar(
        "Success", 
        "Record updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      log("Error updating record: $e");
      Get.snackbar(
        "Error", 
        "Failed to update record: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE RECORD
  Future<bool> deleteRecord(String id) async {
    try {
      if (id.isEmpty) {
        Get.snackbar("Error", "Record ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await recordsCollection.doc(id).delete();
      
      // Remove from local list
      records.removeWhere((record) => record.id == id);
      
      Get.snackbar(
        "Success", 
        "Record deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      log("Error deleting record: $e");
      Get.snackbar(
        "Error", 
        "Failed to delete record: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// CHECKOUT GUEST
  Future<bool> checkoutGuest(String id, String checkoutDate, String checkoutTime) async {
    try {
      if (id.isEmpty) {
        Get.snackbar("Error", "Record ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await recordsCollection.doc(id).update({
        "checkoutDate": checkoutDate,
        "checkoutTime": checkoutTime,
        "updatedAt": DateTime.now(),
      });
      
      // Refresh the list
      await getAllRecords();
      
      Get.snackbar(
        "Success", 
        "Guest checked out successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      log("Error during checkout: $e");
      Get.snackbar(
        "Error", 
        "Failed to checkout guest: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
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