import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final double height;
  final double width;
  final bool? isLoading;
  final Function()? onTap;
  const CustomButton(
      {super.key,
      required this.color,
      required this.text,
      required this.onTap,
      required this.height,
      required this.width,
      this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: isLoading == true
              //small loader
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(text,
                  style: interMedium( size: 14.h, color: white))),
    );
  }
}