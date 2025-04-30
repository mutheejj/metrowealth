import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveHelper {
  static const double mobileBreakpoint = 650;
  static const double tabletBreakpoint = 1100;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) => 
      getDeviceType(context) == DeviceType.mobile;
  
  static bool isTablet(BuildContext context) => 
      getDeviceType(context) == DeviceType.tablet;
  
  static bool isDesktop(BuildContext context) => 
      getDeviceType(context) == DeviceType.desktop;

  static double getResponsiveFontSize(BuildContext context, {
    required double baseFontSize,
    double? minFontSize,
    double? maxFontSize,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return maxFontSize != null 
            ? (baseFontSize * 1.15).clamp(minFontSize ?? baseFontSize, maxFontSize)
            : baseFontSize * 1.15;
      case DeviceType.desktop:
        return maxFontSize != null 
            ? (baseFontSize * 1.3).clamp(minFontSize ?? baseFontSize, maxFontSize) 
            : baseFontSize * 1.3;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  static double getContentMaxWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return MediaQuery.of(context).size.width;
      case DeviceType.tablet:
        return 700;
      case DeviceType.desktop:
        return 1200;
    }
  }
} 