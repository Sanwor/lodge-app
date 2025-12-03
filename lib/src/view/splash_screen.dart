import 'package:family_home/src/app_utils/read_write.dart';
import 'package:family_home/src/view/home_page.dart';
import 'package:family_home/src/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), (){
      Get.offAll(() => read('token') != '' ? const HomePage() : LoginPage());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Icon(Icons.adb_rounded, size: 50.sp))
        ],
      ),
    );
  }
}