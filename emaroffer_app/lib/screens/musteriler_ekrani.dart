import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/musteri_form_dialog.dart';
import '../widgets/musteri_liste_ogesi.dart';

class MusterilerEkrani extends StatefulWidget {
  const MusterilerEkrani({super.key});

  @override
  State<MusterilerEkrani> createState() => _MusterilerEkraniState();
}

class _MusterilerEkraniState extends State<MusterilerEkrani> {
  final ApiService _apiService = ApiService();
  List<dynamic> _musteriler = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    setState(() => _isLoading = true);
    try {
      final veriler = await _apiService.getMusteriler();
      if (mounted) {
        setState(() {
          _musteriler = veriler;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: $e", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _musteriDialogGoster({Map<String, dynamic>? musteri}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MusteriFormDialog(
        musteri: musteri,
        apiService: _apiService,
        onKaydedildi: _verileriCek,
      ),
    );
  }

  Future<void> _musteriSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Silme Onayı",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          "Bu müşteriyi silmek istediğinize emin misiniz?",
          style: GoogleFonts.inter(color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
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
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Sil",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (onay == true) {
      final hataMesaji = await _apiService.deleteMusteri(id);
      if (hataMesaji == null && mounted) {
        _verileriCek();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Müşteri silindi.", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hataMesaji ?? "Hata", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _musteriDetayGoster(Map<String, dynamic> musteri) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_pin_rounded,
                color: Color(0xFF4F46E5),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                musteri["FirmaAdi"] ?? "Müşteri Detayı",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Genel Bilgiler",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF4F46E5),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                _detaySatiri(
                  Icons.person_outline,
                  "Yetkili Kişi:",
                  musteri["YetkiliKisi"]?.toString() ?? "-",
                ),
                _detaySatiri(
                  Icons.phone_outlined,
                  "Telefon:",
                  musteri["Telefon"]?.toString() ?? "-",
                ),
                _detaySatiri(
                  Icons.mail_outline,
                  "E-posta:",
                  musteri["Eposta"]?.toString() ?? "-",
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                ),

                Text(
                  "Vergi Bilgileri",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF10B981),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                _detaySatiri(
                  Icons.business_center_outlined,
                  "Vergi Dairesi:",
                  musteri["VergiDairesi"]?.toString() ?? "-",
                ),
                _detaySatiri(
                  Icons.badge_outlined,
                  "Vergi No:",
                  musteri["VergiNo"]?.toString() ?? "-",
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                ),

                Text(
                  "Adres & Lokasyon",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF06B6D4),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                _detaySatiri(
                  Icons.map_outlined,
                  "Ülke / Şehir:",
                  "${musteri["Ulke"] ?? "-"} / ${musteri["Sehir"] ?? "-"}",
                ),
                _detaySatiri(
                  Icons.location_city_outlined,
                  "İlçe:",
                  musteri["Ilce"]?.toString() ?? "-",
                ),
                _detaySatiri(
                  Icons.location_on_outlined,
                  "Açık Adres:",
                  musteri["Adres"]?.toString() ?? "-",
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Kapat",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detaySatiri(
    IconData icon,
    String baslik,
    String deger, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              baslik,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              deger,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.all(isMobil ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Müşteri Yönetimi",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _musteriDialogGoster(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  "Yeni Müşteri",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (isMobil) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _musteriler.length,
                            itemBuilder: (context, index) => MusteriMobilKarti(
                              musteri: _musteriler[index],
                              onDetayGoster: () =>
                                  _musteriDetayGoster(_musteriler[index]),
                              onDuzenle: () => _musteriDialogGoster(
                                musteri: _musteriler[index],
                              ),
                              onSil: () =>
                                  _musteriSil(_musteriler[index]["Id"]),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 1000,
                              maxWidth: constraints.maxWidth > 1000
                                  ? constraints.maxWidth
                                  : 1000,
                            ),
                            child: Column(
                              children: [
                                const MusteriTabloBasliklari(),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _musteriler.length,
                                    itemBuilder: (context, index) =>
                                        MusteriTabloSatiri(
                                          index: index,
                                          musteri: _musteriler[index],
                                          onDetayGoster: () =>
                                              _musteriDetayGoster(
                                                _musteriler[index],
                                              ),
                                          onDuzenle: () => _musteriDialogGoster(
                                            musteri: _musteriler[index],
                                          ),
                                          onSil: () => _musteriSil(
                                            _musteriler[index]["Id"],
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
