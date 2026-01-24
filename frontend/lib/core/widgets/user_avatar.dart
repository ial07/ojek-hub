import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 24.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.pastelGreen,
      backgroundImage: _getImageProvider(),
      child: _buildChild(),
    );
  }

  ImageProvider? _getImageProvider() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    }
    return null;
  }

  Widget? _buildChild() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return null; // Image is shown via backgroundImage
    }

    return Text(
      _getInitials(name),
      style: TextStyle(
        color: textColor ?? AppColors.primaryBlack,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.8,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }
}
