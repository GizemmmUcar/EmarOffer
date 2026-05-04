import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../widgets/teklif_liste_elemani.dart';
import 'teklif_ekle_ekrani.dart';
import '../widgets/teklif_paylas_dialog.dart';
import 'dart:convert';

class TekliflerEkrani extends StatefulWidget {
  const TekliflerEkrani({super.key});

  @override
  State<TekliflerEkrani> createState() => _TekliflerEkraniState();
}

class _TekliflerEkraniState extends State<TekliflerEkrani> {
  final ApiService _apiService = ApiService();
  List<dynamic> _teklifler = [];
  bool _isLoading = true;
  String _siralama = "Yeniden Eskiye";

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
          if (_siralama == "Yeniden Eskiye") {
            veriler.sort(
              (a, b) => (b["Id"] as int? ?? 0).compareTo(a["Id"] as int? ?? 0),
            );
          } else {
            veriler.sort(
              (a, b) => (a["Id"] as int? ?? 0).compareTo(b["Id"] as int? ?? 0),
            );
          }
          _teklifler = veriler;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Teklifler çekilemedi: $e");
    }
  }

  Future<void> _teklifSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Emin misiniz?"),
        content: const Text(
          "Bu teklifi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (onay == true) {
      final hata = await _apiService.deleteTeklif(id);
      if (hata == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Teklif silindi."),
              backgroundColor: Colors.green,
            ),
          );
          _verileriCek();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(hata), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _durumGuncelle(int id, String yeniDurum) async {
    final basarili = await _apiService.updateTeklifDurumu(id, yeniDurum);
    if (basarili) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Durum güncellendi."),
            backgroundColor: Colors.green,
          ),
        );
        _verileriCek();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Durum güncellenemedi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _teklifDetayGoster(Map<String, dynamic> teklif) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.indigo)),
    );

    final detaylar = await _apiService.getTeklifDetaylari(teklif["Id"]);
    if (!mounted) return;
    Navigator.pop(context);

    final doviz = teklif["Doviz"]?.toString() ?? "TRY";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Teklif Detayı: ${teklif['TeklifNo'] ?? '-'}"),
        content: SizedBox(
          width: 600,
          height: 400,
          child: detaylar.isEmpty
              ? const Center(
                  child: Text("Bu teklife ait ürün detayı bulunamadı."),
                )
              : ListView.separated(
                  itemCount: detaylar.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final d = detaylar[index];
                    String? gorselBase64 = d["UrunGorsel"]?.toString();
                    if (gorselBase64 != null) {
                      gorselBase64 = gorselBase64.replaceAll(
                        RegExp(r'\s+'),
                        '',
                      );
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: (gorselBase64 != null && gorselBase64.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(gorselBase64),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.inventory_2,
                                color: Colors.indigo,
                                size: 24,
                              ),
                      ),
                      title: Text(
                        d["UrunAdi"]?.toString() ?? "Bilinmeyen Ürün",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Miktar: ${d['Miktar'] ?? 1}  |  Birim Fiyat: ${d['BirimFiyat'] ?? 0} $doviz",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "İskonto: %${d['IskontoYuzdesi'] ?? 0}  |  KDV Oranı: %${d['KdvOrani'] ?? 0}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  Future<void> _pdfOlusturVeGoster(Map<String, dynamic> teklif) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.indigo)),
    );

    try {
      final urunler = await _apiService.getTeklifDetaylari(teklif["Id"]);
      final sirketBilgileri = await _apiService.getSirketBilgileri();

      if (!mounted) return;
      Navigator.pop(context);

      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: teklif,
        urunler: urunler,
        sirket: sirketBilgileri ?? {},
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 800,
            height: 600,
            child: PdfPreview(
              build: (format) => pdfBytes,
              allowPrinting: true,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: "Teklif_${teklif['TeklifNo'] ?? 'Yeni'}.pdf",
              actions: [
                PdfPreviewAction(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: (context, build, pageFormat) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => TeklifPaylasDialog(teklif: teklif),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Kapat"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF oluşturulurken hata: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.all(isMobil ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobil
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Teklif Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            tooltip: "Sıralama Seçenekleri",
                            icon: const Icon(
                              Icons.sort,
                              size: 24,
                              color: Color(0xFF374151),
                            ),
                            offset: const Offset(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onSelected: (val) {
                              setState(() {
                                _siralama = val;
                                _verileriCek();
                              });
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: "Yeniden Eskiye",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: _siralama == "Yeniden Eskiye"
                                          ? Colors.indigo
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Yeniden Eskiye",
                                      style: TextStyle(
                                        fontWeight:
                                            _siralama == "Yeniden Eskiye"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _siralama == "Yeniden Eskiye"
                                            ? Colors.indigo
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "Eskiden Yeniye",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: _siralama == "Eskiden Yeniye"
                                          ? Colors.indigo
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Eskiden Yeniye",
                                      style: TextStyle(
                                        fontWeight:
                                            _siralama == "Eskiden Yeniye"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _siralama == "Eskiden Yeniye"
                                            ? Colors.indigo
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeklifEkleEkrani(
                                    onSaved: () => _verileriCek(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              "Yeni Teklif",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Teklif Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            tooltip: "Sıralama Seçenekleri",
                            icon: const Icon(
                              Icons.sort,
                              size: 20,
                              color: Color(0xFF374151),
                            ),
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            onSelected: (val) {
                              setState(() {
                                _siralama = val;
                                _verileriCek();
                              });
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: "Yeniden Eskiye",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: _siralama == "Yeniden Eskiye"
                                          ? Colors.indigo
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Yeniden Eskiye",
                                      style: TextStyle(
                                        fontWeight:
                                            _siralama == "Yeniden Eskiye"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _siralama == "Yeniden Eskiye"
                                            ? Colors.indigo
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "Eskiden Yeniye",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: _siralama == "Eskiden Yeniye"
                                          ? Colors.indigo
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Eskiden Yeniye",
                                      style: TextStyle(
                                        fontWeight:
                                            _siralama == "Eskiden Yeniye"
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _siralama == "Eskiden Yeniye"
                                            ? Colors.indigo
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeklifEkleEkrani(
                                  onSaved: () => _verileriCek(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            "Yeni Teklif Oluştur",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isMobil ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: isMobil
                    ? null
                    : Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (!isMobil) _buildListHeader(),
                  if (!isMobil) const Divider(height: 1),

                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.indigo,
                            ),
                          )
                        : _teklifler.isEmpty
                        ? _buildBosDurum()
                        : isMobil
                        ? ListView.builder(
                            itemCount: _teklifler.length,
                            itemBuilder: (context, index) {
                              final t = _teklifler[index];
                              return TeklifListeElemani(
                                index: index,
                                teklif: t,
                                onShowDetails: () => _teklifDetayGoster(t),
                                onDelete: () => _teklifSil(t["Id"]),
                                onStatusChange: (yeniDurum) =>
                                    _durumGuncelle(t["Id"], yeniDurum),
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeklifEkleEkrani(
                                        mevcutTeklif: t,
                                        onSaved: () => _verileriCek(),
                                      ),
                                    ),
                                  );
                                },
                                onPdfExport: () => _pdfOlusturVeGoster(t),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1250,
                              child: ListView.builder(
                                itemCount: _teklifler.length,
                                itemBuilder: (context, index) {
                                  final t = _teklifler[index];
                                  return TeklifListeElemani(
                                    index: index,
                                    teklif: t,
                                    onShowDetails: () => _teklifDetayGoster(t),
                                    onDelete: () => _teklifSil(t["Id"]),
                                    onStatusChange: (yeniDurum) =>
                                        _durumGuncelle(t["Id"], yeniDurum),
                                    onEdit: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TeklifEkleEkrani(
                                                mevcutTeklif: t,
                                                onSaved: () => _verileriCek(),
                                              ),
                                        ),
                                      );
                                    },
                                    onPdfExport: () => _pdfOlusturVeGoster(t),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 1250,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Row(
          children: [
            _headerCell("No", 40, isCenter: true),
            _headerCell("Teklif No", 140),
            _headerCell("Müşteri / Firma", 240),
            _headerCell("Oluşturan", 110),
            _headerCell("Tarihler", 140),
            _headerCell("Tutar", 130),
            _headerCell("İndirim", 90, isCenter: true),
            _headerCell("Durum", 140),
            _headerCell("İşlemler", 160),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String title, double width, {bool isCenter = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          textAlign: isCenter ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz hiç teklif oluşturulmamış.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
