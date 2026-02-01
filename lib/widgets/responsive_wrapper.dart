import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Responsive wrapper that limits max width on desktop and centers content.
/// On mobile, content takes full width. On desktop/web, content is centered with max width.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),
      );
    }
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}
