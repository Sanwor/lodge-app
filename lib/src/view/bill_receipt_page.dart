import 'package:family_home/src/view/home_page.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/widget/custom_button.dart';

class BillReceiptPage extends StatefulWidget {
  final Map<String, dynamic> billData;
  
  const BillReceiptPage({super.key, required this.billData});

  @override
  State<BillReceiptPage> createState() => _BillReceiptPageState();
}

class _BillReceiptPageState extends State<BillReceiptPage> {
  final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 200.w : 20.w, // Increase horizontal padding to make dialog narrower
        ),
        child: Column(
          children: [
            // Receipt Header
            _checkoutheader(),
            SizedBox(height: 24.h),
            
            // Guest Info
            _buildReceiptSection(
              title: "Guest Information",
              children: [
                _buildReceiptRow("Name", widget.billData['guestName']),
                _buildReceiptRow("Room", "Room ${widget.billData['roomNo']} (${widget.billData['roomType']})"),
                _buildReceiptRow("Check-in", "${widget.billData['checkinDate']} ${widget.billData['checkinTime']}"),
                _buildReceiptRow("Check-out", "${widget.billData['checkoutDate']} ${widget.billData['checkoutTime']}"),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Bill Details
            _buildReceiptSection(
              title: "Bill Details",
              children: [
                // Room Charges
                _buildReceiptRow("Room Charge", "Rs. ${widget.billData['roomPrice'].toString()}"),
                
                // Food Items
                if ((widget.billData['foodItems'] as List).isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    "Food & Beverages:",
                    style: interMedium(size: 14.sp, color: txtBlack),
                  ),
                  ...(widget.billData['foodItems'] as List).map<Widget>((item) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "  • ${item['name']} (${item['quantity']}x)",
                              style: interRegular(size: 13.sp, color: txtGrey2),
                            ),
                          ),
                          Text(
                            "Rs. ${(item['price'] * item['quantity']).toString()}",
                            style: interRegular(size: 13.sp, color: txtBlack),
                          ),
                        ],
                      ),
                    );
                  })
                ],
                
                // Totals
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 12.h),
                _buildReceiptRow("Subtotal", "Rs. ${widget.billData['subtotal'].toString()}"),
                SizedBox(height: 12.h),
                Divider(color: orange.withValues(alpha: 0.3), thickness: 1.5),
                SizedBox(height: 12.h),
                _buildReceiptRow(
                  "GRAND TOTAL",
                  "Rs. ${widget.billData['total'].toString()}",
                  isBold: true,
                  color: orange,
                ),
              ],
            ),
            
            SizedBox(height: 40.h),
            
            // Back Button
            Column(
              children: [
                CustomButton(
                  text: "Back to Home",
                  color: orange,
                  onTap: () => Get.offAll(const HomePage()),
                  height: kIsWeb ? 64.h : 50.h,
                  width: kIsWeb ? 600.w : double.infinity,
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _appBar(){
    return AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: txtBlack),
          onPressed: () => Get.until((route) => route.isFirst),
        ),
        title: Text(
          "Bill Receipt",
          style: interBold(size: 18.sp, color: txtBlack),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: txtBlack),
            onPressed: _printReceipt,
          ),
          IconButton(
            icon: Icon(Icons.share, color: txtBlack),
            onPressed: _shareReceipt,
          ),
        ],
      );
  }

  //checkout header
  _checkoutheader(){
    return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: orange.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 60.w, color: Colors.green),
                  SizedBox(height: 16.h),
                  Text(
                    "Checkout Successful!",
                    style: interBold(size: 20.sp, color: Colors.green),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Bill #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                    style: interMedium(size: 14.sp, color: txtGrey2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formattedDate,
                    style: interRegular(size: 12.sp, color: txtGrey2),
                  ),
                ],
              ),
            );
  }

  //guest information
  _buildReceiptSection({required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: interBold(size: 16.sp, color: txtBlack),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  //receipt row
  _buildReceiptRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? interBold(size: 14.sp, color: color ?? txtBlack)
                : interRegular(size: 14.sp, color: txtBlack),
          ),
          Text(
            value,
            style: isBold
                ? interBold(size: 14.sp, color: color ?? txtBlack)
                : interMedium(size: 14.sp, color: txtBlack),
          ),
        ],
      ),
    );
  }

  void _printReceipt() {
    showToast("Receipt sent to printer");
  }

  void _shareReceipt() {
    showToast("Receipt shared successfully");
  }
}