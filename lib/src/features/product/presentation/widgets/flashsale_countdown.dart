import 'dart:async';
import 'package:flutter/material.dart';

class FlashsaleCountdown extends StatefulWidget {
  final DateTime endTime;
  final Color? color;
  final Color? textColor;

  const FlashsaleCountdown({
    super.key,
    required this.endTime,
    this.color,
    this.textColor,
  });

  @override
  State<FlashsaleCountdown> createState() => _FlashsaleCountdownState();
}

class _FlashsaleCountdownState extends State<FlashsaleCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _calculateRemaining();
      });
    }
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (now.isAfter(widget.endTime)) {
      if (mounted) {
        setState(() => _remaining = Duration.zero);
      }
      _timer?.cancel();
    } else {
      if (mounted) {
        setState(() => _remaining = widget.endTime.difference(now));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return const SizedBox.shrink();
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    final effectiveTextColor = widget.textColor ?? Colors.red;
    final effectiveBgColor = widget.color ?? Colors.redAccent.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: effectiveTextColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: effectiveTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
