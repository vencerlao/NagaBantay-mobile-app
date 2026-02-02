import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  // --- ADD THIS LINE ---
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    // --- ADD THIS LINE ---
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottom = math.max(viewPadding.bottom, viewInsets.bottom);

    return Scaffold(
      // --- MAP THE VALUE HERE ---
      backgroundColor: backgroundColor,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : Padding(
        padding: EdgeInsets.only(bottom: viewPadding.bottom),
        child: bottomNavigationBar,
      ),
      body: SafeArea(
        child: AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottom),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: body,
        ),
      ),
    );
  }
}