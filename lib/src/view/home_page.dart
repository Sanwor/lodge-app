import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:family_home/src/view/add_record.dart';
import 'package:family_home/src/view/checkout_page.dart';
import 'package:family_home/src/widget/custom_menubar.dart';
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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GuestRecordController recordController = Get.put(GuestRecordController());
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  CustomMenubar drawer = Get.put(CustomMenubar());
  late final TabController _tabController;
  // ignore: unused_field
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      appBar: _appBar(),
      drawer: drawer,
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
                _buildTabBar(),
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
  AppBar _appBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txtBlack),
      title: Text(
        "Daily Records",
        style: interBold(size: 18.sp, color: txtBlack),
      ),
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
  Widget _buildTabBar() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: orange,
          borderRadius: BorderRadius.circular(8.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: txtGrey2,
        labelStyle: interMedium(size: 14.sp),
        unselectedLabelStyle: interMedium(size: 14.sp),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: "Today"),
          Tab(text: "Active"),
          Tab(text: "All"),
        ],
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
            if (index == 0) {
              formattedDate = today;
              recordController.getRecordsByDate(today);
            } else if (index == 1) {
              formattedDate = "Active Guests";
              recordController.getActiveRecords();
            } else {
              formattedDate = "All Records";
              recordController.getAllRecords();
            }
          });
        },
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
            onTap: () {},
            onTapCheckout: record.checkoutDate == null
              ? () => Get.to(() => CheckoutPage(record: record))
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

  // //checkout
  // void _showCheckoutDialog(GuestRecordModel record) {
  //   final checkoutDateController =
  //       TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  //   final checkoutTimeController =
  //       TextEditingController(text: DateFormat('HH:mm').format(DateTime.now()));

  //   Get.defaultDialog(
  //     title: "Checkout Guest",
  //     content: Padding(
  //       padding: EdgeInsets.all(16.w),
  //       child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SizedBox(height: 14.h),
              
  //             CustomDatepicker(
  //               controller: checkoutDateController,
  //               labelText: 'Check-out Date',
  //               firstDate: DateTime(1900, 1, 1),
  //               onChanged: (value) {
  //                 setState(() {});
  //               },
  //             ),
              
  //             SizedBox(height: 18.h),
              
  //             CustomTimePicker(
  //               controller: checkoutTimeController,
  //               defaultTime: const TimeOfDay(hour: 12, minute: 0),
  //               fixedToDefault: true,
  //               headingText: "Check-out Time",
  //             ),
  //           ],
  //         ), ),
  //     actions: [
  //       TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
  //       ElevatedButton(
  //         onPressed: () async {
  //           if (record.id == null) return;

  //           recordController.checkoutGuest(
  //           record.id!,
  //           checkoutDateController.text,
  //           checkoutTimeController.text,
  //         );
          
  //         Get.back();
  //         },
  //         style: ElevatedButton.styleFrom(backgroundColor: orange),
  //         child: const Text("Checkout", style: TextStyle(color: Colors.white)),
  //       ),
  //     ],
  //   );
  // }

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
