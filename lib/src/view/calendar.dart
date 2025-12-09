import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/controllers/record_controller.dart';
import 'package:family_home/src/models/guest_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final recordController = Get.find<GuestRecordController>();
  List<GuestRecordModel> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedEvents(_focusedDay);
    });
  }

  void _updateSelectedEvents(DateTime day) {
    final formattedDay = DateFormat('yyyy-MM-dd').format(day);
    
    // Use records directly from controller without calling setState
    _selectedEvents = recordController.records.where((record) {
      return record.checkinDate == formattedDay;
    }).toList();
    
    // Only call setState if we're not currently building
    if (mounted) {
      setState(() {});
    }
  }

  // Get events for calendar markers
  List<String> _getEventsForDay(DateTime day) {
    final formattedDay = DateFormat('yyyy-MM-dd').format(day);
    return recordController.records
        .where((record) => record.checkinDate == formattedDay)
        .map((record) => record.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _appBar(),
      body: Column(
        children: [
          calendar(),
          SizedBox(height: 16.h),
          eventsList(),
        ],
      ),
    );
  }

  ///AppBar
  _appBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: txtBlack),
      title: Text(
        "Calendar",
        style: interBold(size: 18.sp, color: txtBlack),
      ),
    );
  }

  ///CALENDAR
  Widget calendar() {
    return Container(
      margin: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        
        // Mark days with events
        eventLoader: _getEventsForDay,
        
        // Event indicator
        calendarBuilders: CalendarBuilders(

          //Activity Marker
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
          
          dowBuilder: (context, day) {
            if (day.weekday == DateTime.saturday) {
              final text = DateFormat.E().format(day);
              return Center(
                child: Text(
                  text,
                  style: TextStyle(color: red),
                ),
              );
            }
            return null;
          },
        ),
        
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _updateSelectedEvents(selectedDay);
          }
        },
        
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: interMedium(size: 16.sp),
        ),
        
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: orange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: orange,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// EVENTS LIST - Remove Obx from here
  Widget eventsList() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedDay == null
                  ? "Select a date"
                  : "Activities on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}",
              style: interBold(size: 16.sp, color: txtBlack),
            ),
            SizedBox(height: 12.h),
            
            if (_selectedEvents.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event, size: 60.w, color: txtGrey2),
                      SizedBox(height: 12.h),
                      Text(
                        "No activities",
                        style: interMedium(size: 14.sp, color: txtGrey2),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Select another date",
                        style: interRegular(size: 12.sp, color: txtGrey2),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final record = _selectedEvents[index];
                    return eventCard(record);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// EVENT CARD
  Widget eventCard(GuestRecordModel record) {
    final isCheckedOut = record.checkoutDate != null && record.checkoutDate!.isNotEmpty;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.05),
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
              Expanded(
                child: Text(
                  record.name,
                  style: interBold(size: 16.sp, color: txtBlack),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCheckedOut ? grey :  green,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  isCheckedOut ? "Checked Out" : "Active",
                  style: interMedium(
                    size: 12.sp,
                    color: txtBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          Row(
            children: [
              Icon(Icons.meeting_room, size: 14.w, color: txtGrey2),
              SizedBox(width: 4.w),
              Text(
                "Room ${record.roomNo}",
                style: interRegular(size: 13.sp, color: txtGrey2),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, size: 14.w, color: txtGrey2),
              SizedBox(width: 4.w),
              Text(
                record.checkinTime,
                style: interRegular(size: 13.sp, color: txtGrey2),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          if (record.checkoutDate != null && record.checkoutDate!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.logout, size: 14.w, color: orange),
                SizedBox(width: 4.w),
                Text(
                  "Checked out: ${record.checkoutDate} ${record.checkoutTime ?? ''}",
                  style: interRegular(size: 13.sp, color: orange),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.login, size: 14.w, color: green2),
                SizedBox(width: 4.w),
                Text(
                  "Currently staying",
                  style: interRegular(size: 13.sp, color: green2),
                ),
              ],
            ),
        ],
      ),
    );
  }
}