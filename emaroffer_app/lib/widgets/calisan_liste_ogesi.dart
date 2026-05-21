import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalisanTabloBasliklari extends StatelessWidget {
  const CalisanTabloBasliklari({super.key});

  Widget _hucre(
    String metin, {
    int? flex,
    double? genislik,
    bool ortala = false,
  }) {
    Widget icerik = Text(
      metin,
      textAlign: ortala ? TextAlign.center : TextAlign.left,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
        fontSize: 10,
        letterSpacing: 0.5,
      ),
    );
    return genislik != null
        ? SizedBox(
            width: genislik,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icerik,
            ),
          )
        : Expanded(
            flex: flex ?? 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icerik,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _hucre("NO", genislik: 50, ortala: true),
          _hucre("AD SOYAD", flex: 3),
          _hucre("E-POSTA", flex: 3),
          _hucre("ROL / YETKİ", flex: 2),
          _hucre("İŞLEMLER", genislik: 120),
        ],
      ),
    );
  }
}

class CalisanTabloSatiri extends StatelessWidget {
  final int index;
  final dynamic calisan;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const CalisanTabloSatiri({
    super.key,
    required this.index,
    required this.calisan,
    required this.onDuzenle,
    required this.onSil,
  });

  Widget _hucreText(
    String metin, {
    int? flex,
    double? genislik,
    bool ortala = false,
    bool bold = false,
    Color? color,
  }) {
    Widget icerik = Text(
      metin,
      textAlign: ortala ? TextAlign.center : TextAlign.left,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: color ?? const Color(0xFF0F172A),
      ),
    );
    return genislik != null
        ? SizedBox(
            width: genislik,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icerik,
            ),
          )
        : Expanded(
            flex: flex ?? 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: icerik,
            ),
          );
  }

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _hucreText(
            "${index + 1}",
            genislik: 50,
            ortala: true,
            color: const Color(0xFF64748B),
          ),
          _hucreText(
            calisan["AdSoyad"]?.toString() ?? "-",
            flex: 3,
            bold: true,
          ),
          _hucreText(
            calisan["Eposta"]?.toString() ?? "-",
            flex: 3,
            color: const Color(0xFF64748B),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  calisan["RolAdi"]?.toString() ?? "Bilinmiyor",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
          ),
        ],
      ),
    );
  }
}

class CalisanMobilKarti extends StatelessWidget {
  final dynamic calisan;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const CalisanMobilKarti({
    super.key,
    required this.calisan,
    required this.onDuzenle,
    required this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  calisan["AdSoyad"]?.toString() ?? "-",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  calisan["RolAdi"]?.toString() ?? "Bilinmiyor",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  calisan["Eposta"]?.toString() ?? "-",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _mobilButon(
                Icons.edit_outlined,
                const Color(0xFF3B82F6),
                "Düzenle",
                onDuzenle,
              ),
              const SizedBox(width: 8),
              _mobilButon(
                Icons.delete_outline_rounded,
                const Color(0xFFEF4444),
                "Sil",
                onSil,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mobilButon(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              tooltip,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
