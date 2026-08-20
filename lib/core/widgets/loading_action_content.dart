import 'package:flutter/material.dart';

/// Shared progress content for async action buttons.
///
/// It combines an indeterminate progress indicator with a subtle animated
/// shimmer while the owning button remains disabled.
class LoadingActionContent extends StatefulWidget {
  final String label;
  final TextStyle textStyle;
  final Color color;
  final double indicatorSize;

  const LoadingActionContent({
    super.key,
    required this.label,
    required this.textStyle,
    required this.color,
    this.indicatorSize = 20,
  });

  @override
  State<LoadingActionContent> createState() => _LoadingActionContentState();
}

class _LoadingActionContentState extends State<LoadingActionContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
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
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final travel = _controller.value * 2.4 - 1.2;
            return LinearGradient(
              begin: Alignment(travel - 1, 0),
              end: Alignment(travel + 1, 0),
              colors: [
                widget.color.withValues(alpha: .62),
                widget.color,
                widget.color.withValues(alpha: .62),
              ],
              stops: const [.15, .5, .85],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: widget.indicatorSize,
            height: widget.indicatorSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: widget.color,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              style: widget.textStyle.copyWith(color: widget.color),
            ),
          ),
        ],
      ),
    );
  }
}
