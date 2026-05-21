import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeklifEkleKimlikBilgileriKarti extends StatelessWidget {
  final TextEditingController teklifNoController;
  final int gecerlilikGunu;
  final ValueChanged<int> onGecerlilikGunuChanged;
  final String doviz;
  final ValueChanged<String> onDovizChanged;
  final String odemeTuru;
  final ValueChanged<String> onOdemeTuruChanged;

  const TeklifEkleKimlikBilgileriKarti({
    super.key,
    required this.teklifNoController,
    required this.gecerlilikGunu,
    required this.onGecerlilikGunuChanged,
    required this.doviz,
    required this.onDovizChanged,
    required this.odemeTuru,
    required this.onOdemeTuruChanged,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kimlik Bilgileri",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          _kucukTextField("Teklif No", teklifNoController),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "Geçerlilik:",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _secimButonu(
                      "7 Gün",
                      gecerlilikGunu == 7,
                      () => onGecerlilikGunuChanged(7),
                    ),
                    _secimButonu(
                      "14 Gün",
                      gecerlilikGunu == 14,
                      () => onGecerlilikGunuChanged(14),
                    ),
                    _secimButonu(
                      "30 Gün",
                      gecerlilikGunu == 30,
                      () => onGecerlilikGunuChanged(30),
                    ),
                    SizedBox(
                      width: 70,
                      height: 38,
                      child: TextFormField(
                        initialValue: [7, 14, 30].contains(gecerlilikGunu)
                            ? ""
                            : gecerlilikGunu.toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: "Özel",
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          final gun = int.tryParse(v);
                          if (gun != null) onGecerlilikGunuChanged(gun);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "Döviz:",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _secimButonu(
                    "TRY",
                    doviz == "TRY",
                    () => onDovizChanged("TRY"),
                  ),
                  _secimButonu(
                    "EUR",
                    doviz == "EUR",
                    () => onDovizChanged("EUR"),
                  ),
                  _secimButonu(
                    "USD",
                    doviz == "USD",
                    () => onDovizChanged("USD"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "Ödeme:",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  _secimButonu(
                    "Nakit",
                    odemeTuru == "Nakit",
                    () => onOdemeTuruChanged("Nakit"),
                  ),
                  _secimButonu(
                    "Kredi Kartı",
                    odemeTuru == "Kredi Kartı",
                    () => onOdemeTuruChanged("Kredi Kartı"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kucukTextField(String etiket, TextEditingController controller) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: etiket,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  Widget _secimButonu(String metin, bool seciliMi, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: seciliMi ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          metin,
          style: GoogleFonts.inter(
            color: seciliMi ? Colors.white : const Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
