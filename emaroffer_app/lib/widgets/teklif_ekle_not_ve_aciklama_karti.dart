import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeklifEkleNotVeAciklamaKarti extends StatelessWidget {
  final TextEditingController notController;

  const TeklifEkleNotVeAciklamaKarti({super.key, required this.notController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Genel Not / Açıklama",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          TextField(
            controller: notController,
            minLines: 4,
            maxLines: 6,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Özel notlar...",
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
