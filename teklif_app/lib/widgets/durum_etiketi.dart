import 'package:flutter/material.dart';

class DurumEtiketi extends StatelessWidget {
  final String durum;

  const DurumEtiketi({super.key, required this.durum});

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    Color textColor;

    String guvenliDurum = durum.trim().toLowerCase();

    switch (guvenliDurum) {
      case "bekliyor":
        labelColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        break;
      case "onaylandı":
      case "kabul edildi":
        labelColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        break;
      case "reddedildi":
        labelColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        break;
      case "yeni":
        labelColor = Colors.blue[50]!;
        textColor = Colors.blue[800]!;
        break;
      default:
        labelColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

      decoration: BoxDecoration(
        color: labelColor,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Text(
        durum,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
