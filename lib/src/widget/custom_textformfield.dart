import 'package:family_home/src/app_config/app_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomTextFormField extends StatelessWidget {
  final String? headingText;
  final TextStyle? headingTextStyle;
  final String? infoText;
  final String? impText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool? isRequired ;
  final bool? isOptional ;
  final bool? isDropdown;
  final bool? isSuffixLoading;
  final bool readOnly;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final OutlineInputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final Color? cursorColor;
  final Color? filledColor;
  final bool? filled;
  final int? maxLines;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autoValidateMode;
  final bool? isDisabled;
  final FocusNode? focusNode;
  final bool? autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? infoTextStyle;
  final int? maxLength;
  final String? reqText; 
  final double? headingTextHeight;

  const CustomTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.labelText,
    this.hintText,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.cursorColor,
    this.maxLines,
    this.width,
    this.height, 
    this.filledColor, 
    this.filled, 
    this.autofocus = false, 
    this.readOnly = false, 
    this.onTap, 
    this.autoValidateMode, 
    this.isDisabled, 
    this.inputFormatters, 
    this.onFieldSubmitted,
    this.focusNode,
    this.headingText, 
    this.isRequired, 
    this.headingTextHeight,
    this.isDropdown, this.isOptional, this.infoText, this.infoTextStyle, this.maxLength, this.isSuffixLoading, this.reqText, this.impText, this.headingTextStyle
  });

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading Text and Required
         Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: headingText != null,
              child: SizedBox(
                child: Text(
                  headingText ?? "", 
                  style: headingTextStyle ?? interRegular(
                    size: isWeb ? 14.sp : 13.sp, 
                    color: const Color(0xff808084)
                  ),
                ),
              ),
            ),
            SizedBox(width: isWeb ? 12.w : 8.w),
            //Required Indicator
            Visibility(
              visible: isRequired == true,
              child: Container(
                height: isWeb ? 24.h : 20.h,
                padding: EdgeInsets.fromLTRB(
                  isWeb ? 8.0.w : 5.0.w, 
                  0.0.h, 
                  isWeb ? 8.0.w : 5.0.w, 
                  isWeb ? 2.0.h : 1.6.h
                ),
                margin: EdgeInsets.only(top: isWeb ? 4.0.h : 3.0.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: const Color(0xffC13939)
                ),
                child: Center(
                  child: Text(
                    reqText ?? "requiredTag".tr, 
                    style: interRegular(
                      size: isWeb ? 13.sp : 12.sp, 
                      color: white
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ),
            ),
            // Optional Indicator
            SizedBox(width: isWeb ? 8.w : 4.w),
            Visibility(
              visible: infoText != null,
              child: Text(
                infoText ?? "", 
                style: infoTextStyle ?? interRegular(
                  size: isWeb ? 12.sp : 11.sp, 
                  color: const Color(0xff808084)
                )
              ),
            ),
          ],
        ),
        SizedBox(
          height: headingText == null ? 0 : headingTextHeight ?? (isWeb ? 12.0.h : 8.0.h),
        ),
        Visibility(
          visible: impText  != null,
          child: Padding(
            padding:  EdgeInsets.only(bottom: isWeb ? 8.0.sp : 6.0.sp),
            child: Text(
              impText ?? "", 
              style: infoTextStyle ?? interMedium(
                size: isWeb ? 13.sp : 12.sp, 
                color: red
              ),
            ),
          )
        ),
        // TextField
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            style: textStyle ?? TextStyle(
              fontSize: isWeb ? 18.sp : 16.sp, 
              color: black, 
              fontFamily: 'NotoSansJP-Regular',
              height: isWeb ? 1.6.sp : 1.5.sp
            ),
            focusNode: focusNode,
            inputFormatters: inputFormatters ?? [],
            onTap: isDisabled == true ? (){} : isSuffixLoading == true ? (){} : onTap,
            autofocus: autofocus!,
            autovalidateMode: autoValidateMode ?? AutovalidateMode.onUserInteraction,
            initialValue: initialValue,
            textCapitalization: TextCapitalization.sentences,
            controller: controller,
            obscureText: obscureText,
            readOnly: isDropdown == true ? true : readOnly,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: cursorColor ?? black,
            maxLines: maxLines ?? 1,
            maxLength: maxLength,
            decoration: InputDecoration(
              errorMaxLines: 3,
              labelText: labelText,
              hintText: hintText,
              labelStyle: labelStyle,
              hintStyle: hintStyle ?? interRegular(
                size: isWeb ? 18.sp : 16.sp, 
                color: txtGrey7
              ),
              prefixIcon: prefixIcon,
              suffixIcon: isSuffixLoading == true 
                ? Container(
                    height: isWeb ? 56.h : 48.h,
                    width: isWeb ? 56.h : 48.h,
                    padding: EdgeInsets.all(isWeb ? 16.sp : 14.sp),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xff949494),
                        strokeWidth: isWeb ? 2.0.sp : 1.8.sp,
                      ),
                    ),
                  )
                : isDropdown == true 
                  ? Icon(
                      Icons.arrow_drop_down, 
                      color: const Color(0xff808084),
                      size: isWeb ? 28.w : 24.w,
                    )
                  : suffixIcon,
              border: border ??  OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC9C9C9),
                  width: isWeb ? 2.5.sp : 2.sp
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                borderSide: BorderSide(
                  color: const Color(0xff808084),
                  width: isWeb ? 1.5.sp : 1.sp
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                borderSide: BorderSide(
                  color: const Color(0xff808084),
                  width: isWeb ? 1.5.sp : 1.sp
                ),
              ),
              fillColor: isDisabled == true ? grey2 : filledColor ?? white,
              filled: true,
              errorBorder: errorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC13939), 
                  width: isWeb ? 1.5.sp : 1.sp
                ),
              ),
              focusedErrorBorder: errorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWeb ? 12.r : 10.r),
                borderSide: BorderSide(
                  color: const Color(0xffC13939), 
                  width: isWeb ? 1.5.sp : 1.sp
                ),
              ),
              disabledBorder: disabledBorder,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isWeb ? 16.sp : 12.sp,
                vertical: isWeb ? 16.0.sp : 8.0.sp
              ),
              errorStyle: interRegular(
                size: isWeb ? 13.sp : 11.5.sp, 
                color: const Color(0xffC13939)
              ),
            ),
          ),
        ),
      ],
    );
  }
}