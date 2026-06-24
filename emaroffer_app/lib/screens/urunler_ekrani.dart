import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/urun_form_dialog.dart';
import '../widgets/urun_liste_ogesi.dart';
import 'dart:convert';

class UrunlerEkrani extends StatefulWidget {
  const UrunlerEkrani({super.key});
  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  final ApiService _apiService = ApiService();
  List<dynamic> _urunler = [];
  List<dynamic> _filtrelenmisUrunler = [];

  List<String> _kategoriler = ["Tümü"];
  String _seciliKategori = "Tümü";

  final TextEditingController _aramaController = TextEditingController();
  bool _isLoading = true;
  String _seciliSiralama = "İsme Göre (A-Z)";
  final List<String> _siralamaSecenekleri = [
    "İsme Göre (A-Z)",
    "Fiyat (Artan)",
    "Fiyat (Azalan)",
  ];

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  Future<void> _verileriCek() async {
    setState(() => _isLoading = true);
    final veriler = await _apiService.getUrunler();
    if (mounted) {
      Set<String> katSet = {"Tümü"};
      for (var u in veriler) {
        String k = (u["Kategori"]?.toString() ?? "").trim();
        if (k.isNotEmpty) katSet.add(k);
      }

      setState(() {
        _urunler = veriler;
        _kategoriler = katSet.toList();
        if (!_kategoriler.contains(_seciliKategori)) _seciliKategori = "Tümü";

        _listeyiGuncelle();
        _isLoading = false;
      });
    }
  }

  void _listeyiGuncelle() {
    List<dynamic> sonuc = List.from(_urunler);

    if (_seciliKategori != "Tümü") {
      sonuc = sonuc
          .where(
            (u) => (u["Kategori"]?.toString() ?? "").trim() == _seciliKategori,
          )
          .toList();
    }

    if (_aramaController.text.isNotEmpty) {
      final q = _aramaController.text.toLowerCase();
      sonuc = sonuc
          .where(
            (urun) =>
                (urun["UrunAdi"]?.toString() ?? "").toLowerCase().contains(q) ||
                (urun["UrunKodu"]?.toString() ?? "").toLowerCase().contains(q),
          )
          .toList();
    }

    if (_seciliSiralama == "İsme Göre (A-Z)") {
      sonuc.sort(
        (a, b) => (a["UrunAdi"]?.toString() ?? "").compareTo(
          b["UrunAdi"]?.toString() ?? "",
        ),
      );
    } else if (_seciliSiralama == "Fiyat (Artan)") {
      sonuc.sort(
        (a, b) => (double.tryParse(a["BirimFiyati"]?.toString() ?? "0") ?? 0)
            .compareTo(
              double.tryParse(b["BirimFiyati"]?.toString() ?? "0") ?? 0,
            ),
      );
    } else if (_seciliSiralama == "Fiyat (Azalan)") {
      sonuc.sort(
        (a, b) => (double.tryParse(b["BirimFiyati"]?.toString() ?? "0") ?? 0)
            .compareTo(
              double.tryParse(a["BirimFiyati"]?.toString() ?? "0") ?? 0,
            ),
      );
    }

    setState(() => _filtrelenmisUrunler = sonuc);
  }

