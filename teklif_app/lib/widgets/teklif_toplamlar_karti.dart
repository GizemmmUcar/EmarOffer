import 'package:flutter/material.dart';

class TeklifToplamlarKarti extends StatelessWidget {
  final double araToplam;
  final double toplamIndirim;
  final double kdvHaricTutar;
  final double toplamKdv;
  final double genelToplam;
  final String doviz;

  const TeklifToplamlarKarti({
    super.key,
    required this.araToplam,
    required this.toplamIndirim,
    required this.kdvHaricTutar,
    required this.toplamKdv,
    required this.genelToplam,
    required this.doviz,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hesap Özeti",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const Divider(height: 12),
          _ozetSatiri("Ara Toplam:", araToplam),
          const SizedBox(height: 6),
          _ozetSatiri("Toplam İndirim:", -toplamIndirim, renk: Colors.red),
          const Divider(),
          _ozetSatiri("KDV Hariç Tutar:", kdvHaricTutar),
          _ozetSatiri("Toplam KDV:", toplamKdv, renk: Colors.blueGrey),
          const Divider(height: 24, thickness: 1.2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "GENEL TOPLAM:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "${genelToplam.toStringAsFixed(2)} $doviz",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ozetSatiri(
    String etiket,
    double deger, {
    Color? renk,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiket,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "${deger.toStringAsFixed(2)} $doviz",
          style: TextStyle(
            color: renk,
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
