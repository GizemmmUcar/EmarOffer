import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hesap Özeti",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          _ozetSatiri("Ara Toplam", araToplam),
          const SizedBox(height: 8),
          _ozetSatiri(
            "Toplam İndirim",
            -toplamIndirim,
            renk: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 8),
          _ozetSatiri("KDV Hariç Tutar", kdvHaricTutar),
          const SizedBox(height: 8),
          _ozetSatiri("Toplam KDV", toplamKdv, renk: const Color(0xFF64748B)),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "GENEL TOPLAM",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                "${genelToplam.toStringAsFixed(2)} $doviz",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: const Color(0xFF4F46E5),
                  letterSpacing: -0.5,
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
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          "${deger.toStringAsFixed(2)} $doviz",
          style: GoogleFonts.inter(
            color: renk ?? const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
