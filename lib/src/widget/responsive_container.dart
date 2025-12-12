import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useMaxWidth;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.useMaxWidth = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: useMaxWidth ? 1200.w : double.infinity,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(
              horizontal: 40.w,
              vertical: 20.h,
            ),
            child: child,
          ),
        ),
      );
    }
    
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ),
      child: child,
    );
  }
}