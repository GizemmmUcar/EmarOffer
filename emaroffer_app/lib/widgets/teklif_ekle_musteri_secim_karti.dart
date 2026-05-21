import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class TeklifEkleMusteriSecimKarti extends StatelessWidget {
  final bool yeniMusteri;
  final ValueChanged<bool> onYeniMusteriChanged;
  final Map<String, dynamic>? mevcutTeklif;
  final List<dynamic> musteriler;
  final ValueChanged<int?> onMusteriSecildi;

  final TextEditingController yFirmaController;
  final TextEditingController yYetkiliController;
  final String telefonKodu;
  final TextEditingController yTelefonController;
  final TextEditingController yEpostaController;
  final String? secilenUlkeAdi;
  final String? secilenUlkeKodu;
  final ValueChanged<Country> onUlkeSecildi;
  final List<csc.State> bolgeler;
  final csc.State? secilenBolge;
  final ValueChanged<csc.State?> onBolgeSecildi;
  final List<csc.City> sehirler;
  final csc.City? secilenSehir;
  final ValueChanged<csc.City?> onSehirSecildi;
  final TextEditingController yVergiDairesiController;
  final TextEditingController yVergiNoController;
  final TextEditingController yAdresController;

  const TeklifEkleMusteriSecimKarti({
    super.key,
    required this.yeniMusteri,
    required this.onYeniMusteriChanged,
    this.mevcutTeklif,
    required this.musteriler,
    required this.onMusteriSecildi,
    required this.yFirmaController,
    required this.yYetkiliController,
    required this.telefonKodu,
    required this.yTelefonController,
    required this.yEpostaController,
    required this.secilenUlkeAdi,
    required this.secilenUlkeKodu,
    required this.onUlkeSecildi,
    required this.bolgeler,
    required this.secilenBolge,
    required this.onBolgeSecildi,
    required this.sehirler,
    required this.secilenSehir,
    required this.onSehirSecildi,
    required this.yVergiDairesiController,
    required this.yVergiNoController,
    required this.yAdresController,
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
                "Müşteri Seçimi",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Yeni Müşteri",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: yeniMusteri,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF4F46E5),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCBD5E1),
                    onChanged: onYeniMusteriChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          if (yeniMusteri) ...[
            _kucukTextField("Firma Adı", yFirmaController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kucukTextField("Yetkili Kişi", yYetkiliController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kucukTextField(
                    "Telefon",
                    yTelefonController,
                    prefixText: "$telefonKodu ",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kucukTextField("E-posta", yEpostaController)),
                const SizedBox(width: 12),
                Expanded(child: _buildUlkeSecici(context)),
              ],
            ),
            const SizedBox(height: 12),
            _buildIlIlceSecici(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _kucukTextField(
                    "Vergi Dairesi",
                    yVergiDairesiController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _kucukTextField("Vergi No", yVergiNoController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _kucukTextField("Adres", yAdresController),
          ] else ...[
            SizedBox(
              height: 48,
              child: Autocomplete<Map<String, dynamic>>(
                initialValue: TextEditingValue(
                  text: mevcutTeklif?["FirmaAdi"] ?? "",
                ),
                displayStringForOption: (option) =>
                    option["FirmaAdi"]?.toString() ?? "Bilinmeyen Firma",
                optionsBuilder: (TextEditingValue textValue) {
                  if (textValue.text.isEmpty) {
                    return musteriler.cast<Map<String, dynamic>>();
                  }
                  return musteriler.cast<Map<String, dynamic>>().where(
                    (m) => (m["FirmaAdi"]?.toString().toLowerCase() ?? "")
                        .contains(textValue.text.toLowerCase()),
                  );
                },
                onSelected: (secim) => onMusteriSecildi(secim["Id"]),
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Firma ara veya seç...",
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 250,
                          maxWidth: 350,
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          itemBuilder: (context, index) {
                            final m = options.elementAt(index);
                            return ListTile(
                              title: Text(
                                m["FirmaAdi"]?.toString() ?? "",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => onSelected(m),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUlkeSecici(BuildContext context) {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          countryListTheme: CountryListThemeData(
            bottomSheetHeight: 500,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            inputDecoration: InputDecoration(
              labelText: 'Ülke Ara',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onSelect: onUlkeSecildi,
        );
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              secilenUlkeAdi ?? "Ülke Seç",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: secilenUlkeAdi == null
                    ? const Color(0xFF64748B)
                    : const Color(0xFF0F172A),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF64748B),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIlIlceSecici() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: DropdownButtonFormField<csc.State>(
              key: ValueKey("il_$secilenUlkeKodu"),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
                size: 18,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "İl",
                labelStyle: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
              ),
              isExpanded: true,
              initialValue: secilenBolge,
              items: bolgeler
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(
                        b.name
                            .replaceAll(' Province', '')
                            .replaceAll(' State', '')
                            .trim(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onBolgeSecildi,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: DropdownButtonFormField<csc.City>(
              key: ValueKey("ilce_${secilenBolge?.isoCode}"),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF64748B),
                size: 18,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "İlçe",
                labelStyle: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 0,
                ),
              ),
              isExpanded: true,
              initialValue: secilenSehir,
              items: sehirler
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.name
                            .replaceAll(' İlçesi', '')
                            .replaceAll(' District', '')
                            .replaceAll(' Merkez', '')
                            .trim(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onSehirSecildi,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kucukTextField(
    String etiket,
    TextEditingController controller, {
    String? prefixText,
  }) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: etiket,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          prefixText: prefixText,
          prefixStyle: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}
