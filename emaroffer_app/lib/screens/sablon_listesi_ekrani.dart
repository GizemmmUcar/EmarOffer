import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'sablon_yonetimi_ekrani.dart';
import '../widgets/sablon_karti.dart';

class SablonListesiEkrani extends StatefulWidget {
  const SablonListesiEkrani({super.key});

  @override
  State<SablonListesiEkrani> createState() => _SablonListesiEkraniState();
}

class _SablonListesiEkraniState extends State<SablonListesiEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  List<dynamic> _tumSablonlar = [];
  List<dynamic> _gosterilenSablonlar = [];
  String _aramaMetni = '';
  String _seciliSiralama = 'Yeni';

  @override
  void initState() {
    super.initState();
    _sablonlariYukle();
  }

  Future<void> _sablonlariYukle() async {
    setState(() => _isLoading = true);
    try {
      final veriler = await _apiService.getSablonlar();
      if (mounted) {
        setState(() {
          _tumSablonlar = veriler;
          _listeyiGuncelle();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _listeyiGuncelle() {
    List<dynamic> geciciListe = List.from(_tumSablonlar);

    if (_aramaMetni.isNotEmpty) {
      geciciListe = geciciListe.where((s) {
        final ad = (s['SablonAdi'] ?? '').toString().toLowerCase();
        return ad.contains(_aramaMetni.toLowerCase());
      }).toList();
    }

    if (_seciliSiralama == 'Yeni') {
      geciciListe.sort((a, b) => b['Id'].compareTo(a['Id']));
    } else {
      geciciListe.sort((a, b) => a['Id'].compareTo(b['Id']));
    }

    setState(() => _gosterilenSablonlar = geciciListe);
  }

  Future<void> _varsayilanYap(int id) async {
    setState(() => _isLoading = true);
    bool basarili = await _apiService.setVarsayilanSablon(id);
    if (basarili && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Varsayılan şablon güncellendi.",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _sablonlariYukle();
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Emin misiniz?",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Bu şablonu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
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
      await _apiService.deleteSablon(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şablon başarıyla silindi.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        _sablonlariYukle();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "PDF Şablonları",
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SablonYonetimiEkrani(),
                  ),
                ).then((_) => _sablonlariYukle());
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                "Yeni Şablon",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 46,
                    child: TextField(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Şablon Adı ile Ara...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        _aramaMetni = val;
                        _listeyiGuncelle();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _seciliSiralama,
                        isExpanded: true,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                        icon: const Icon(
                          Icons.sort,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Yeni',
                            child: Text(
                              'Yeniden Eskiye',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Eski',
                            child: Text(
                              'Eskiden Yeniye',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _seciliSiralama = val);
                            _listeyiGuncelle();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : _tumSablonlar.isEmpty
                ? Center(
                    child: Text(
                      "Henüz hiç şablon oluşturmadınız.",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 15,
                      ),
                    ),
                  )
                : _gosterilenSablonlar.isEmpty
                ? Center(
                    child: Text(
                      "Aradığınız kritere uygun şablon bulunamadı.",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 15,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: _gosterilenSablonlar.length,
                    itemBuilder: (context, index) {
                      final s = _gosterilenSablonlar[index];
                      final isVarsayilan =
                          s['VarsayilanMi'] == true || s['VarsayilanMi'] == 1;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          SablonKarti(
                            sablon: s,
                            onDuzenle: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SablonYonetimiEkrani(mevcutSablon: s),
                                ),
                              ).then((_) => _sablonlariYukle());
                            },
                            onSil: () => _sil(s['Id']),
                          ),

                          Positioned(
                            top: 12,
                            right: 12,
                            child: isVarsayilan
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Varsayılan",
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    onTap: () => _varsayilanYap(s['Id']),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Varsayılan Yap",
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF64748B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
