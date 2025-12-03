import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/view/add_record.dart';
import 'package:family_home/src/widget/record_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GuestRecordController recordController = Get.put(GuestRecordController());
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await recordController.getRecordsByDate(formattedDate);
  }

  Future<void> _refreshData() async {
    if (formattedDate == "Active Guests") {
      await recordController.getActiveRecords();
    } else if (formattedDate == "All Records") {
      await recordController.getAllRecords();
    } else {
      await recordController.getRecordsByDate(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),

      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.to(() => const AddRecord()),
      ),

      appBar: _buildAppBar(),
      body: Obx(() {
        if (recordController.isLoading.isTrue) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 16.h),
                _buildFilterButtons(),
                SizedBox(height: 16.h),
                _buildRecordList(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  //app bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txtBlack),
      title: Text(
        "Daily Records",
        style: interBold(size: 18.sp, color: txtBlack),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {},
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.refresh),
      //     onPressed: _refreshData,
      //   ),
      // ],
    );
  }

  //header
  Widget _buildHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Records:", style: interBold(size: 22.sp, color: txtBlack)),
          SizedBox(height: 6.h),
          Text(formattedDate, style: interRegular(size: 14.sp, color: txtGrey2)),
          SizedBox(height: 6.h),
          Text(
            "Total: ${recordController.records.length} guest(s)",
            style: interMedium(size: 14.sp, color: orange),
          ),
        ],
      ),
    );
  }

  //filter buttons 
  Widget _buildFilterButtons() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _filterButton(
            text: "Today",
            active: formattedDate == today,
            activeColor: orange,
            onTap: () {
              setState(() => formattedDate = today);
              recordController.getRecordsByDate(today);
            },
          ),
          SizedBox(width: 10.w),

          _filterButton(
            text: "Active",
            active: formattedDate == "Active Guests",
            activeColor: Colors.green,
            onTap: () {
              setState(() => formattedDate = "Active Guests");
              recordController.getActiveRecords();
            },
          ),
          SizedBox(width: 10.w),

          _filterButton(
            text: "All",
            active: formattedDate == "All Records",
            activeColor: txtBlue,
            onTap: () {
              setState(() => formattedDate = "All Records");
              recordController.getAllRecords();
            },
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String text,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              text,
              style: interMedium(
                size: 14.sp,
                color: active ? Colors.white : txtGrey2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //record list
  Widget _buildRecordList() {
    if (recordController.records.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.separated(
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recordController.records.length,
        itemBuilder: (context, index) {
          final record = recordController.records[index];

          return RecordContainer(
            date: record.checkinDate,
            name: record.name,
            address: record.address,
            roomNo: record.roomNo,
            isCheckedOut: record.checkoutDate != null,
            onTap: () => Get.to(() => AddRecord(
                  isUpdate: true,
                  recordId: record.id,
                )),
            onTapCheckout: record.checkoutDate == null
                ? () => _showCheckoutDialog(record)
                : null,
            onDelete: () => _showDeleteDialog(record),
          );
        },
      ),
    );
  }

  //empty view
  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Icon(Icons.inbox, size: 80.sp, color: txtGrey2),
        SizedBox(height: 10.h),
        Text(
          formattedDate == "Active Guests"
              ? "No active guests"
              : formattedDate == "All Records"
                  ? "No records found"
                  : "No records for $formattedDate",
          style: interMedium(size: 16.sp, color: txtGrey2),
        ),
      ],
    );
  }

  //checkout
  void _showCheckoutDialog(GuestRecordModel record) {
    final checkoutDateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final checkoutTimeController =
        TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

    Get.defaultDialog(
      title: "Checkout Guest",
      content: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            TextFormField(
              controller: checkoutDateController,
              decoration: const InputDecoration(
                labelText: 'Checkout Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.parse(record.checkinDate),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  checkoutDateController.text =
                      DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: checkoutTimeController,
              decoration: const InputDecoration(
                labelText: 'Checkout Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                final time = await showTimePicker(
                  context: Get.context!,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  checkoutTimeController.text = time.format(Get.context!);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (record.id == null) return;

            bool success = await recordController.checkoutGuest(
              record.id!,
              checkoutDateController.text,
              checkoutTimeController.text,
            );

            if (success) Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: orange),
          child: const Text("Checkout", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  //delete
  void _showDeleteDialog(GuestRecordModel record) {
    Get.defaultDialog(
      title: "Delete Record",
      middleText: "Are you sure you want to delete ${record.name}'s record?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: txtBlack,
      onConfirm: () async {
        if (record.id == null) return;

        bool success = await recordController.deleteRecord(record.id!);
        if (success) Get.back();
      },
    );
  }
}
