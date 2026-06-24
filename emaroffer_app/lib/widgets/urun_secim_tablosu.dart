import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../models/teklif_satiri_model.dart';

class SatirYonetici {
  TeklifSatiri veri;
  TextEditingController miktarCtrl;
  TextEditingController fiyatCtrl;
  TextEditingController iskontoCtrl;
  TextEditingController kdvCtrl;

  SatirYonetici(this.veri)
    : miktarCtrl = TextEditingController(text: veri.miktar.toString()),
      fiyatCtrl = TextEditingController(
        text: veri.birimFiyat.toStringAsFixed(2),
      ),
      iskontoCtrl = TextEditingController(
        text: veri.iskontoYuzdesi.toStringAsFixed(0),
      ),
      kdvCtrl = TextEditingController(text: veri.kdvOrani.toStringAsFixed(0));

  void urunGuncelle(int id, String ad, double fiyat, double kdv) {
    veri.urunId = id;
    veri.urunAdi = ad;
    veri.birimFiyat = fiyat;
    veri.kdvOrani = kdv;
    fiyatCtrl.text = fiyat.toStringAsFixed(2);
    kdvCtrl.text = kdv.toStringAsFixed(0);
    veri.iskontoYuzdesi = 0.0;
    iskontoCtrl.text = "0";
  }

  void dispose() {
    miktarCtrl.dispose();
    fiyatCtrl.dispose();
    iskontoCtrl.dispose();
    kdvCtrl.dispose();
  }
}

class UrunSecimTablosu extends StatefulWidget {
  final List<SatirYonetici> satirlar;
  final List<dynamic> sistemUrunleri;
  final String seciliDoviz;
  final VoidCallback onSatirEkle;
  final Function(int) onSatirSil;
  final VoidCallback onDegisiklik;

  const UrunSecimTablosu({
    super.key,
    required this.satirlar,
    required this.sistemUrunleri,
    required this.seciliDoviz,
    required this.onSatirEkle,
    required this.onSatirSil,
    required this.onDegisiklik,
  });

  @override
  State<UrunSecimTablosu> createState() => _UrunSecimTablosuState();
}

class _UrunSecimTablosuState extends State<UrunSecimTablosu> {
  String _seciliKategori = "Tümü";

  List<String> get _kategoriler {
    Set<String> katSet = {"Tümü"};
    for (var u in widget.sistemUrunleri) {
      String k = (u["Kategori"]?.toString() ?? "").trim();
      if (k.isNotEmpty) katSet.add(k);
    }
    return katSet.toList();
  }

  Iterable<Map<String, dynamic>> _getFilteredOptions(String query) {
    return widget.sistemUrunleri.cast<Map<String, dynamic>>().where((u) {
      String uKat = (u["Kategori"]?.toString() ?? "").trim();
      if (_seciliKategori != "Tümü" && uKat != _seciliKategori) return false;

      if (query.isEmpty) return true;
      final ad = (u["UrunAdi"] ?? "").toString().toLowerCase();
      final kod = (u["UrunKodu"] ?? "").toString().toLowerCase();
      final q = query.toLowerCase();
      return ad.contains(q) || kod.contains(q);
    });
  }

  void _galeriGoster(
    BuildContext context,
    List<String> gorseller,
    int baslangicIndex,
  ) {
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

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 700;
    final kategoriler = _kategoriler;

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
                "Ürünler ve Kalemler",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (kategoriler.length > 1 && !isMobil)
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: kategoriler.length,
                    itemBuilder: (context, index) {
                      final kat = kategoriler[index];
                      final isSelected = _seciliKategori == kat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Text(kat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _seciliKategori = kat);
                          },
                          selectedColor: const Color(
                            0xFF4F46E5,
                          ).withValues(alpha: 0.15),
                          backgroundColor: const Color(0xFFF1F5F9),
                          showCheckmark: false,
                          labelStyle: GoogleFonts.inter(
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF64748B),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          if (kategoriler.length > 1 && isMobil) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kategoriler.length,
                itemBuilder: (context, index) {
                  final kat = kategoriler[index];
                  final isSelected = _seciliKategori == kat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(kat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _seciliKategori = kat);
                      },
                      selectedColor: const Color(
                        0xFF4F46E5,
                      ).withValues(alpha: 0.15),
                      backgroundColor: const Color(0xFFF1F5F9),
                      showCheckmark: false,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF64748B),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          if (!isMobil) _buildBasliklar(),

