import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UstProfilBari extends StatelessWidget {
  final String kullaniciAdi;

  const UstProfilBari({super.key, required this.kullaniciAdi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Hoş Geldiniz,",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                kullaniciAdi,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF8FAFC),
              radius: 18,
              child: Text(
                kullaniciAdi.isNotEmpty ? kullaniciAdi[0].toUpperCase() : "U",
                style: GoogleFonts.inter(
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
