import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'teklif_ekle_ekrani.dart';
import 'teklif_pdf_onizleme_ekrani.dart';
import '../widgets/teklif_liste_ogesi.dart';

class TekliflerEkrani extends StatefulWidget {
  const TekliflerEkrani({super.key});

  @override
  State<TekliflerEkrani> createState() => _TekliflerEkraniState();
}

class _TekliflerEkraniState extends State<TekliflerEkrani> {
  final ApiService _apiService = ApiService();

  List<dynamic> _tumTeklifler = [];
  List<dynamic> _gosterilenTeklifler = [];

  bool _isLoading = true;
  String _aramaMetni = "";
  String _seciliDurum = "Tümü";

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final veriler = await _apiService.getTeklifler();

      if (mounted) {
        setState(() {
          _tumTeklifler = veriler;
          _isLoading = false;
        });
        _filtreleVeSirala();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtreleVeSirala() {
    List<dynamic> sonuc = List.from(_tumTeklifler);
    if (_seciliDurum != "Tümü") {
      sonuc = sonuc.where((t) => t["Durum"] == _seciliDurum).toList();
    }
    if (_aramaMetni.isNotEmpty) {
      final arama = _aramaMetni.toLowerCase();
      sonuc = sonuc
          .where(
            (t) =>
                (t["TeklifNo"]?.toString().toLowerCase() ?? "").contains(
                  arama,
                ) ||
                (t["FirmaAdi"]?.toString().toLowerCase() ?? "").contains(arama),
          )
          .toList();
    }
    sonuc.sort(
      (a, b) => (b["Id"] as int? ?? 0).compareTo(a["Id"] as int? ?? 0),
    );
    setState(() => _gosterilenTeklifler = sonuc);
  }

  Future<void> _teklifSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Emin misiniz?",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          "Bu teklifi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
          style: GoogleFonts.inter(color: const Color(0xFF475569)),
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
      final hata = await _apiService.deleteTeklif(id);
      if (hata == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Teklif silindi.", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        _verileriCek();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hata ?? "Hata", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _durumGuncelle(int id, String yeniDurum) async {
    final basarili = await _apiService.updateTeklifDurumu(id, yeniDurum);
    if (basarili && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Durum güncellendi.", style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _verileriCek();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Durum güncellenemedi.", style: GoogleFonts.inter()),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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

  Future<void> _teklifDetayGoster(Map<String, dynamic> teklif) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
    );

    try {
      final detaylar = await _apiService.getTeklifDetaylari(teklif["Id"]);
      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Teklif: ${teklif["TeklifNo"] ?? '-'}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detaySatiri("Müşteri:", teklif["FirmaAdi"] ?? "-"),
                  _detaySatiri("Durum:", teklif["Durum"] ?? "Bekliyor"),
                  _detaySatiri(
                    "Ara Toplam:",
                    "${teklif["AraToplam"]} ${teklif["Doviz"] ?? 'TRY'}",
                  ),
                  _detaySatiri(
                    "İndirim:",
                    "${teklif["ToplamIndirim"]} ${teklif["Doviz"] ?? 'TRY'}",
                  ),
                  _detaySatiri(
                    "Genel Toplam:",
                    "${teklif["GenelToplam"]} ${teklif["Doviz"] ?? 'TRY'}",
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  Text(
                    "İçerikteki Ürünler",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...detaylar.map((d) {
                    List<String> urunGorselleri = [];
                    final rawGorsel = d["UrunGorsel"]?.toString() ?? "";
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: urunGorselleri.isNotEmpty
                                ? () => _galeriGoster(urunGorselleri, 0)
                                : null,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: urunGorselleri.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(
                                          urunGorselleri[0].replaceAll(
                                            RegExp(r'\s+'),
                                            '',
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            const Icon(
                                              Icons.broken_image,
                                              color: Color(0xFF94A3B8),
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Color(0xFF64748B),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d["UrunAdi"] ?? "-",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${d["Miktar"]} Adet x ${d["BirimFiyat"]}",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "%${d["KdvOrani"]} KDV",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Detaylar yüklenirken bir hata oluştu.")),
      );
    }
  }

  Widget _detaySatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                "Teklifler",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeklifEkleEkrani(onSaved: () => _verileriCek()),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  "Yeni Teklif",
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

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: isMobil
                ? Column(
                    children: [
                      SizedBox(
                        height: 42,
                        child: TextField(
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: "Teklif No veya Firma ara...",
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
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
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          onChanged: (val) {
                            _aramaMetni = val;
                            _filtreleVeSirala();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 42,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _seciliDurum,
                            icon: const Icon(
                              Icons.unfold_more_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                            isExpanded: true,
                            items:
                                [
                                      "Tümü",
                                      "Bekliyor",
                                      "Kabul Edildi",
                                      "Reddedildi",
                                    ]
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _seciliDurum = val);
                                _filtreleVeSirala();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Teklif No veya Firma ara...",
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            onChanged: (val) {
                              _aramaMetni = val;
                              _filtreleVeSirala();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _seciliDurum,
                              icon: const Icon(
                                Icons.unfold_more_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w500,
                              ),
                              isExpanded: true,
                              items:
                                  [
                                        "Tümü",
                                        "Bekliyor",
                                        "Kabul Edildi",
                                        "Reddedildi",
                                      ]
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _seciliDurum = val);
                                  _filtreleVeSirala();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            itemCount: _gosterilenTeklifler.length,
                            itemBuilder: (context, index) => TeklifMobilKarti(
                              teklif: _gosterilenTeklifler[index],
                              onDurumGuncelle: _durumGuncelle,
                              onDetayGoster: () => _teklifDetayGoster(
                                _gosterilenTeklifler[index],
                              ),
                              onPdfGoster: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeklifPdfOnizlemeEkrani(
                                    teklif: _gosterilenTeklifler[index],
                                  ),
                                ),
                              ),
                              onDuzenle: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => TeklifEkleEkrani(
                                    mevcutTeklif: _gosterilenTeklifler[index],
                                    onSaved: _verileriCek,
                                  ),
                                ),
                              ),
                              onSil: () =>
                                  _teklifSil(_gosterilenTeklifler[index]["Id"]),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 1100,
                              maxWidth: constraints.maxWidth > 1100
                                  ? constraints.maxWidth
                                  : 1100,
                            ),
                            child: Column(
                              children: [
                                const TeklifTabloBasliklari(),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _gosterilenTeklifler.length,
                                    itemBuilder: (context, index) =>
                                        TeklifTabloSatiri(
                                          index: index,
                                          teklif: _gosterilenTeklifler[index],
                                          onDurumGuncelle: _durumGuncelle,
                                          onDetayGoster: () =>
                                              _teklifDetayGoster(
                                                _gosterilenTeklifler[index],
                                              ),
                                          onPdfGoster: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TeklifPdfOnizlemeEkrani(
                                                    teklif:
                                                        _gosterilenTeklifler[index],
                                                  ),
                                            ),
                                          ),
                                          onDuzenle: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (ctx) => TeklifEkleEkrani(
                                                mevcutTeklif:
                                                    _gosterilenTeklifler[index],
                                                onSaved: _verileriCek,
                                              ),
                                            ),
                                          ),
                                          onSil: () => _teklifSil(
                                            _gosterilenTeklifler[index]["Id"],
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
