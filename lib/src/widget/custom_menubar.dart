import 'package:family_home/src/view/manage_menu.dart';
import 'package:family_home/src/view/manage_rooms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomMenubar extends StatelessWidget {
  const CustomMenubar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMenuItems(context)),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  /// ---------------- HEADER ----------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade300,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.orange),
          ),
          SizedBox(height: 10.h),
          Text(
            "Welcome!",
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Family Home Management",
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  /// ---------------- MENU ITEMS ----------------
  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      children: [
        _menuItem(
          icon: Icons.dashboard,
          title: "Dashboard",
          onTap: () {
            Get.back();
          },
        ),
        _menuItem(
          icon: Icons.restaurant_menu,
          title: "Manage Menu",
          onTap: () {
            Get.to(()=>ManageMenu());
          },
        ),
        _menuItem(
          icon: Icons.meeting_room,
          title: "Manage Rooms",
          onTap: () {
            Get.to(()=>ManageRoom());
          },
        ),
        _menuItem(
          icon: Icons.people,
          title: "Guests",
          onTap: () {},
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      onTap: onTap,
      hoverColor: Colors.orange.withValues(alpha: 0.08),
    );
  }

  /// ---------------- LOGOUT BUTTON ----------------
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text(
          "Logout",
          style: TextStyle(
            color: Colors.red,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        hoverColor: Colors.red.withValues(alpha: 0.06),
      ),
    );
  }
}
