import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/view/bill_receipt_page.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/menu_controller.dart';
import 'package:family_home/src/controllers/room_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/models/menu_model.dart';
import 'package:family_home/src/models/room_model.dart';
import 'package:family_home/src/widget/custom_button.dart';
import 'package:family_home/src/widget/custom_datepicker.dart';
import 'package:family_home/src/widget/custom_time_picker.dart';

class CheckoutPage extends StatefulWidget {
  final GuestRecordModel record;
  
  const CheckoutPage({super.key, required this.record});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final MenusController menuController = Get.put(MenusController());
  final RoomController roomController = Get.put(RoomController());
  final GuestRecordController recordController = Get.put(GuestRecordController());
  
  final checkoutDateController = TextEditingController();
  final checkoutTimeController = TextEditingController();
  
  RoomModel? currentRoom;
  RxList<MenuItemModel> selectedMenuItems = <MenuItemModel>[].obs;
  final itemQuantities = <String, int>{}.obs;
  
  double roomPrice = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    checkoutDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    checkoutTimeController.text = DateFormat('HH:mm').format(DateTime.now());
    
    // Load menu items
    await menuController.getAllMenuItems();
    
    // Find room details
    await roomController.getAllRooms();
    currentRoom = roomController.rooms.firstWhereOrNull(
      (room) => room.roomNumber == widget.record.roomNo
    );
    
    if (currentRoom != null) {
      roomPrice = currentRoom!.pricePerDay;
    }
    
