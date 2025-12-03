import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_home/src/app_config/app_styles.dart';

class CustomTimePicker extends StatefulWidget {
  final String? headingText;
  final TextStyle? headingTextStyle;
  final bool? isRequired;
  final bool? isOptional;
  final String? infoText;
  final String? impText;
  final String? reqText;
  final double? headingTextHeight;

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool? isDisabled;

  final TimeOfDay? defaultTime;
  final bool fixedToDefault;

  const CustomTimePicker({
    super.key,
    this.headingText,
    this.headingTextStyle,
    this.isRequired,
    this.isOptional,
    this.infoText,
    this.impText,
    this.reqText,
    this.headingTextHeight,
    required this.controller,
    this.onChanged,
    this.onTap,
    this.isDisabled,
    this.defaultTime,
    this.fixedToDefault = false, 
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  @override
  void initState() {
    super.initState();
    
    // Set default time if provided and controller is empty
    if (widget.defaultTime != null && widget.controller.text.isEmpty) {
      final formatted = _formatTime(widget.defaultTime!);
      widget.controller.text = formatted;
      
      if (widget.onChanged != null) {
        widget.onChanged!(formatted);
      }
    }
  }

  Future<void> _pickTime() async {
    if (widget.isDisabled == true) return;

    // Use default time or current time as initial
    TimeOfDay initialTime = widget.defaultTime ?? TimeOfDay.now();
    
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formatted = _formatTime(picked);
      widget.controller.text = formatted;

      if (widget.onChanged != null) {
        widget.onChanged!(formatted);
      }

      setState(() {});
    }
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Row(
          children: [
            if (widget.headingText != null)
              Text(
                widget.headingText!,
                style: widget.headingTextStyle ??
                    interRegular(size: 12.sp, color: txtGrey7),
              ),

            SizedBox(width: 8.w),

            // Required badge
            if (widget.isRequired == true)
              Container(
                height: 20.h,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: const Color(0xffC13939),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(
                    widget.reqText ?? "Required",
                    style: interRegular(size: 12.sp, color: white),
                  ),
                ),
              ),
            SizedBox(width: 4.w),

            // Info (optional text)
            if (widget.infoText != null)
              Text(
                widget.infoText!,
                style: interRegular(size: 11.sp, color: const Color(0xff808084)),
              ),
          ],
        ),

        SizedBox(height: widget.headingText == null ? 0 : widget.headingTextHeight ?? 8.h),

        // Important message
        if (widget.impText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              widget.impText!,
              style: interMedium(size: 12.sp, color: red),
            ),
          ),

        // TIME PICKER TEXTFIELD DESIGN
        TextFormField(
          controller: widget.controller,
          readOnly: true,
          onTap: widget.fixedToDefault ? null : _pickTime,
          style: interRegular(size: 16.sp, color: black),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.access_time, color: Color(0xff808084)),
            hintText: widget.fixedToDefault ? "12:00 PM" : null,
            hintStyle: interRegular(size: 16.sp, color: txtGrey7),

            // Borders copy of CustomTextFormField
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: const Color(0xffC9C9C9), width: 2.sp),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: const Color(0xff808084), width: 1.sp),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: const Color(0xff808084), width: 1.sp),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: const Color(0xffC13939), width: 1.sp),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: const Color(0xffC13939), width: 1.sp),
            ),

            filled: true,
            fillColor: widget.isDisabled == true ? grey2 : white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
        ),
      ],
    );
  }
}
