import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class UrunListeOgesi extends StatelessWidget {
  final dynamic urun;
  final VoidCallback onDetayGoster;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;
  final VoidCallback? onGaleriGoster;

  const UrunListeOgesi({
    super.key,
    required this.urun,
    required this.onDetayGoster,
    required this.onDuzenle,
    required this.onSil,
    this.onGaleriGoster,
  });

  Widget _actionButton(
    Color primaryColor,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, size: 16, color: primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urunKodu = (urun["UrunKodu"] ?? urun["UrunKodu"])?.toString() ?? "";
    List<String> urunGorselleri = [];
    final rawGorsel = urun["UrunGorsel"]?.toString() ?? "";
    if (rawGorsel.isNotEmpty) {
      if (rawGorsel.trimLeft().startsWith('[')) {
        try {
          urunGorselleri = List<String>.from(jsonDecode(rawGorsel));
        } catch (_) {
          urunGorselleri = [rawGorsel];
        }
      } else {
        urunGorselleri = [rawGorsel];
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          InkWell(
            onTap: onGaleriGoster,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: urunGorselleri.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(
                          urunGorselleri[0].replaceAll(RegExp(r'\s+'), ''),
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.broken_image,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF64748B),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  urun["UrunAdi"]?.toString() ?? "Bilinmeyen Ürün",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (urunKodu.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          urunKodu,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        "${urun["BirimFiyati"]} ${urun["ParaBirimi"] ?? 'TRY'}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionButton(
                const Color(0xFF14B8A6),
                Icons.info_outline_rounded,
                "Detayları Gör",
                onDetayGoster,
              ),
              _actionButton(
                const Color(0xFF3B82F6),
                Icons.edit_outlined,
                "Düzenle",
                onDuzenle,
              ),
              _actionButton(
                const Color(0xFFEF4444),
                Icons.delete_outline_rounded,
                "Sil",
                onSil,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