    if (mounted) setState(() {});
  }

  // Calculate totals
  double getFoodTotal() {
    double total = 0.0;
    for (var item in selectedMenuItems) {
      final quantity = itemQuantities[item.id!] ?? 0;
      total += (item.price * quantity);
    }
    return total;
  }

  double getSubtotal() {
    return roomPrice + getFoodTotal();
  }
  double getGrandTotal() {
    return getSubtotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 200.w : 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest Header
            guestHeader(),
            SizedBox(height: 24.h),
            
            // Checkout Time
            checkoutTime(),
            SizedBox(height: 24.h),
            
            // Room Charges
            roomCharges(),
            SizedBox(height: 24.h),
            
            // Food & Beverages
            Obx(() => foodSection()),
            SizedBox(height: 24.h),
            
            // Bill Summary
            Obx(() => billSummary()),
            SizedBox(height: 32.h),
            
            // Action Buttons
            actionButtons(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ============ WIDGETS ============

  //AppBar
  _appBar(){
    return AppBar(
        backgroundColor: white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(onPressed: () {
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios_new_outlined)),
        title: Text(
          "Checkout & Billing",
          style: interBold(size: 18.sp, color: txtBlack),
        ),
      );
  }

  // Guest Header
  guestHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25.w),
                ),
                child: Icon(Icons.person, color: orange, size: 24.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.record.name,
                      style: interBold(size: 18.sp, color: txtBlack),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Room ${widget.record.roomNo}",
                      style: interMedium(size: 14.sp, color: txtBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Check-in",
                    style: interRegular(size: 12.sp, color: txtGrey2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${widget.record.checkinDate} ${widget.record.checkinTime}",
                    style: interMedium(size: 14.sp, color: txtBlack),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Duration",
                    style: interRegular(size: 12.sp, color: txtGrey2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _calculateStayDuration(),
                    style: interMedium(size: 14.sp, color: orange),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Checkout Time
  checkoutTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Checkout Time", style: interBold(size: 16.sp, color: txtBlack)),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date",
                    style: interRegular(size: 12.sp, color: txtGrey2),
                  ),
                  SizedBox(height: 8.h),
                  CustomDatepicker(
                    controller: checkoutDateController,
                    labelText: 'Select Date',
                    firstDate: DateTime(1900, 1, 1),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time",style: interRegular(size: 12.sp, color: txtGrey2)),
                  SizedBox(height: 8.h),
                  CustomTimePicker(
                    controller: checkoutTimeController,
                    defaultTime: const TimeOfDay(hour: 12, minute: 0),
                    fixedToDefault: true,
                    headingText: "Select Time",
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Room Charges
  roomCharges() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Room Charges:",style: interBold(size: 16.sp, color: txtBlack)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Room ${widget.record.roomNo}",
                    style: interMedium(size: 14.sp, color: txtBlack),
                  ),
                  if (currentRoom != null)
                    Text(
                      currentRoom!.roomType,
                      style: interRegular(size: 12.sp, color: txtGrey2),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Rs. ${roomPrice.toStringAsFixed(2)}",
                    style: interBold(size: 16.sp, color: orange),
                  ),
                  Text(
                    "Per Day",
                    style: interRegular(size: 12.sp, color: txtGrey2),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Food Section
  foodSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Food & Beverages:",
                style: interBold(size: 16.sp, color: txtBlack),
              ),
              TextButton(
                onPressed: _showFoodSelection,
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16.w, color: orange),
                    SizedBox(width: 4.w),
                    Text(
                      selectedMenuItems.isEmpty ? "Add Items" : "Edit Items",
                      style: interMedium(size: 12.sp, color: orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Selected Items List
          Obx(() {
          return Column(
            children: [
              if (selectedMenuItems.isNotEmpty) ...[
                SizedBox(height: 16.h),
                ...selectedMenuItems.map((item) {
                  final quantity = itemQuantities[item.id!] ?? 1;
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: interMedium(size: 14.sp, color: txtBlack),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    "Rs. ${item.price.toStringAsFixed(2)}",
                                    style: interRegular(size: 12.sp, color: txtGrey2),
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      "Qty: $quantity",
                                      style: interMedium(size: 11.sp, color: orange),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Rs. ${(item.price * quantity).toStringAsFixed(2)}",
                          style: interMedium(size: 14.sp, color: txtBlack),
                        ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                SizedBox(height: 16.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 24.h,horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu, size: 40.w, color: txtGrey2),
                        SizedBox(height: 12.h),
                        Text(
                          "No food items added",
                          style: interRegular(size: 14.sp, color: txtGrey2),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Tap 'Add Items' to add food charges",
                          style: interRegular(size: 12.sp, color: txtGrey2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              if (selectedMenuItems.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Food Total",
                      style: interMedium(size: 14.sp, color: txtBlack),
                    ),
                    Text(
                      "Rs. ${getFoodTotal().toStringAsFixed(2)}",
                      style: interMedium(size: 14.sp, color: txtBlack),
                    ),
                  ],
                ),
              ],
            ],
          );
          })
        ],
      ),
    );
  }

  // Bill Summary
  billSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bill Summary:",
            style: interBold(size: 16.sp, color: txtBlack),
          ),
          SizedBox(height: 16.h),
          
          // Row items
          _buildBillRow("Room Charges", "Rs. ${roomPrice.toStringAsFixed(2)}"),
          if (selectedMenuItems.isNotEmpty)
            _buildBillRow("Food & Beverages", "Rs. ${getFoodTotal().toStringAsFixed(2)}"),
          
          SizedBox(height: 16.h),
          Divider(color: orange.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          
          _buildBillRow(
            "GRAND TOTAL",
            "Rs. ${getGrandTotal().toStringAsFixed(2)}",
            isBold: true,
            color: orange,
          ),
        ],
      ),
    );
  }

  _buildBillRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? interBold(size: 15.sp, color: color ?? txtBlack)
                : interRegular(size: 14.sp, color: txtBlack),
          ),
          Text(
            value,
            style: isBold
                ? interBold(size: 15.sp, color: color ?? txtBlack)
                : interMedium(size: 14.sp, color: txtBlack),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  actionButtons() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: orange),
            )
          else ...[
            CustomButton(
              text: "Generate Bill & Checkout",
              color: orange,
              onTap: _processCheckout,
              height: kIsWeb ? 64.h : 50.h,
              width: kIsWeb ? 600.w: double.infinity,
            ),
            SizedBox(height: 12.h),
            CustomButton(
              text: "Cancel",
              color: Colors.grey.shade400,
              onTap: () => Get.back(),
              height: kIsWeb ? 64.h : 50.h,
              width: kIsWeb ? 600.w : double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  // ============ HELPER METHODS ============

  // Food Selection Dialog
  void _showFoodSelection() {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Food Items",
                    style: interBold(size: 18.sp, color: txtBlack),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.w),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Obx(() {
                if (menuController.isLoading.isTrue) {
                  return Center(child: CircularProgressIndicator(color: orange));
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: menuController.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuController.menuItems[index];
                    final isSelected = selectedMenuItems.any((selected) => selected.id == item.id);
                    
                    // Use Obx for each item's quantity to trigger rebuild
                    return Obx(() {
                      final quantity = itemQuantities[item.id!] ?? 0;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? orange.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? orange : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: interMedium(size: 14.sp, color: txtBlack),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.description,
                                    style: interRegular(size: 12.sp, color: txtGrey2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Rs. ${item.price.toStringAsFixed(2)}",
                                    style: interMedium(size: 14.sp, color: orange),
                                  ),
                                ],
                              ),
                            ),
                            
                            Row(
                              children: [
                                // Minus button
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: quantity > 0 ? Colors.red : Colors.grey.shade400,
                                    size: 24.w,
                                  ),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      itemQuantities[item.id!] = quantity - 1;
                                      itemQuantities.refresh(); // Trigger rebuild
                                    } else if (quantity == 1) {
                                      selectedMenuItems.removeWhere((selected) => selected.id == item.id);
                                      itemQuantities.remove(item.id!);
                                      selectedMenuItems.refresh(); // Trigger rebuild
                                      itemQuantities.refresh(); // Trigger rebuild
                                    }
                                  },
                                ),

                                // Quantity display
                                Container(
                                  width: 30.w,
                                  alignment: Alignment.center,
                                  child: Text(
                                    quantity.toString(),
                                    style: interMedium(size: 16.sp),
                                  ),
                                ),

                                // Add button
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Colors.green, size: 24.w),
                                  onPressed: () {
                                    if (!selectedMenuItems.any((selected) => selected.id == item.id)) {
                                      selectedMenuItems.add(item);
                                    }
                                    itemQuantities[item.id!] = quantity + 1;
                                    itemQuantities.refresh(); // Trigger rebuild
                                    selectedMenuItems.refresh(); // Trigger rebuild
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            // Done Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: CustomButton(
                text: "Done",
                color: orange,
                onTap: () => Get.back(),
                height: 50.h,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Process Checkout
  Future<void> _processCheckout() async {
    if (checkoutDateController.text.isEmpty || checkoutTimeController.text.isEmpty) {
      showErrorToast("Please select checkout date and time");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Prepare bill data
      final billData = {
        'guestId': widget.record.id,
        'guestName': widget.record.name,
        'roomNo': widget.record.roomNo,
        'roomPrice': roomPrice,
        'roomType': currentRoom?.roomType ?? 'Standard',
        'checkinDate': widget.record.checkinDate,
        'checkinTime': widget.record.checkinTime,
        'checkoutDate': checkoutDateController.text,
        'checkoutTime': checkoutTimeController.text,
        'foodItems': selectedMenuItems.map((item) {
          return {
            'id': item.id,
            'name': item.name,
            'price': item.price,
            'quantity': itemQuantities[item.id!] ?? 1,
          };
        }).toList(),
        'subtotal': getSubtotal(),
        'total': getGrandTotal(),
        'generatedAt': DateTime.now().toString(),
      };

      // Perform checkout
      final success = await recordController.checkoutGuest(
        widget.record.id!,
        checkoutDateController.text,
        checkoutTimeController.text,
      );

      if (success) {
        // Navigate to bill receipt page
        Get.back(); // Close checkout page
        Get.to(() => BillReceiptPage(billData: billData));
      } else {
        Get.snackbar(
          "Error",
          "Checkout failed. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Calculate stay duration
  String _calculateStayDuration() {
    try {
      final checkinDate = DateFormat('yyyy-MM-dd').parse(widget.record.checkinDate);
      final checkoutDate = DateFormat('yyyy-MM-dd').parse(checkoutDateController.text);
      final duration = checkoutDate.difference(checkinDate).inDays;
      return "${duration + 1} night${duration > 0 ? 's' : ''}";
    } catch (e) {
      return "Calculating...";
    }
  }

  @override
  void dispose() {
    checkoutDateController.dispose();
    checkoutTimeController.dispose();
    super.dispose();
  }
}