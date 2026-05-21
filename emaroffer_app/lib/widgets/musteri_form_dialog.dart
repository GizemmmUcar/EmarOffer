import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import '../services/api_service.dart';

class MusteriFormDialog extends StatefulWidget {
  final Map<String, dynamic>? musteri;
  final ApiService apiService;
  final VoidCallback onKaydedildi;

  const MusteriFormDialog({
    super.key,
    this.musteri,
    required this.apiService,
    required this.onKaydedildi,
  });

  @override
  State<MusteriFormDialog> createState() => _MusteriFormDialogState();
}

class _MusteriFormDialogState extends State<MusteriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _firmaController;
  late final TextEditingController _yetkiliController;
  late final TextEditingController _telefonController;
  late final TextEditingController _epostaController;
  late final TextEditingController _vdController;
  late final TextEditingController _vnoController;
  late final TextEditingController _adresController;

  String? _secilenUlkeAdi;
  String? _secilenUlkeKodu;
  String _telefonKodu = "+90";
  List<csc.State> _bolgeler = [];
  csc.State? _secilenBolge;

  List<csc.City> _sehirler = [];
  csc.City? _secilenSehir;

  @override
  void initState() {
    super.initState();
    final m = widget.musteri;

    _secilenUlkeAdi = m?["Ulke"]?.toString() ?? "Türkiye";
    if (_secilenUlkeAdi == "Türkiye") {
      _secilenUlkeKodu = "TR";
      _telefonKodu = "+90";
    }
    _firmaController = TextEditingController(
      text: m?["FirmaAdi"]?.toString() ?? "",
    );
    _yetkiliController = TextEditingController(
      text: m?["YetkiliKisi"]?.toString() ?? "",
    );
    String tel = m?["Telefon"]?.toString() ?? "";
    if (tel.startsWith(_telefonKodu)) {
      tel = tel.substring(_telefonKodu.length).trim();
    }
    _telefonController = TextEditingController(text: tel);
    _epostaController = TextEditingController(
      text: m?["Eposta"]?.toString() ?? "",
    );
    _vdController = TextEditingController(
      text: m?["VergiDairesi"]?.toString() ?? "",
    );
    _vnoController = TextEditingController(
      text: m?["VergiNo"]?.toString() ?? "",
    );
    _adresController = TextEditingController(
      text: m?["Adres"]?.toString() ?? "",
    );

    if (_secilenUlkeKodu != null) {
      _kayitliLokasyonuYukle(m?["Sehir"]?.toString(), m?["Ilce"]?.toString());
    }
  }

  Future<void> _kayitliLokasyonuYukle(
    String? kayitliSehir,
    String? kayitliIlce,
  ) async {
    final bolgeler = await csc.getStatesOfCountry(_secilenUlkeKodu!);
    csc.State? eslesenBolge;

    if (kayitliSehir != null && kayitliSehir.isNotEmpty) {
      try {
        eslesenBolge = bolgeler.firstWhere((b) {
          String temizAd = b.name
              .replaceAll(' Province', '')
              .replaceAll(' State', '')
              .trim();
          return temizAd.toLowerCase() == kayitliSehir.toLowerCase();
        });
      } catch (e) {
        //
      }
    }

    List<csc.City> sehirler = [];
    csc.City? eslesenSehir;

    if (eslesenBolge != null) {
      final hamSehirler = await csc.getStateCities(
        _secilenUlkeKodu!,
        eslesenBolge.isoCode,
      );
      final Map<String, csc.City> benzersizMap = {};

      for (var s in hamSehirler) {
        String temizAd = s.name
            .replaceAll(' İlçesi', '')
            .replaceAll(' District', '')
            .replaceAll(' Merkez', '')
            .trim();
        String karsilastirmaAnahtari = temizAd
            .toLowerCase()
            .replaceAll('ı', 'i')
            .replaceAll('ş', 's')
            .replaceAll('ğ', 'g')
            .replaceAll('ç', 'c')
            .replaceAll('ö', 'o')
            .replaceAll('ü', 'u')
            .replaceAll('i̇', 'i');

        if (!benzersizMap.containsKey(karsilastirmaAnahtari)) {
          benzersizMap[karsilastirmaAnahtari] = s;
        } else if (temizAd.contains(RegExp(r'[çğıöşüÇĞİÖŞÜ]'))) {
          benzersizMap[karsilastirmaAnahtari] = s;
        }
      }

      var siraliListe = benzersizMap.values.toList();
      siraliListe.sort((a, b) => a.name.compareTo(b.name));
      sehirler = siraliListe;

      if (kayitliIlce != null && kayitliIlce.isNotEmpty) {
        try {
          eslesenSehir = sehirler.firstWhere((s) {
            String temizAd = s.name
                .replaceAll(' İlçesi', '')
                .replaceAll(' District', '')
                .replaceAll(' Merkez', '')
                .trim();
            return temizAd.toLowerCase() == kayitliIlce.toLowerCase();
          });
        } catch (e) {
          //
        }
      }
    }

    if (mounted) {
      setState(() {
        _bolgeler = bolgeler;
        _secilenBolge = eslesenBolge;
        _sehirler = sehirler;
        _secilenSehir = eslesenSehir;
      });
    }
  }

  @override
  void dispose() {
    _firmaController.dispose();
    _yetkiliController.dispose();
    _telefonController.dispose();
    _epostaController.dispose();
    _vdController.dispose();
    _vnoController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_secilenUlkeAdi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lütfen ülke seçin", style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    bool basarili = false;
    String kaydedilecekSehir =
        _secilenBolge?.name
            .replaceAll(' Province', '')
            .replaceAll(' State', '')
            .trim() ??
        "";
    String kaydedilecekIlce =
        _secilenSehir?.name
            .replaceAll(' İlçesi', '')
            .replaceAll(' District', '')
            .replaceAll(' Merkez', '')
            .trim() ??
        "";
    String tamTelefonNumarasi =
        "$_telefonKodu ${_telefonController.text.trim()}";

    if (widget.musteri == null) {
      basarili = await widget.apiService.createMusteri(
        _firmaController.text,
        _yetkiliController.text,
        tamTelefonNumarasi,
        _epostaController.text,
        _vdController.text,
        _vnoController.text,
        _adresController.text,
        _secilenUlkeAdi!,
        kaydedilecekSehir,
        kaydedilecekIlce,
      );
    } else {
      basarili = await widget.apiService.updateMusteri(
        widget.musteri!["Id"],
        _firmaController.text,
        _yetkiliController.text,
        _telefonController.text,
        _epostaController.text,
        _vdController.text,
        _vnoController.text,
        _adresController.text,
        _secilenUlkeAdi!,
        kaydedilecekSehir,
        kaydedilecekIlce,
      );
    }

    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (basarili) {
      widget.onKaydedildi();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Müşteri başarıyla kaydedildi!",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu.", style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.musteri == null ? "Yeni Müşteri Ekle" : "Müşteriyi Düzenle",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width < 600 ? double.maxFinite : 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  _firmaController,
                  "Firma Adı / Unvan *",
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _yetkiliController,
                  "Yetkili Kişi",
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      countryListTheme: CountryListThemeData(
                        backgroundColor: Colors.white,
                        bottomSheetHeight: 500,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        inputDecoration: InputDecoration(
                          labelText: 'Ülke Ara',
                          labelStyle: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF64748B),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      onSelect: (Country country) async {
                        String gelenUlke =
                            country.nameLocalized ?? country.name;
                        if (gelenUlke == "Turkey") gelenUlke = "Türkiye";

                        setState(() {
                          _secilenUlkeAdi = gelenUlke;
                          _secilenUlkeKodu = country.countryCode;
                          _telefonKodu = "+${country.phoneCode}";
                          _secilenBolge = null;
                          _secilenSehir = null;
                          _sehirler = [];
                        });

                        final bolgeler = await csc.getStatesOfCountry(
                          country.countryCode,
                        );
                        setState(() => _bolgeler = bolgeler);
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _secilenUlkeAdi ?? "Ülke Seçiniz *",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _secilenUlkeAdi == null
                                ? const Color(0xFF64748B)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<csc.State>(
                        key: ValueKey("il_$_secilenUlkeKodu"),
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
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                        isExpanded: true,
                        initialValue: _secilenBolge,
                        items: _bolgeler.map((b) {
                          String temizIlAdi = b.name
                              .replaceAll(' Province', '')
                              .replaceAll(' State', '')
                              .trim();
                          return DropdownMenuItem(
                            value: b,
                            child: Text(
                              temizIlAdi,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (yeniBolge) async {
                          setState(() {
                            _secilenBolge = yeniBolge;
                            _secilenSehir = null;
                            _sehirler = [];
                          });
                          if (yeniBolge != null && _secilenUlkeKodu != null) {
                            final hamSehirler = await csc.getStateCities(
                              _secilenUlkeKodu!,
                              yeniBolge.isoCode,
                            );
                            final Map<String, csc.City> benzersizMap = {};
                            for (var s in hamSehirler) {
                              String temizAd = s.name
                                  .replaceAll(' İlçesi', '')
                                  .replaceAll(' District', '')
                                  .replaceAll(' Merkez', '')
                                  .trim();
                              String k = temizAd
                                  .toLowerCase()
                                  .replaceAll('ı', 'i')
                                  .replaceAll('ş', 's')
                                  .replaceAll('ğ', 'g')
                                  .replaceAll('ç', 'c')
                                  .replaceAll('ö', 'o')
                                  .replaceAll('ü', 'u')
                                  .replaceAll('i̇', 'i');
                              if (!benzersizMap.containsKey(k)) {
                                benzersizMap[k] = s;
                              } else if (temizAd.contains(
                                RegExp(r'[çğıöşüÇĞİÖŞÜ]'),
                              ))
                                benzersizMap[k] = s;
                            }
                            var siraliListe = benzersizMap.values.toList();
                            siraliListe.sort(
                              (a, b) => a.name.compareTo(b.name),
                            );
                            setState(() => _sehirler = siraliListe);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<csc.City>(
                        key: ValueKey("ilce_${_secilenBolge?.isoCode}"),
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
                            horizontal: 16,
                            vertical: 0,
                          ),
                        ),
                        isExpanded: true,
                        initialValue: _secilenSehir,
                        items: _sehirler.map((s) {
                          String temizIlceAdi = s.name
                              .replaceAll(' İlçesi', '')
                              .replaceAll(' District', '')
                              .replaceAll(' Merkez', '')
                              .trim();
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              temizIlceAdi,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (yeniSehir) =>
                            setState(() => _secilenSehir = yeniSehir),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _adresController,
                  "Açık Adres (Mahalle, Sokak, No)",
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _telefonController,
                        "Telefon *",
                        isRequired: true,
                        icon: Icons.phone_outlined,
                        prefixText: "$_telefonKodu ",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        _epostaController,
                        "E-Posta",
                        icon: Icons.email_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_vdController, "Vergi Dairesi"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_vnoController, "Vergi No"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 24, bottom: 24, top: 8),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            "İptal",
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _isSaving ? null : _kaydet,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Kaydet",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    IconData? icon,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixText: prefixText,
        prefixStyle: GoogleFonts.inter(
          color: const Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: const Color(0xFF64748B))
            : null,
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Zorunlu alan" : null : null,
    );
  }
}
