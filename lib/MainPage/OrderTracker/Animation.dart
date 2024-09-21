import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AnimatedTimelineTile extends StatefulWidget {
  final String text;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  AnimatedTimelineTile({
    required this.text,
    required this.isActive,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  _AnimatedTimelineTileState createState() => _AnimatedTimelineTileState();
}

class _AnimatedTimelineTileState extends State<AnimatedTimelineTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 30, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(begin: Colors.grey, end: Colors.blueAccent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTimelineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
        return TimelineTile(
          axis: TimelineAxis.vertical,
          alignment: TimelineAlign.start,
          lineXY: 0.2,
          isLast: widget.isLast,
          indicatorStyle: IndicatorStyle(
            width: _sizeAnimation.value,
            height: _sizeAnimation.value,
            color: _colorAnimation.value ?? Colors.grey, // Provide default color if null
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: widget.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
          ),
          beforeLineStyle: LineStyle(
            color: widget.isCompleted ? Colors.blueAccent : Colors.grey,
            thickness: 4,
          ),
          afterLineStyle: LineStyle(
            color: widget.isLast ? Colors.transparent : (widget.isCompleted ? Colors.blueAccent : Colors.grey),
            thickness: 4,
          ),
          endChild: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
