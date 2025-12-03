// lib/src/widget/custom_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_home/src/app_config/app_styles.dart';

class CustomDropdown extends StatefulWidget {
  final String? headingText;
  final TextStyle? headingTextStyle;
  final bool? isRequired;
  final String? infoText;
  final String? impText;
  final String? reqText;
  final double? headingTextHeight;
  final String? hintText;
  final TextStyle? hintStyle;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool? isDisabled;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    super.key,
    this.headingText,
    this.headingTextStyle,
    this.isRequired,
    this.infoText,
    this.impText,
    this.reqText,
    this.headingTextHeight,
    this.hintText,
    this.hintStyle,
    required this.items,
    this.value,
    required this.onChanged,
    this.isDisabled,
    this.validator,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
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

        // DROPDOWN
        DropdownButtonFormField<String>(
          value: widget.value,
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: interRegular(size: 14.sp, color: txtBlack),
              ),
            );
          }).toList(),
          onChanged: widget.isDisabled == true ? null : widget.onChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ?? interRegular(size: 16.sp, color: txtGrey7),
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
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: const Color(0xff808084),
            ),
          ),
          icon: const SizedBox.shrink(), // Hide default icon
          isExpanded: true,
          style: interRegular(size: 16.sp, color: txtBlack),
        ),
      ],
    );
  }
}