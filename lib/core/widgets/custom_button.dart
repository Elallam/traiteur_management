import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool outlined;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.icon,
    this.outlined = false,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Remove double.infinity to allow button to fit content
      height: height,
      child: outlined ? _buildOutlinedButton() : _buildElevatedButton(),
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size.zero, // Allows button to shrink to content size
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduces tap target to content size
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor ?? AppColors.primary,
        side: BorderSide(
          color: backgroundColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    final content = Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w500,
        color: outlined
            ? backgroundColor ?? AppColors.primary
            : textColor ?? AppColors.white,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min, // Makes row take minimum space
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: fontSize != null ? fontSize! * 0.75 : 16),
          const SizedBox(width: 8), // Increased spacing
          content,
        ],
      );
    }

    return content;
  }
}