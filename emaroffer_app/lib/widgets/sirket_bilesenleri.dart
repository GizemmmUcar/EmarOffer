import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SirketKategoriKarti extends StatelessWidget {
  final String baslik;
  final IconData baslikIcon;
  final Color iconRenk;
  final List<Widget> cocuklar;

  const SirketKategoriKarti({
    super.key,
    required this.baslik,
    required this.baslikIcon,
    this.iconRenk = const Color(0xFF4F46E5),
    required this.cocuklar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconRenk.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(baslikIcon, color: iconRenk, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                baslik,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          ...cocuklar,
        ],
      ),
    );
  }
}

class SirketInputAlani extends StatelessWidget {
  final String etiket;
  final TextEditingController controller;
  final int maxLines;
  final IconData? icon;

  const SirketInputAlani({
    super.key,
    required this.etiket,
    required this.controller,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: etiket,
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF94A3B8), size: 20)
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
