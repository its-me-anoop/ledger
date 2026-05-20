import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Scaffold that shows a 1px app-bar bottom border via opacity transition
/// driven by scroll offset. Guards with MediaQuery.disableAnimationsOf.
class ScrollBorderScaffold extends StatefulWidget {
  const ScrollBorderScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.backgroundColor,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  State<ScrollBorderScaffold> createState() => _ScrollBorderScaffoldState();
}

class _ScrollBorderScaffoldState extends State<ScrollBorderScaffold> {
  final ScrollController _controller = ScrollController();
  double _borderOpacity = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _controller.offset;
    final opacity = (offset / 16).clamp(0.0, 1.0);
    if ((opacity - _borderOpacity).abs() > 0.01) {
      setState(() => _borderOpacity = opacity);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final opacity = reduceMotion ? (_borderOpacity > 0 ? 1.0 : 0.0) : _borderOpacity;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      floatingActionButton: widget.floatingActionButton,
      body: Column(
        children: [
          Stack(
            children: [
              widget.appBar,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: opacity,
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: PrimaryScrollController(
              controller: _controller,
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