          ...widget.satirlar.asMap().entries.map(
            (e) => isMobil
                ? _buildMobilSatir(context, e.key, e.value)
                : _buildSatir(context, e.key, e.value),
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onSatirEkle,
              icon: const Icon(Icons.add, color: Color(0xFF4F46E5), size: 18),
              label: Text(
                "Yeni Satır Ekle",
                style: GoogleFonts.inter(
                  color: const Color(0xFF4F46E5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(
                  0xFF4F46E5,
                ).withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilSatir(
    BuildContext context,
    int index,
    SatirYonetici yonetici,
  ) {
    TeklifSatiri satir = yonetici.veri;
    Map<String, dynamic>? seciliUrun;

    try {
      seciliUrun = widget.sistemUrunleri.firstWhere(
        (e) => e["Id"].toString() == satir.urunId.toString(),
      );
    } catch (e) {}

    String gosterilecekAd = seciliUrun?["UrunAdi"]?.toString() ?? satir.urunAdi;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Autocomplete<Map<String, dynamic>>(
                  key: ValueKey(
                    'auto_mobil_${index}_${satir.urunId}_$gosterilecekAd',
                  ),
                  initialValue: TextEditingValue(text: gosterilecekAd),
                  displayStringForOption: (option) =>
                      option["UrunAdi"]?.toString() ?? "-",
                  optionsBuilder: (TextEditingValue textValue) =>
                      _getFilteredOptions(textValue.text),
                  onSelected: (secim) {
                    yonetici.urunGuncelle(
                      secim["Id"],
                      secim["UrunAdi"],
                      double.tryParse(
                            secim["BirimFiyati"]?.toString() ?? "0",
                          ) ??
                          0.0,
                      double.tryParse(secim["KdvOrani"]?.toString() ?? "0") ??
                          0.0,
                    );
                    widget.onDegisiklik();
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return SizedBox(
                          height: 42,
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ürün ara...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              suffixIcon: const Icon(Icons.search, size: 16),
                            ),
                            onChanged: (v) => satir.urunAdi = v,
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
                          constraints: BoxConstraints(
                            maxHeight: 300,
                            maxWidth: MediaQuery.of(context).size.width - 70,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (c, i) => const Divider(
                              height: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            itemBuilder: (context, i) {
                              final u = options.elementAt(i);
                              List<String> resimler = [];
                              final rawGorsel = u["UrunGorsel"]?.toString();
                              if (rawGorsel != null && rawGorsel.isNotEmpty) {
                                if (rawGorsel.trimLeft().startsWith('[')) {
                                  try {
                                    resimler = List<String>.from(
                                      jsonDecode(rawGorsel),
                                    );
                                  } catch (e) {
                                    resimler = [rawGorsel];
                                  }
                                } else {
                                  resimler = [rawGorsel];
                                }
                              }

                              final kat = u["Kategori"]?.toString() ?? "";
                              final altKat = u["AltKategori"]?.toString() ?? "";
                              String katMetni = kat;
                              if (kat.isNotEmpty && altKat.isNotEmpty)
                                katMetni += " > $altKat";

                              return ListTile(
                                leading: GestureDetector(
                                  onTap: resimler.isNotEmpty
                                      ? () =>
                                            _galeriGoster(context, resimler, 0)
                                      : null,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: (resimler.isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.memory(
                                              base64Decode(
                                                resimler.first.replaceAll(
                                                  RegExp(r'\s+'),
                                                  '',
                                                ),
                                              ),
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Color(0xFF94A3B8),
                                                    size: 18,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFF64748B),
                                            size: 18,
                                          ),
                                  ),
                                ),
                                title: Text(
                                  u["UrunAdi"]?.toString() ?? "-",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (katMetni.isNotEmpty)
                                      Text(
                                        katMetni,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: const Color(0xFF4F46E5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    Text(
                                      "Kod: ${u["UrunKodu"] ?? "-"}  •  Fiyat: ${u["BirimFiyati"]} ${widget.seciliDoviz}",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => onSelected(u),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => widget.onSatirSil(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  yonetici.miktarCtrl,
                  (v) => yonetici.veri.miktar = int.tryParse(v) ?? 1,
                  prefix: "Adet: ",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInput(
                  yonetici.fiyatCtrl,
                  (v) => yonetici.veri.birimFiyat = double.tryParse(v) ?? 0.0,
                  prefix: "${widget.seciliDoviz} ",
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  yonetici.iskontoCtrl,
                  (v) =>
                      yonetici.veri.iskontoYuzdesi = double.tryParse(v) ?? 0.0,
                  prefix: "İsk %",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInput(
                  yonetici.kdvCtrl,
                  (v) => yonetici.veri.kdvOrani = double.tryParse(v) ?? 0.0,
                  prefix: "KDV %",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Toplam: ${satir.genelToplam.toStringAsFixed(2)} ${widget.seciliDoviz}",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasliklar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "KAYITLI ÜRÜN",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "MİKTAR",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "BİRİM FİYAT",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "% İSK.",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "% KDV",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "TOPLAM",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildSatir(BuildContext context, int index, SatirYonetici yonetici) {
    TeklifSatiri satir = yonetici.veri;
    Map<String, dynamic>? seciliUrun;

    try {
      seciliUrun = widget.sistemUrunleri.firstWhere(
        (e) => e["Id"].toString() == satir.urunId.toString(),
      );
    } catch (e) {}

    String gosterilecekAd = seciliUrun?["UrunAdi"]?.toString() ?? satir.urunAdi;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Autocomplete<Map<String, dynamic>>(
              key: ValueKey('auto_${index}_${satir.urunId}_$gosterilecekAd'),
              initialValue: TextEditingValue(text: gosterilecekAd),
              displayStringForOption: (option) =>
                  option["UrunAdi"]?.toString() ?? "-",
              optionsBuilder: (TextEditingValue textValue) =>
                  _getFilteredOptions(textValue.text),
              onSelected: (secim) {
                yonetici.urunGuncelle(
                  secim["Id"],
                  secim["UrunAdi"],
                  double.tryParse(secim["BirimFiyati"]?.toString() ?? "0") ??
                      0.0,
                  double.tryParse(secim["KdvOrani"]?.toString() ?? "0") ?? 0.0,
                );
                widget.onDegisiklik();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return SizedBox(
                      height: 42,
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ürün ara...",
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          suffixIcon: const Icon(Icons.search, size: 16),
                        ),
                        onChanged: (v) => satir.urunAdi = v,
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
                        maxHeight: 300,
                        maxWidth: 400,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (c, i) =>
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        itemBuilder: (context, i) {
                          final u = options.elementAt(i);
                          List<String> resimler = [];
                          final rawGorsel = u["UrunGorsel"]?.toString();
                          if (rawGorsel != null && rawGorsel.isNotEmpty) {
                            if (rawGorsel.trimLeft().startsWith('[')) {
                              try {
                                resimler = List<String>.from(
                                  jsonDecode(rawGorsel),
                                );
                              } catch (e) {
                                resimler = [rawGorsel];
                              }
                            } else {
                              resimler = [rawGorsel];
                            }
                          }

                          final kat = u["Kategori"]?.toString() ?? "";
                          final altKat = u["AltKategori"]?.toString() ?? "";
                          String katMetni = kat;
                          if (kat.isNotEmpty && altKat.isNotEmpty)
                            katMetni += " > $altKat";

                          return ListTile(
                            leading: GestureDetector(
                              onTap: resimler.isNotEmpty
                                  ? () => _galeriGoster(context, resimler, 0)
                                  : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: (resimler.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(
                                            resimler.first.replaceAll(
                                              RegExp(r'\s+'),
                                              '',
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.broken_image,
                                            color: Color(0xFF94A3B8),
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Color(0xFF64748B),
                                        size: 18,
                                      ),
                              ),
                            ),
                            title: Text(
                              u["UrunAdi"]?.toString() ?? "-",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (katMetni.isNotEmpty)
                                  Text(
                                    katMetni,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF4F46E5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                Text(
                                  "Kod: ${u["UrunKodu"] ?? "-"}  •  Fiyat: ${u["BirimFiyati"]} ${widget.seciliDoviz}",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => onSelected(u),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 42,
              child: _buildInput(
                yonetici.miktarCtrl,
                (v) => satir.miktar = int.tryParse(v) ?? 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 42,
              child: _buildInput(
                yonetici.fiyatCtrl,
                (v) => satir.birimFiyat = double.tryParse(v) ?? 0.0,
                prefix: "${widget.seciliDoviz} ",
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 42,
              child: _buildInput(
                yonetici.iskontoCtrl,
                (v) => satir.iskontoYuzdesi = double.tryParse(v) ?? 0.0,
                suffix: "%",
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 42,
              child: _buildInput(
                yonetici.kdvCtrl,
                (v) => satir.kdvOrani = double.tryParse(v) ?? 0.0,
                suffix: "%",
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              height: 42,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                "${satir.genelToplam.toStringAsFixed(2)} ${widget.seciliDoviz}",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            height: 42,
            child: InkWell(
              onTap: () => widget.onSatirSil(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    Function(String) onSave, {
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        prefixText: prefix,
        suffixText: suffix,
      ),
      onChanged: (v) {
        onSave(v);
        widget.onDegisiklik();
      },
    );
  }
}
