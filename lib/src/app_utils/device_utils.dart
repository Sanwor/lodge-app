import 'package:flutter/foundation.dart';

class DeviceUtils {
  static bool get isMobile => !kIsWeb || (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  
  static bool get isWeb => kIsWeb;
  
  static bool get isDesktop => kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux);
  
  static double get responsivePadding {
    if (isWeb) return 40.0;
    return 20.0;
  }
  
  static double get maxContentWidth {
    if (isWeb) return 1200.0;
    return double.infinity;
  }
}