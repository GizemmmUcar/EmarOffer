import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeklifTabloBasliklari extends StatelessWidget {
  const TeklifTabloBasliklari({super.key});

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
          _hucre("TEKLİF NO", flex: 4),
          _hucre("MÜŞTERİ / FİRMA", flex: 4),
          _hucre("OLUŞTURAN", flex: 2),
          _hucre("TARİHLER", flex: 3),
          _hucre("TUTAR", flex: 3),
          _hucre("İNDİRİM", flex: 3, ortala: true),
          _hucre("DURUM", flex: 3),
          _hucre("İŞLEMLER", genislik: 180),
        ],
      ),
    );
  }
}

class TeklifTabloSatiri extends StatelessWidget {
  final int index;
  final dynamic teklif;
  final Function(int, String) onDurumGuncelle;
  final VoidCallback onDetayGoster;
  final VoidCallback onPdfGoster;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const TeklifTabloSatiri({
    super.key,
    required this.index,
    required this.teklif,
    required this.onDurumGuncelle,
    required this.onDetayGoster,
    required this.onPdfGoster,
    required this.onDuzenle,
    required this.onSil,
  });

  String _tarihFormatla(dynamic tarih) {
    if (tarih == null) return "-";
    String t = tarih.toString();
    if (t.contains("T")) {
      List<String> parcalar = t.split("T")[0].split("-");
      if (parcalar.length == 3) {
        return "${parcalar[2]}.${parcalar[1]}.${parcalar[0]}";
      }
    }
    return t;
  }

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
        color: color,
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

  Widget _actionBtn(
    IconData icon,
    Color color,
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final durum = teklif["Durum"]?.toString() ?? "Bekliyor";
    Color durumRenk = durum == "Kabul Edildi"
        ? const Color(0xFF10B981)
        : durum == "Reddedildi"
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final doviz = teklif["Doviz"]?.toString() ?? "TRY";
    final olusturma = _tarihFormatla(teklif["OlusturmaTarihi"]);
    final gecerlilik = _tarihFormatla(teklif["GecerlilikTarihi"]);

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
            teklif["TeklifNo"]?.toString() ?? "-",
            flex: 4,
            bold: true,
            color: const Color(0xFF0F172A),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teklif["FirmaAdi"]?.toString() ?? "-",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Müşteri",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _hucreText("Admin", flex: 2, color: const Color(0xFF64748B)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          olusturma,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.update,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          gecerlilik,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _hucreText(
            "${teklif["GenelToplam"]} $doviz",
            flex: 3,
            bold: true,
            color: const Color(0xFF0F172A),
          ),
          _hucreText(
            "-${teklif["ToplamIndirim"]} $doviz",
            flex: 3,
            ortala: true,
            color: const Color(0xFFEF4444),
            bold: true,
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PopupMenuButton<String>(
                initialValue: durum,
                tooltip: "Durumu Değiştir",
                position: PopupMenuPosition.under,
                offset: const Offset(0, 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: durumRenk.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: durumRenk.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: durumRenk,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          durum,
                          style: GoogleFonts.inter(
                            color: durumRenk,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: durumRenk,
                      ),
                    ],
                  ),
                ),
                onSelected: (yeniDurum) =>
                    onDurumGuncelle(teklif["Id"], yeniDurum),
                itemBuilder: (context) =>
                    ["Bekliyor", "Kabul Edildi", "Reddedildi"]
                        .map(
                          (d) => PopupMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _actionBtn(
                  Icons.info_outline,
                  const Color(0xFF10B981),
                  "Detay",
                  onDetayGoster,
                ),
                _actionBtn(
                  Icons.picture_as_pdf_outlined,
                  const Color(0xFF8B5CF6),
                  "PDF",
                  onPdfGoster,
                ),
                _actionBtn(
                  Icons.edit_outlined,
                  const Color(0xFF3B82F6),
                  "Düzenle",
                  onDuzenle,
                ),
                _actionBtn(
                  Icons.delete_outline,
                  const Color(0xFFEF4444),
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

class TeklifMobilKarti extends StatelessWidget {
  final dynamic teklif;
  final Function(int, String) onDurumGuncelle;
  final VoidCallback onDetayGoster;
  final VoidCallback onPdfGoster;
  final VoidCallback onDuzenle;
  final VoidCallback onSil;

  const TeklifMobilKarti({
    super.key,
    required this.teklif,
    required this.onDurumGuncelle,
    required this.onDetayGoster,
    required this.onPdfGoster,
    required this.onDuzenle,
    required this.onSil,
  });

  String _tarihFormatla(dynamic tarih) {
    if (tarih == null) return "-";
    String t = tarih.toString();
    if (t.contains("T")) {
      List<String> parcalar = t.split("T")[0].split("-");
      if (parcalar.length == 3) {
        return "${parcalar[2]}.${parcalar[1]}.${parcalar[0]}";
      }
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final durum = teklif["Durum"]?.toString() ?? "Bekliyor";
    Color durumRenk = durum == "Kabul Edildi"
        ? const Color(0xFF10B981)
        : durum == "Reddedildi"
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final doviz = teklif["Doviz"]?.toString() ?? "TRY";
    final olusturma = _tarihFormatla(teklif["OlusturmaTarihi"]);

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
              Text(
                teklif["TeklifNo"]?.toString() ?? "-",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
              PopupMenuButton<String>(
                initialValue: durum,
                onSelected: (yeniDurum) =>
                    onDurumGuncelle(teklif["Id"], yeniDurum),
                itemBuilder: (context) =>
                    ["Bekliyor", "Kabul Edildi", "Reddedildi"]
                        .map(
                          (d) => PopupMenuItem(
                            value: d,
                            child: Text(
                              d,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: durumRenk.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    durum,
                    style: TextStyle(
                      color: durumRenk,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            teklif["FirmaAdi"]?.toString() ?? "-",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    olusturma,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                "${teklif["GenelToplam"]} $doviz",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _mobilIslemButon(
                Icons.info_outline,
                const Color(0xFF10B981),
                "Detay",
                onDetayGoster,
              ),
              _mobilIslemButon(
                Icons.picture_as_pdf_outlined,
                const Color(0xFF8B5CF6),
                "PDF",
                onPdfGoster,
              ),
              _mobilIslemButon(
                Icons.edit_outlined,
                const Color(0xFF3B82F6),
                "Düzenle",
                onDuzenle,
              ),
              _mobilIslemButon(
                Icons.delete_outline,
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

  Widget _mobilIslemButon(
    IconData icon,
    Color renk,
    String etiket,
    VoidCallback tap,
  ) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: renk, size: 20),
            const SizedBox(height: 4),
            Text(
              etiket,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: renk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
