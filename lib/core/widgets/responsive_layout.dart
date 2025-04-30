import 'package:flutter/material.dart';
import 'package:metrowealth/core/utils/responsive_helper.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final Color? color;
  final Decoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.alignment,
    this.color,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.getContentMaxWidth(context),
        ),
        alignment: alignment,
        color: color,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRow({
    super.key, 
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    
    // For mobile, stack vertically
    if (deviceType == DeviceType.mobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacingColumn(children, spacing),
      );
    }
    
    // For tablet and desktop, display in a row
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacingRow(children, spacing),
    );
  }
  
  List<Widget> _addSpacingColumn(List<Widget> children, double spacing) {
    final List<Widget> spacedChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    
    return spacedChildren;
  }
  
  List<Widget> _addSpacingRow(List<Widget> children, double spacing) {
    final List<Widget> spacedChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(Expanded(child: children[i]));
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    
    return spacedChildren;
  }
} 