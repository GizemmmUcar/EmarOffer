import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/sirket_bilesenleri.dart';

class SirketEkrani extends StatefulWidget {
  const SirketEkrani({super.key});

  @override
  State<SirketEkrani> createState() => _SirketEkraniState();
}

class _SirketEkraniState extends State<SirketEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _sirketAdiController = TextEditingController();
  final TextEditingController _yetkiliController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _epostaController = TextEditingController();
  final TextEditingController _webController = TextEditingController();
  final TextEditingController _vergiDairesiController = TextEditingController();
  final TextEditingController _vergiNoController = TextEditingController();
  final TextEditingController _bankaController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();

  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    try {
      final sirket = await _apiService.getSirketBilgileri();
      if (mounted && sirket != null) {
        setState(() {
          _sirketAdiController.text = sirket["SirketAdi"] ?? "";
          _yetkiliController.text = sirket["Yetkili"] ?? "";
          _telefonController.text = sirket["Telefon"] ?? "";
          _epostaController.text = sirket["Eposta"] ?? "";
          _webController.text = sirket["WebSitesi"] ?? "";
          _vergiDairesiController.text = sirket["VergiDairesi"] ?? "";
          _vergiNoController.text = sirket["VergiNo"] ?? "";
          _bankaController.text = sirket["BankaBilgileri"] ?? "";
          _adresController.text = sirket["Adres"] ?? "";
          _logoBase64 = sirket["Logo"];
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logoSec() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _logoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _kaydet() async {
    setState(() => _isSaving = true);
    final data = {
      "SirketAdi": _sirketAdiController.text,
      "Yetkili": _yetkiliController.text,
      "Telefon": _telefonController.text,
      "Eposta": _epostaController.text,
      "WebSitesi": _webController.text,
      "VergiDairesi": _vergiDairesiController.text,
      "VergiNo": _vergiNoController.text,
      "BankaBilgileri": _bankaController.text,
      "Adres": _adresController.text,
      "Logo": _logoBase64 ?? "",
    };

    final basarili = await _apiService.updateSirketBilgileri(data);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            basarili
                ? "Şirket bilgileri kaydedildi."
                : "Kaydedilirken hata oluştu.",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: basarili
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 850;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      );
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.all(isMobil ? 16.0 : 40.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Şirket Profilim",
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Teklif ve PDF'lerde görünecek firma detaylarınızı yönetin.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobil)
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _kaydet,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      "Değişiklikleri Kaydet",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              children: [
                SizedBox(
                  width: isMobil ? double.infinity : 450,
                  child: Column(
                    children: [
                      SirketKategoriKarti(
                        baslik: "Firma Bilgileri",
                        baslikIcon: Icons.business_rounded,
                        iconRenk: const Color(0xFF4F46E5),
                        cocuklar: [
                          SirketInputAlani(
                            etiket: "Şirket Adı",
                            controller: _sirketAdiController,
                            icon: Icons.business,
                          ),
                          SirketInputAlani(
                            etiket: "Yetkili Kişi",
                            controller: _yetkiliController,
                            icon: Icons.person_outline,
                          ),
                        ],
                      ),
                      SirketKategoriKarti(
                        baslik: "İletişim Bilgileri",
                        baslikIcon: Icons.contact_mail_outlined,
                        iconRenk: const Color(0xFF06B6D4),
                        cocuklar: [
                          SirketInputAlani(
                            etiket: "Telefon",
                            controller: _telefonController,
                            icon: Icons.phone_outlined,
                          ),
                          SirketInputAlani(
                            etiket: "E-posta",
                            controller: _epostaController,
                            icon: Icons.mail_outline,
                          ),
                          SirketInputAlani(
                            etiket: "Web Sitesi",
                            controller: _webController,
                            icon: Icons.language,
                          ),
                          SirketInputAlani(
                            etiket: "Açık Adres",
                            controller: _adresController,
                            icon: Icons.location_on_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: isMobil ? double.infinity : 450,
                  child: Column(
                    children: [
                      SirketKategoriKarti(
                        baslik: "Vergi & Banka",
                        baslikIcon: Icons.account_balance_wallet_outlined,
                        iconRenk: const Color(0xFF10B981),
                        cocuklar: [
                          Row(
                            children: [
                              Expanded(
                                child: SirketInputAlani(
                                  etiket: "Vergi Dairesi",
                                  controller: _vergiDairesiController,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SirketInputAlani(
                                  etiket: "Vergi No",
                                  controller: _vergiNoController,
                                ),
                              ),
                            ],
                          ),
                          SirketInputAlani(
                            etiket: "Banka ve IBAN Bilgileri",
                            controller: _bankaController,
                            icon: Icons.account_balance_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      _buildLogoKarti(),
                    ],
                  ),
                ),
              ],
            ),
            if (isMobil)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _kaydet,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      "Değişiklikleri Kaydet",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoKarti() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Firma Logosu",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: _logoBase64 != null && _logoBase64!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            base64Decode(_logoBase64!),
                            fit: BoxFit.contain,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Görsel Yok",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _logoSec,
                  icon: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 18,
                    color: Color(0xFF4F46E5),
                  ),
                  label: Text(
                    "Bilgisayardan Seç",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2FF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "PNG, JPG (Maks. 2MB önerilir)",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
