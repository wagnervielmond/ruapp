import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../themes/colors.dart';

class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const QrCodeWidget({
    required this.data,
    this.size = 200,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        embeddedImage: AssetImage('assets/images/logo_mark.png'),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(size * 0.2, size * 0.2),
        ),
      ),
    );
  }
}