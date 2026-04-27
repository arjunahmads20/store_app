import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double deltaX;
  final Curve curve;
  final VoidCallback? onAnimationComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
    this.onAnimationComplete,
  });

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController searchController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    searchController = AnimationController(
        duration: widget.duration, vsync: this);
    
    // Create a sine wave like animation for shaking
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: searchController,
      curve: widget.curve,
    ));
    
    searchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        searchController.reset();
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void shake() {
    searchController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final sineValue = sin(4 * pi * animation.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.deltaX, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
