import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MusteriTabloBasliklari extends StatelessWidget {
  const MusteriTabloBasliklari({super.key});

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
          _hucre("FİRMA ADI / YETKİLİ", flex: 6),
          _hucre("İLETİŞİM", flex: 5),
          _hucre("LOKASYON", flex: 4),
          _hucre("İŞLEMLER", genislik: 140),
        ],
      ),
    );
  }
}

class MusteriTabloSatiri extends StatelessWidget {
  final int index;
  final dynamic musteri;
  final VoidCallback onDetayGoster;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const MusteriTabloSatiri({
    super.key,
    required this.index,
    required this.musteri,
    required this.onDetayGoster,
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
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musteri["FirmaAdi"]?.toString() ?? "-",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    musteri["YetkiliKisi"]?.toString() ?? "-",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musteri["Telefon"]?.toString() ?? "-",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    musteri["Eposta"]?.toString() ?? "-",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _hucreText(
            "${musteri["Sehir"] ?? "-"} / ${musteri["Ulke"] ?? "-"}",
            flex: 4,
            color: const Color(0xFF64748B),
          ),
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _actionButton(
                  const Color(0xFF14B8A6),
                  Icons.info_outline_rounded,
                  "Detay",
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
          ),
        ],
      ),
    );
  }
}

class MusteriMobilKarti extends StatelessWidget {
  final dynamic musteri;
  final VoidCallback onDetayGoster;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const MusteriMobilKarti({
    super.key,
    required this.musteri,
    required this.onDetayGoster,
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
          Text(
            musteri["FirmaAdi"]?.toString() ?? "-",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            musteri["YetkiliKisi"]?.toString() ?? "-",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                musteri["Telefon"]?.toString() ?? "-",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  musteri["Eposta"]?.toString() ?? "-",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${musteri["Sehir"] ?? "-"} / ${musteri["Ulke"] ?? "-"}",
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
                Icons.info_outline_rounded,
                const Color(0xFF14B8A6),
                "Detay",
                onDetayGoster,
              ),
              const SizedBox(width: 8),
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
