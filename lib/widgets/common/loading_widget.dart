import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

class LoadingWidget extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const LoadingWidget({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? AppDimensions.loadingIndicatorSize,
      height: size ?? AppDimensions.loadingIndicatorSize,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth ?? AppDimensions.loadingIndicatorStroke,
      ),
    );
  }
}

class CupertinoLoadingWidget extends StatelessWidget {
  final double? radius;
  final Color? color;

  const CupertinoLoadingWidget({
    super.key,
    this.radius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius ?? AppDimensions.loadingIndicatorSize / 2,
      color: color ?? AppColors.primary,
    );
  }
}

class CustomLoadingWidget extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const CustomLoadingWidget({
    super.key,
    this.size = 40.0,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2.0 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  widget.color.withValues(alpha: 0.1),
                  widget.color,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DotsLoadingWidget extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const DotsLoadingWidget({
    super.key,
    this.color = AppColors.primary,
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<DotsLoadingWidget> createState() => _DotsLoadingWidgetState();
}

class _DotsLoadingWidgetState extends State<DotsLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(_animation1),
        SizedBox(width: widget.size / 2),
        _buildDot(_animation2),
        SizedBox(width: widget.size / 2),
        _buildDot(_animation3),
      ],
    );
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.3 + (animation.value * 0.7)),
          ),
        );
      },
    );
  }
}