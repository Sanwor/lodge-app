// lib/src/controllers/room_controller.dart
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:get/get.dart';
import '../models/room_model.dart';

class RoomController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<RoomModel> rooms = <RoomModel>[].obs;
  RxList<String> roomTypes = <String>[].obs;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get roomsCollection => _firestore.collection('rooms');

  // Initialize room types
  @override
  void onInit() {
    super.onInit();
    _initializeRoomTypes();
  }

  void _initializeRoomTypes() {
    roomTypes.value = [
      'Standard',
      'Deluxe',
      'Suite',
      'Family',
      'Executive',
      'Other'
    ];
  }

  /// GET ALL ROOMS
  Future<void> getAllRooms() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await roomsCollection
          .orderBy('roomNumber')
          .get();

      rooms.value = querySnapshot.docs.map((doc) {
        return RoomModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
    } catch (e) {
      log("Error fetching rooms: $e");
      rooms.clear();
      showErrorToast("Failed to load rooms");
    } finally {
      isLoading.value = false;
    }
  }

  /// GET ROOMS BY TYPE
  Future<void> getRoomsByType(String type) async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await roomsCollection
          .where('roomType', isEqualTo: type)
          .orderBy('roomNumber')
          .get();

      rooms.value = querySnapshot.docs.map((doc) {
        return RoomModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
    } catch (e) {
      log("Error fetching rooms by type: $e");
      rooms.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// ADD NEW ROOM
  Future<String?> addRoom(RoomModel room) async {
    try {
      // Check if room number already exists
      final existingRoom = await _getRoomByNumber(room.roomNumber);
      if (existingRoom != null) {
        showErrorToast("Room ${room.roomNumber} already exists");
        return null;
      }
      
      isLoading.value = true;
      
      DocumentReference docRef = await roomsCollection.add(room.toMap());

      Get.back();
      
      await getAllRooms();
      
      showToast("Room ${room.roomNumber} added successfully");
      
      return docRef.id;
    } catch (e) {
      log("Error adding room: $e");
      showErrorToast("Failed to add room: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE ROOM
  Future<bool> updateRoom(String id, RoomModel room) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Room ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await roomsCollection.doc(id).update(room.toMap());

      Get.back();
      
      await getAllRooms();
      
      showToast("Room ${room.roomNumber} updated successfully",);
      
      return true;
    } catch (e) {
      log("Error updating room: $e");
      showErrorToast("Failed to update room: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// DELETE ROOM
  Future<bool> deleteRoom(String id, String roomNumber) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Room ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await roomsCollection.doc(id).delete();
      
      rooms.removeWhere((room) => room.id == id);

      Get.back();
      
      await getAllRooms();
      
      showToast("Room $roomNumber deleted successfully");
      
      return true;
    } catch (e) {
      log("Error deleting room: $e");
      showErrorToast("Failed to delete room: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// TOGGLE ROOM AVAILABILITY
  Future<bool> toggleRoomAvailability(String id, bool currentStatus) async {
    try {
      if (id.isEmpty) return false;
      
      await roomsCollection.doc(id).update({
        'isAvailable': !currentStatus,
        'updatedAt': DateTime.now(),
      });
      
      // Update local list
      final index = rooms.indexWhere((room) => room.id == id);
      if (index != -1) {
        rooms[index] = rooms[index].copyWith(
          isAvailable: !currentStatus,
        );
        rooms.refresh();
      }
      
      return true;
    } catch (e) {
      log("Error toggling room availability: $e");
      return false;
    }
  }

  /// GET ROOM BY NUMBER
  Future<RoomModel?> _getRoomByNumber(String roomNumber) async {
    try {
      QuerySnapshot querySnapshot = await roomsCollection
          .where('roomNumber', isEqualTo: roomNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      
      return RoomModel.fromMap(
        querySnapshot.docs.first.id,
        querySnapshot.docs.first.data() as Map<String, dynamic>
      );
    } catch (e) {
      log("Error getting room by number: $e");
      return null;
    }
  }

  /// GET AVAILABLE ROOMS
  List<RoomModel> getAvailableRooms() {
    return rooms.where((room) => room.isAvailable).toList();
  }

  /// GET ROOM TYPE STATS
  Map<String, int> getRoomTypeStats() {
    Map<String, int> stats = {};
    
    for (var room in rooms) {
      stats[room.roomType] = (stats[room.roomType] ?? 0) + 1;
    }
    
    return stats;
  }

  /// GET TOTAL ROOMS COUNT
  int getTotalRooms() {
    return rooms.length;
  }

  /// GET TOTAL CAPACITY
  int getTotalCapacity() {
    return rooms.fold(0, (int sum, room) => sum + room.capacity);
  }

  void clearData() {
    rooms.clear();
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}