import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final double borderRadius;
  final Widget? icon;
  final bool iconOnRight;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF145931),
    this.textColor = Colors.white,
    this.elevation = 6.0,
    this.borderRadius = 12.0,
    this.icon,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );

    List<Widget> children = icon != null
        ? iconOnRight
            ? [textWidget, const SizedBox(width: 8), icon!]
            : [icon!, const SizedBox(width: 8), textWidget]
        : [textWidget];

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? backgroundColor : backgroundColor.withOpacity(0.6),
          elevation: elevation,
          padding: const EdgeInsets.symmetric(vertical: 21),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
