import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/calisan_form_dialog.dart';
import '../widgets/calisan_liste_ogesi.dart';

class CalisanlarEkrani extends StatefulWidget {
  const CalisanlarEkrani({super.key});

  @override
  State<CalisanlarEkrani> createState() => _CalisanlarEkraniState();
}

class _CalisanlarEkraniState extends State<CalisanlarEkrani> {
  final ApiService _apiService = ApiService();
  List<dynamic> _calisanlar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    setState(() => _isLoading = true);
    final veriler = await _apiService.getKullanicilar();
    if (mounted) {
      setState(() {
        _calisanlar = veriler;
        _isLoading = false;
      });
    }
  }

  void _calisanDialogGoster({Map<String, dynamic>? calisan}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CalisanFormDialog(
        calisan: calisan,
        apiService: _apiService,
        onKaydedildi: _verileriCek,
      ),
    );
  }

  Future<void> _calisanSil(int id) async {
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
          "Bu çalışanı silmek istediğinize emin misiniz?",
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
      final hataMesaji = await _apiService.deleteKullanici(id);
      if (hataMesaji == null && mounted) {
        _verileriCek();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Çalışan silindi.", style: GoogleFonts.inter()),
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

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 600;

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
                "Çalışanlar",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _calisanDialogGoster(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  "Yeni Çalışan",
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
                            itemCount: _calisanlar.length,
                            itemBuilder: (context, index) => CalisanMobilKarti(
                              calisan: _calisanlar[index],
                              onDuzenle: () => _calisanDialogGoster(
                                calisan: _calisanlar[index],
                              ),
                              onSil: () =>
                                  _calisanSil(_calisanlar[index]["Id"]),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 800,
                              maxWidth: constraints.maxWidth > 800
                                  ? constraints.maxWidth
                                  : 800,
                            ),
                            child: Column(
                              children: [
                                const CalisanTabloBasliklari(),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _calisanlar.length,
                                    itemBuilder: (context, index) =>
                                        CalisanTabloSatiri(
                                          index: index,
                                          calisan: _calisanlar[index],
                                          onDuzenle: () => _calisanDialogGoster(
                                            calisan: _calisanlar[index],
                                          ),
                                          onSil: () => _calisanSil(
                                            _calisanlar[index]["Id"],
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
