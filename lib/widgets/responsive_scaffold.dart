import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A lightweight wrapper that helps avoid bottom overflow by accounting for
/// both the system navigation bars (safe area) and the keyboard (viewInsets).
///
/// Usage:
/// Replace `Scaffold(body: SafeArea(child: ...))` with
/// `ResponsiveScaffold(appBar: ..., body: ..., bottomNavigationBar: ..., )`.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final FloatingActionButton? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    // viewPadding: areas consumed by system UI (status bar, nav bar)
    // viewInsets: areas covered by IME (keyboard)
    final viewPadding = MediaQuery.of(context).viewPadding;
    final viewInsets = MediaQuery.of(context).viewInsets;

    // bottom padding should be the max of system bottom and keyboard bottom so
    // we reserve space for either.
    final bottom = math.max(viewPadding.bottom, viewInsets.bottom);

    return Scaffold(
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
