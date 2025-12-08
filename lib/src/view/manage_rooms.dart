// lib/src/view/manage_room.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/controllers/room_controller.dart';
import 'package:family_home/src/models/room_model.dart';
import 'package:family_home/src/widget/custom_button.dart';
import 'package:family_home/src/widget/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ManageRoom extends StatefulWidget {
  const ManageRoom({super.key});

  @override
  State<ManageRoom> createState() => _ManageRoomState();
}

class _ManageRoomState extends State<ManageRoom> {
  final RoomController roomController = Get.put(RoomController());
  final GuestRecordController recordController = Get.find<GuestRecordController>();

  @override
  void initState() {
    super.initState();
    roomController.getAllRooms();
    roomController.getOccupiedRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        child: Icon(Icons.add, color: white, size: 24.w),
        onPressed: () => _showAddDialog(),
      ),
      body: roomList(),
    );
  }

  //app bar
  appBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txtBlack),
      title: Text(
        "Manage Rooms",
        style: interBold(size: 18.sp, color: txtBlack),
      ),
    );
  }

  //floating action button function
  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final roomNumberController = TextEditingController();
    final priceController = TextEditingController();
    final capacityController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedRoomType = roomController.roomTypes.first;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- TITLE ----------
              Center(
                child: Text(
                  "Add New Room",
                  style: interBold(size: 18.sp, color: txtBlack),
                ),
              ),

              SizedBox(height: 20.h),

              /// ---------- FORM ----------
              Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: roomNumberController,
                      headingText: "Room Number *",
                      validator: (value) =>
                          (value == null || value.isEmpty) ? "Please enter room number" : null,
                    ),
                    SizedBox(height: 16.h),

                    StatefulBuilder(
                      builder: (context, setStateSB) {
                        return _buildRoomTypeDropdown(
                          value: selectedRoomType,
                          onChanged: (value) {
                            setStateSB(() {
                              selectedRoomType = value!;
                            });
                          },
                        );
                      },
                    ),

                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: priceController,
                            headingText: "Price/Day (Rs.) *",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Please enter price";
                              if (double.tryParse(value) == null) return "Enter valid price";
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CustomTextFormField(
                            controller: capacityController,
                            headingText: "Capacity *",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Please enter capacity";
                              if (int.tryParse(value) == null) return "Enter valid capacity";
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    CustomTextFormField(
                      controller: descriptionController,
                      headingText: "Description",
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ---------- BUTTONS ----------
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: interMedium(size: 14.sp, color: txtGrey2),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newRoom = RoomModel(
                            roomNumber: roomNumberController.text,
                            roomType: selectedRoomType,
                            pricePerDay: double.parse(priceController.text),
                            capacity: int.parse(capacityController.text),
                            description: descriptionController.text,
                          );

                          await roomController.addRoom(newRoom);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Add Room",
                        style: interMedium(size: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ROOM LIST
  Widget roomList() {
    return Obx(() {
      if (roomController.isLoading.isTrue) {
        return const Center(child: CircularProgressIndicator());
      }

      if (roomController.rooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.meeting_room, size: 80.w, color: txtGrey2),
              SizedBox(height: 16.h),
              Text(
                "No rooms found",
                style: interMedium(size: 16.sp, color: txtGrey2),
              ),
              SizedBox(height: 8.h),
              Text(
                "Add your first room using the + button",
                style: interRegular(size: 14.sp, color: txtGrey2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => roomController.getAllRooms(),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemCount: roomController.rooms.length,
          itemBuilder: (context, index) {
            final room = roomController.rooms[index];
            return _buildRoomCard(room);
          },
        ),
      );
    });
  }

  // ============ HELPER WIDGETS ============
  Widget _buildRoomTypeDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Room Type *",
          style: interRegular(size: 12.sp, color: txtGrey7),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xff808084)),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              icon: Icon(Icons.arrow_drop_down, color: txtGrey2),
              items: roomController.roomTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: interRegular(size: 14.sp)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildRoomCard(RoomModel room) {
  return FutureBuilder<bool>(
    future: _checkRoomOccupancy(room.roomNumber),
    builder: (context, snapshot) {
      bool isOccupied = snapshot.data ?? false;
      bool isLoading = snapshot.connectionState == ConnectionState.waiting;
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Room Icon
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.meeting_room, color: orange, size: 30.w),
                  ),
                  SizedBox(width: 16.w),
                  
                  // Room Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Room ${room.roomNumber}",
                              style: interBold(size: 16.sp, color: txtBlack),
                            ),
                            if (isLoading)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                child: SizedBox(
                                  width: 12.w,
                                  height: 12.w,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isOccupied
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  isOccupied ? 'Occupied' : 'Available',
                                  style: interMedium(
                                    size: 12.sp,
                                    color: isOccupied ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          room.roomType,
                          style: interMedium(size: 14.sp, color: txtBlue),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          room.description,
                          style: interRegular(size: 14.sp, color: txtGrey2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, size: 14.w, color: txtGrey2),
                                SizedBox(width: 4.w),
                                Text(
                                  "${room.capacity} Persons",
                                  style: interRegular(size: 12.sp, color: txtGrey2),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              'Rs. ${room.pricePerDay.toStringAsFixed(0)}/day',
                              style: interBold(size: 16.sp, color: orange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              SizedBox(height: 12.h),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 8.h),
              
              Row(
                children: [
                  // Edit Button
                  Expanded(
                    child: CustomButton(
                      text: "Edit Room",
                      color: isOccupied ? Colors.grey : txtBlue,
                      onTap: isOccupied ? null : () => _showEditDialog(room),
                      height: 40.h,
                      width: 80.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  
                  // Delete Button
                  Expanded(
                    child: CustomButton(
                      text: "Delete",
                      color: isOccupied ? Colors.grey : Colors.red,
                      onTap: isOccupied ? null : () => _showDeleteDialog(room),
                      height: 40.h,
                      width: 80.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


  // Helper method
  Future<bool> _checkRoomOccupancy(String roomNumber) async {
    try {
      // First check active records locally
      final recordController = Get.find<GuestRecordController>();
      bool hasLocalOccupancy = recordController.records.any((record) =>
          record.roomNo == roomNumber &&
          (record.checkoutDate == null || record.checkoutDate!.isEmpty));
      
      if (hasLocalOccupancy) return true;
      
      // If not found locally, check Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('guest_records')
          .where('roomNo', isEqualTo: roomNumber)
          .where('checkoutDate', whereIn: [null, ''])
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking occupancy for room $roomNumber: $e");
      return false;
    }
  }

  //edit room dialogue
  void _showEditDialog(RoomModel room) {
  final formKey = GlobalKey<FormState>();
  final roomNumberController = TextEditingController(text: room.roomNumber);
  final priceController = TextEditingController(text: room.pricePerDay.toString());
  final capacityController = TextEditingController(text: room.capacity.toString());
  final descriptionController = TextEditingController(text: room.description);

  String selectedRoomType = room.roomType;

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- TITLE ----------
            Center(
              child: Text(
                "Edit Room",
                style: interBold(size: 18.sp, color: txtBlack),
              ),
            ),

            SizedBox(height: 20.h),

            /// ---------- FORM ----------
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: roomNumberController,
                    headingText: "Room Number *",
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? "Please enter room number"
                            : null,
                  ),
                  SizedBox(height: 16.h),

                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return _buildRoomTypeDropdown(
                        value: selectedRoomType,
                        onChanged: (v) {
                          setStateSB(() {
                            selectedRoomType = v!;
                          });
                        },
                      );
                    },
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: priceController,
                          headingText: "Price/Day (Rs.) *",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter price";
                            }
                            if (double.tryParse(value) == null) {
                              return "Enter valid price";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTextFormField(
                          controller: capacityController,
                          headingText: "Capacity *",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter capacity";
                            }
                            if (int.tryParse(value) == null) {
                              return "Enter valid capacity";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  CustomTextFormField(
                    controller: descriptionController,
                    headingText: "Description",
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// ---------- BUTTONS ----------
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      "Cancel",
                      style: interMedium(size: 14.sp, color: txtGrey2),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: CustomButton(
                    onTap: () async {
                      if (formKey.currentState!.validate() &&
                          room.id != null) {
                        final updatedRoom = room.copyWith(
                          roomNumber: roomNumberController.text,
                          roomType: selectedRoomType,
                          pricePerDay: double.parse(priceController.text),
                          capacity: int.parse(capacityController.text),
                          description: descriptionController.text,
                        );

                        await roomController.updateRoom(
                            room.id!, updatedRoom);
                      }
                    },
                    color: orange,
                    text: "Update",
                    height: 50.h,
                    width: 140.w,
                    isLoading: roomController.isLoading.isTrue
                      ? true
                      : false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  //delete eoom dialogue
  void _showDeleteDialog(RoomModel room) {
    Get.defaultDialog(
      title: "Delete Room",
      middleText: "Are you sure you want to delete Room ${room.roomNumber}?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: txtBlack,
      onConfirm: () async {
        if (room.id != null) {
          await roomController.deleteRoom(room.id!, room.roomNumber);
        }
      },
    );
  }
}