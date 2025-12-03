import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordContainer extends StatelessWidget {
  final String date;
  final String name;
  final String address;
  final String roomNo;
  final bool isCheckedOut;
  final VoidCallback onTap;
  final VoidCallback? onTapCheckout;
  final VoidCallback? onDelete;
  
  const RecordContainer({
    super.key,
    required this.date,
    required this.name,
    required this.address,
    required this.roomNo,
    this.isCheckedOut = false,
    required this.onTap,
    this.onTapCheckout,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 8.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: isCheckedOut ? Colors.grey : Colors.green,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 12.w),
            
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: interSemiBold(size: 16.sp, color: txtBlack),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isCheckedOut ? Colors.grey.shade200 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          isCheckedOut ? "Checked Out" : "Active",
                          style: interMedium(
                            size: 12.sp,
                            color: isCheckedOut ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address,
                    style: interRegular(size: 14.sp, color: txtGrey2),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: orange),
                      SizedBox(width: 4.w),
                      Text(
                        date,
                        style: interRegular(size: 13.sp, color: txtGrey2),
                      ),
                      SizedBox(width: 16.w),
                      Icon(Icons.meeting_room, size: 14.sp, color: txtBlue),
                      SizedBox(width: 4.w),
                      Text(
                        "Room $roomNo",
                        style: interRegular(size: 13.sp, color: txtGrey2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action buttons
            if (onTapCheckout != null || onDelete != null)
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: txtGrey2),
                itemBuilder: (context) => [
                  if (onTapCheckout != null)
                    PopupMenuItem(
                      onTap: onTapCheckout,
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: orange),
                          SizedBox(width: 8.w),
                          Text("Checkout"),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text("Delete"),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}