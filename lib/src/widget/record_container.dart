import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordContainer extends StatelessWidget {
  final String date;
  final String name;
  final String address;
  final String status;
  final String roomNo;
  final bool? isCheckedOut;
  final VoidCallback onTap;
  final VoidCallback? onTapCheckout;
  final VoidCallback? onTapCheckIn;
  final VoidCallback? onDelete;
  
  const RecordContainer({
    super.key,
    required this.date,
    required this.name,
    required this.address,
    required this.status,
    required this.roomNo,
    this.isCheckedOut,
    required this.onTap,
    this.onTapCheckout,
    this.onTapCheckIn,
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
                color: isCheckedOut == true ? Colors.grey : Colors.green,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status), // Use status-based color
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          status, // Show actual status from database
                          style: interMedium(
                            size: 12.sp,
                            color: Colors.white, // White text for better contrast
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
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: txtGrey2),
              itemBuilder: (context) {
                List<PopupMenuItem> items = [];
                
                // Show Check-in button only if status is "Booked"
                if (status.toLowerCase() == 'booked' && onTapCheckIn != null) {
                  items.add(
                    PopupMenuItem(
                      onTap: onTapCheckIn,
                      child: Row(
                        children: [
                          Icon(Icons.login, color: Colors.green),
                          SizedBox(width: 8.w),
                          Text("Check In"),
                        ],
                      ),
                    ),
                  );
                }
                
                // Show Checkout button (existing logic)
                if (onTapCheckout != null) {
                  items.add(
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
                  );
                }
                
                // Show Delete button (existing logic)
                if (onDelete != null) {
                  items.add(
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: red),
                          SizedBox(width: 8.w),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  );
                }
                
                return items;
              },
            ),
          ],
        ),
      ),
    );
  }

}
// Helper method for status colors
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'booked':
      return Colors.blue;
    case 'checked in':
      return Colors.green;
    case 'checked out':
      return Colors.grey;
    default:
      return Colors.blueGrey;
  }
}