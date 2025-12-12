import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final double height;
  final double width;
  final bool? isLoading;
  final Function()? onTap;
  final double? fontSize; // Custom font size
  final EdgeInsetsGeometry? padding; // Custom padding
  final BorderRadiusGeometry? borderRadius; // Custom border radius
  const CustomButton(
      {super.key,
      required this.color,
      required this.text,
      required this.onTap,
      required this.height,
      required this.width,
      this.isLoading,
      this.fontSize,
      this.padding,
      this.borderRadius,});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(
              isWeb ? 12.r : 8.r
            ),
          ),
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: isWeb ? 24.w : 16.w,
          ),
          elevation: isWeb ? 4.0 : 2.0,
          shadowColor: Colors.black.withValues(alpha: isWeb ? 0.15 : 0.1),
        ),
        child: isLoading == true
            // Loader with responsive size
            ? SizedBox(
                height: isWeb ? 28 : 24,
                width: isWeb ? 28 : 24,
                child: CircularProgressIndicator(
                  strokeWidth: isWeb ? 3 : 2, 
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: interMedium(
                  size: fontSize ?? (isWeb ? 16.sp : 14.sp), 
                  color: white,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}