  void _urunDialogGoster({Map<String, dynamic>? urun}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UrunFormDialog(
        urun: urun,
        apiService: _apiService,
        onKaydedildi: _verileriCek,
      ),
    );
  }

  void _galeriGoster(List<String> gorseller, int baslangicIndex) {
    final PageController pageController = PageController(
      initialPage: baslangicIndex,
    );
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE0E7FF),
                    Color(0xFFF8FAFC),
                    Color(0xFFFEFCE8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "ÜRÜN DETAY GÖRÜNÜMÜ",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  PageView.builder(
                    itemCount: gorseller.length,
                    controller: pageController,
                    onPageChanged: (index) =>
                        setStateDialog(() => baslangicIndex = index),
                    itemBuilder: (ctx, i) => Center(
                      child: InteractiveViewer(
                        child: Container(
                          margin: const EdgeInsets.all(40),
                          constraints: const BoxConstraints(
                            maxWidth: 800,
                            maxHeight: 600,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFC7D2FE),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withAlpha(30),
                                blurRadius: 40,
                                spreadRadius: 10,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withAlpha(15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              base64Decode(
                                gorseller[i].replaceAll(RegExp(r'\s+'), ''),
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (gorseller.length > 1)
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            "${baslangicIndex + 1} / ${gorseller.length}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF334155),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (gorseller.length > 1 && baslangicIndex > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF4F46E5),
                              size: 24,
                            ),
                            onPressed: () => pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (gorseller.length > 1 &&
                      baslangicIndex < gorseller.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF4F46E5),
                              size: 24,
                            ),
                            onPressed: () => pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 24,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _urunSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Silme Onayı",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          "Bu ürünü silmek istediğinize emin misiniz?",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (onay == true) {
      final hataMesaji = await _apiService.deleteUrun(id);
      if (hataMesaji == null && mounted) {
        _verileriCek();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ürün başarıyla silindi."),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hataMesaji ?? "Hata oluştu"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _urunDetayGoster(Map<String, dynamic> urun) {
    final kategori = (urun["Kategori"]?.toString() ?? "").trim();
    final altKategori = (urun["AltKategori"]?.toString() ?? "").trim();
    String kategoriMetni = kategori.isEmpty ? "-" : kategori;
    if (kategori.isNotEmpty && altKategori.isNotEmpty)
      kategoriMetni += " > $altKategori";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          urun["UrunAdi"] ?? "Ürün Detayı",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detaySatiri("Ürün Kodu:", urun["UrunKodu"]?.toString() ?? "-"),
            _detaySatiri("Kategori:", kategoriMetni),
            _detaySatiri(
              "Fiyat:",
              "${urun["BirimFiyati"]} ${urun["ParaBirimi"] ?? 'TRY'}",
            ),
            _detaySatiri("KDV Oranı:", "%${urun["KdvOrani"] ?? '0'}"),
            const SizedBox(height: 12),
            Text(
              "Açıklama:",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (urun["Aciklama"]?.toString() ?? "").isNotEmpty
                  ? urun["Aciklama"].toString()
                  : "Açıklama bulunmuyor.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Kapat",
              style: GoogleFonts.inter(
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detaySatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: const Color(0xFF0F172A),
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
                "Ürün Yönetimi",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _urunDialogGoster(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  "Yeni Ürün",
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_kategoriler.length > 1) ...[
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriler.length,
                itemBuilder: (context, index) {
                  final kat = _kategoriler[index];
                  final isSelected = _seciliKategori == kat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(kat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _seciliKategori = kat);
                          _listeyiGuncelle();
                        }
                      },
                      selectedColor: const Color(
                        0xFF4F46E5,
                      ).withValues(alpha: 0.15),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF64748B),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _aramaController,
                    onChanged: (val) => _listeyiGuncelle(),
                    decoration: InputDecoration(
                      hintText: "Ürün adı veya kodu...",
                      border: InputBorder.none,
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Icon(Icons.search, color: Color(0xFF94A3B8)),
                      ),
                      suffixIcon: _aramaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _aramaController.clear();
                                _listeyiGuncelle();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.sort_rounded,
                    color: Color(0xFF64748B),
                  ),
                  onSelected: (yeniSecim) {
                    setState(() => _seciliSiralama = yeniSecim);
                    _listeyiGuncelle();
                  },
                  itemBuilder: (context) => _siralamaSecenekleri
                      .map(
                        (secenek) => PopupMenuItem(
                          value: secenek,
                          child: Text(
                            secenek,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _filtrelenmisUrunler.isEmpty
                        ? Center(
                            child: Text(
                              "Ürün bulunamadı.",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: _filtrelenmisUrunler.length,
                            separatorBuilder: (ctx, idx) => const Divider(
                              height: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            itemBuilder: (context, index) {
                              final urun = _filtrelenmisUrunler[index];
                              List<String> urunGorselleri = [];
                              final rawGorsel =
                                  urun["UrunGorsel"]?.toString() ?? "";
                              if (rawGorsel.isNotEmpty) {
                                if (rawGorsel.trimLeft().startsWith('[')) {
                                  try {
                                    urunGorselleri = List<String>.from(
                                      jsonDecode(rawGorsel),
                                    );
                                  } catch (_) {
                                    urunGorselleri = [rawGorsel];
                                  }
                                } else {
                                  urunGorselleri = [rawGorsel];
                                }
                              }
                              return UrunListeOgesi(
                                urun: urun,
                                onDetayGoster: () => _urunDetayGoster(urun),
                                onDuzenle: () => _urunDialogGoster(urun: urun),
                                onSil: () => _urunSil(urun["Id"]),
                                onGaleriGoster: urunGorselleri.isNotEmpty
                                    ? () => _galeriGoster(urunGorselleri, 0)
                                    : null,
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
