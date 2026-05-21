import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeklifPdfSolPanel extends StatelessWidget {
  final List<dynamic> sablonlar;
  final dynamic seciliSablon;
  final ValueChanged<dynamic> onSablonSecildi;
  final String seciliDil;
  final ValueChanged<String> onDilSecildi;
  final VoidCallback onSablonYonetimiTiklandi;

  const TeklifPdfSolPanel({
    super.key,
    required this.sablonlar,
    required this.seciliSablon,
    required this.onSablonSecildi,
    required this.seciliDil,
    required this.onDilSecildi,
    required this.onSablonYonetimiTiklandi,
  });

  Color _hexToColor(String hexString) {
    hexString = hexString.replaceAll('#', '');
    if (hexString.length == 6) hexString = 'FF$hexString';
    return Color(int.parse(hexString, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tasarım Şablonu",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sablonlar.length,
              itemBuilder: (context, index) {
                final s = sablonlar[index];
                bool isSelected = seciliSablon?['Id'] == s['Id'];
                Color anaRenk = _hexToColor(s['AnaRenk'] ?? '#374151');

                return GestureDetector(
                  onTap: () => onSablonSecildi(s),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF1F5F9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: anaRenk,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: anaRenk.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s['SablonAdi'],
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: const Color(0xFF0F172A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF4F46E5),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32, color: Color(0xFFE2E8F0)),
          Text(
            "Belge Dili",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDilSecildi('TR'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: seciliDil == 'TR'
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: seciliDil == 'TR'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          "Türkçe (TR)",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: seciliDil == 'TR'
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: seciliDil == 'TR'
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDilSecildi('EN'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: seciliDil == 'EN'
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: seciliDil == 'EN'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          "English (EN)",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: seciliDil == 'EN'
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: seciliDil == 'EN'
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSablonYonetimiTiklandi,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                "Şablonları Yönet",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
