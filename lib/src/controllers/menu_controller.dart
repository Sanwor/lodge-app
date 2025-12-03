// lib/src/controllers/menu_controller.dart
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:get/get.dart';
import '../models/menu_model.dart';

class MenusController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<MenuItemModel> menuItems = <MenuItemModel>[].obs;
  RxList<String> categories = <String>[].obs;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get menuCollection => _firestore.collection('menu_items');

  // Initialize categories
  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
  }

  void _initializeCategories() {
    categories.value = [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Snacks',
      'Beverages',
      'Desserts',
      'Other'
    ];
  }

  /// GET ALL MENU ITEMS
  Future<void> getAllMenuItems() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await menuCollection
          .orderBy('createdAt', descending: true)
          .get();

      menuItems.value = querySnapshot.docs.map((doc) {
        return MenuItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
    } catch (e) {
      log("Error fetching menu items: $e");
      menuItems.clear();
      showErrorToast(
        "Failed to load menu items",
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// GET MENU ITEMS BY CATEGORY
  Future<void> getMenuItemsByCategory(String category) async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await menuCollection
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      menuItems.value = querySnapshot.docs.map((doc) {
        return MenuItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
    } catch (e) {
      log("Error fetching menu items by category: $e");
      menuItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET AVAILABLE MENU ITEMS
  Future<void> getAvailableMenuItems() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot querySnapshot = await menuCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('category')
          .get();

      menuItems.value = querySnapshot.docs.map((doc) {
        return MenuItemModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
    } catch (e) {
      log("Error fetching available menu items: $e");
      menuItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// ADD NEW MENU ITEM
  Future<String?> addMenuItem(MenuItemModel menuItem) async {
    try {
      isLoading.value = true;
      
      DocumentReference docRef = await menuCollection.add(menuItem.toMap());
      
      await getAllMenuItems();
      
      showToast(
        "${menuItem.name} added successfully",
      );
      
      return docRef.id;
    } catch (e) {
      log("Error adding menu item: $e");
      showErrorToast(
        "Failed to add menu item: $e",
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// UPDATE MENU ITEM
  Future<bool> updateMenuItem(String id, MenuItemModel menuItem) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Menu item ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await menuCollection.doc(id).update(menuItem.toMap());
      
      await getAllMenuItems();
      
      showToast( 
        "${menuItem.name} updated successfully",
      );
      
      return true;
    } catch (e) {
      log("Error updating menu item: $e");
      showErrorToast(
        "Failed to update menu item: $e",
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// DELETE MENU ITEM
  Future<bool> deleteMenuItem(String id, String name) async {
    try {
      if (id.isEmpty) {
        showErrorToast("Menu item ID is required");
        return false;
      }
      
      isLoading.value = true;
      
      await menuCollection.doc(id).delete();
      
      menuItems.removeWhere((item) => item.id == id);
      
      showToast("$name deleted successfully");
      
      return true;
    } catch (e) {
      log("Error deleting menu item: $e");
      showErrorToast("Failed to delete menu item: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// TOGGLE MENU ITEM AVAILABILITY
  Future<bool> toggleMenuItemAvailability(String id, bool currentStatus) async {
    try {
      if (id.isEmpty) return false;
      
      await menuCollection.doc(id).update({
        'isAvailable': !currentStatus,
        'updatedAt': DateTime.now(),
      });
      
      // Update local list
      final index = menuItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        menuItems[index] = menuItems[index].copyWith(
          isAvailable: !currentStatus,
        );
        menuItems.refresh();
      }
      
      return true;
    } catch (e) {
      log("Error toggling menu item availability: $e");
      return false;
    }
  }

  /// ADD NEW CATEGORY
  void addCategory(String newCategory) {
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      categories.add(newCategory);
      categories.sort();
      categories.refresh();
    }
  }

  /// GET CATEGORY STATS
  Map<String, int> getCategoryStats() {
    Map<String, int> stats = {};
    
    for (var item in menuItems) {
      stats[item.category] = (stats[item.category] ?? 0) + 1;
    }
    
    return stats;
  }

  void clearData() {
    menuItems.clear();
    isLoading.value = false;
  }

  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}