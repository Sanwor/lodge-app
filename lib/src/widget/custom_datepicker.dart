import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomDatepicker extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? reqText;
  final ValueChanged<String>? onChanged;
  final bool? isRequired;
  final FormFieldValidator<String>? validator;

  CustomDatepicker({
    super.key,
    required this.controller,
    required this.labelText,
    DateTime? firstDate,
    DateTime? lastDate,
    this.onChanged,
    this.isRequired,
    this.reqText,
    this.validator,
  })  : firstDate = firstDate ?? DateTime(1900),
        lastDate = lastDate ?? DateTime(2100);

  @override
  State<CustomDatepicker> createState() => _CustomDatepickerState();
}

class _CustomDatepickerState extends State<CustomDatepicker> {
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();

    // Ensure initialDate is within range
    DateTime initialDate = now;
    if (initialDate.isBefore(widget.firstDate)) {
      initialDate = widget.firstDate;
    } else if (initialDate.isAfter(widget.lastDate)) {
      initialDate = widget.lastDate;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (picked != null) {
      setState(() {
        widget.controller.text = DateFormat("yyyy-MM-dd").format(picked);
        if (widget.onChanged != null) {
          widget.onChanged!(widget.controller.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              child: Text(
                widget.labelText,
                style: interRegular(size: 12.sp, color: txtGrey7)
              )
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
          ],
        ),

        SizedBox(height: 8.0.h),

        TextFormField(
          controller: widget.controller,
          readOnly: true,
          style: TextStyle(color: black),
          validator: widget.validator,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, color: Color(0xff808084),),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC9C9C9),
                  width: 2.sp
                ),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: const Color(0xff808084),
                  width: 1.sp
                ),
              ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: const Color(0xff808084),
                  width: 1.sp
                ),
              ),
            fillColor: white,
            filled: true,
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC13939), 
                  width: 1.sp
                ),
              ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC13939), 
                  width: 1.sp
                ),
              ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.0.sp),
            errorStyle: TextStyle(fontSize: 11.5.sp, color: Colors.red),
          ),
          onTap: _pickDate,
        ),
      ],
    );
  }
}