import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SablonKarti extends StatelessWidget {
  final dynamic sablon;
  final VoidCallback onDuzenle;
  final VoidCallback? onSil;

  const SablonKarti({
    super.key,
    required this.sablon,
    required this.onDuzenle,
    this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    Color anaRenk = Color(
      int.parse(
        (sablon['AnaRenk'] ?? '#1E5084').replaceFirst('#', 'FF'),
        radix: 16,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: anaRenk.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: anaRenk.withValues(alpha: 0.1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 40,
                    color: anaRenk.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sablon['SablonAdi'] ?? 'İsimsiz Şablon',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onDuzenle,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(
                        "Düzenle",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        backgroundColor: const Color(
                          0xFF4F46E5,
                        ).withValues(alpha: 0.05),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (onSil != null)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 18,
                          ),
                          tooltip: "Sil",
                          onPressed: onSil,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
