import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SablonSolPanel extends StatelessWidget {
  final TextEditingController sablonAdiController;
  final String seciliYaziTipi;
  final List<String> desteklenenFontlar;
  final ValueChanged<String?> onYaziTipiChanged;
  final Color anaRenk;
  final Color ikinciRenk;
  final VoidCallback onAnaRenkAc;
  final VoidCallback onIkinciRenkAc;
  final bool logoGoster;
  final ValueChanged<bool> onLogoGosterChanged;
  final VoidCallback onGenelAyarlarAc;
  final List<String> bloklar;
  final void Function(int, int) onReorder;
  final Function(String) onBlokAyarlariAc;

  const SablonSolPanel({
    super.key,
    required this.sablonAdiController,
    required this.seciliYaziTipi,
    required this.desteklenenFontlar,
    required this.onYaziTipiChanged,
    required this.anaRenk,
    required this.ikinciRenk,
    required this.onAnaRenkAc,
    required this.onIkinciRenkAc,
    required this.logoGoster,
    required this.onLogoGosterChanged,
    required this.onGenelAyarlarAc,
    required this.bloklar,
    required this.onReorder,
    required this.onBlokAyarlariAc,
  });

  String _blokBasligiGetir(String key) {
    switch (key) {
      case 'BASLIK':
        return 'Firma Logosu / Başlık';
      case 'SIRKET':
        return 'Şirket Bilgileri';
      case 'MUSTERI':
        return 'Müşteri Bilgileri';
      case 'TABLO':
        return 'Ürün ve Fiyat Tablosu';
      case 'NOTLAR':
        return 'Şartlar ve Açıklamalar';
      case 'TOPLAMLAR':
        return 'Ara Toplam ve KDV';
      case 'IMZA':
        return 'Kaşe ve İmza Alanı';
      default:
        return key;
    }
  }

  Widget _renkButonu(String t, Color c, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Metinleri, boyutları ve renkleri değiştirmek için sağdaki önizleme üzerinde yazılara tıklayın.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF3730A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: sablonAdiController,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Şablon İsmi',
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              "Görünüm ve Tasarım",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(seciliYaziTipi),
                initialValue: desteklenenFontlar.contains(seciliYaziTipi)
                    ? seciliYaziTipi
                    : 'Inter',
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                ),
                decoration: InputDecoration(
                  labelText: "Yazı Tipi (Font)",
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                  ),
                ),
                items: desteklenenFontlar.map((fontAdi) {
                  return DropdownMenuItem(
                    value: fontAdi,
                    child: Text(
                      fontAdi,
                      style: GoogleFonts.getFont(
                        fontAdi,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onYaziTipiChanged,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _renkButonu("Ana Renk", anaRenk, onAnaRenkAc),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _renkButonu("Tablo", ikinciRenk, onIkinciRenkAc),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  "Firma Logosunu Göster",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF4F46E5),
                value: logoGoster,
                onChanged: onLogoGosterChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "Düzen ve Hizalama",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGenelAyarlarAc,
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(
                    "Genel Sayfa Margini & Satır Aralığı",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Blok Sıralaması (Sürükle-Bırak)",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder: onReorder,
                  children: bloklar.asMap().entries.map((entry) {
                    int index = entry.key;
                    String b = entry.value;
                    return Container(
                      key: ValueKey(b),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: ListTile(
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_indicator_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _blokBasligiGetir(b),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          onPressed: () => onBlokAyarlariAc(b),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        dense: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
