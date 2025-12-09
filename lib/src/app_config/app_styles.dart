import 'package:flutter/material.dart';
 
//------- App Colors --------
const darkBlue    = Color(0xff04203D);
const grey        = Color(0xffEDEDED);
const grey1       = Color(0xff878787);
const grey2       = Color(0xffD9D9D9);
const grey3       = Color(0xffF5F5F5);
const grey4       = Color(0xff3C3C43);
const grey5       = Color(0xffEBEBEB);
const grey6       = Color(0xffD0D0D0);
const grey7       = Color(0xffC8C8C8);
const grey8       = Color(0xffF3F3F3);
const grey9       = Color(0xff8D8D8D);
const grey10      = Color(0xffEAEAEA);
const grey11      = Color(0xffECECEC);
const buttonGrey  = Color(0xffE9E9EA);
const darkGrey    = Color(0xff454545);
const white       = Color(0xffffffff);
const black       = Color(0xff000000);
const iconBlack   = Color(0xff323232);
const scaffoldBg  = Color(0xffF6F6F6);
const txtGrey     = Color(0xff929292);
const txtGrey1    = Color(0xff727272);
const txtGrey2    = Color(0xff909090);
const txtGrey3    = Color(0xffA9A9A9);
const txtGrey4    = Color(0xff5C5C5E);
const txtGrey5    = Color(0xff636363);
const txtGrey6    = Color(0xff808084);
const txtGrey7    = Color(0xffACAEAD);
const txtBlue     = Color(0xff50A3FF);
const txtBlack    = Color(0xff151515);
const txtBlack2   = Color(0xff3C3E42);
const txtBlack3   = Color(0xff575757);
const golden      = Color(0xffFFCC24);
const green       = Color.fromARGB(255, 91, 255, 36);
const green2      = Colors.green;
const red         = Color(0xffBC1D35);
const red2        = Color(0xffBA1E35);
const red3        = Color(0xffBC1D37);
const orange      = Color(0xffF06102);
const yellow      = Color(0xffFFC400);
 
//------- Fonts --------
TextStyle interBold({
  required double size,
  Color? color,
  double? charSpacing = 0.0,
  double? lineSpacing = 1.0,
  TextDecoration? decoration,
}) => TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w700,
  fontSize: size,
  color: color ?? const Color(0xFF707070),
  letterSpacing: charSpacing,
  height: lineSpacing,
  decoration: decoration,
);
 
TextStyle interSemiBold({
  required double size,
  Color? color,
  double? charSpacing = 0.0,
  double? lineSpacing = 1.0,
  TextDecoration? decoration,
}) => TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w600,
  fontSize: size,
  color: color ?? const Color(0xFF707070),
  letterSpacing: charSpacing,
  height: lineSpacing,
  decoration: decoration,
);
 
TextStyle interMedium({
  required double size,
  Color? color,
  double? charSpacing = 0.0,
  double? lineSpacing = 1.0,
}) => TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
  fontSize: size,
  color: color ?? const Color(0xFF707070),
  letterSpacing: charSpacing,
  height: lineSpacing,
);
 
TextStyle interRegular({
  required double size,
  Color? color,
  double? charSpacing = 0.0,
  double? lineSpacing = 1.0,
}) => TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
  fontSize: size,
  color: color ?? const Color(0xFF707070),
  letterSpacing: charSpacing,
  height: lineSpacing,
);
 