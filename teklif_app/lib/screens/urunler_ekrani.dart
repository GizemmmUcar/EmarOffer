import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/urun_form_dialog.dart';

class UrunlerEkrani extends StatefulWidget {
  const UrunlerEkrani({super.key});
  @override
  State<UrunlerEkrani> createState() => _UrunlerEkraniState();
}

class _UrunlerEkraniState extends State<UrunlerEkrani> {
  final ApiService _apiService = ApiService();

  List<dynamic> _urunler = [];
  List<dynamic> _filtrelenmisUrunler = [];
  final TextEditingController _aramaController = TextEditingController();

  bool _isLoading = true;

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
      setState(() {
        _urunler = veriler;
        _filtrelenmisUrunler = veriler;
        _aramaController.clear();
        _isLoading = false;
      });
    }
  }

  void _urunFiltrele(String arananKelime) {
    if (arananKelime.isEmpty) {
      setState(() {
        _filtrelenmisUrunler = _urunler;
      });
      return;
    }

    final kucukHarfliArama = arananKelime.toLowerCase();

    setState(() {
      _filtrelenmisUrunler = _urunler.where((urun) {
        final ad = (urun["UrunAdi"]?.toString() ?? "").toLowerCase();
        final kod = (urun["UrunKodu"]?.toString() ?? "").toLowerCase();
        return ad.contains(kucukHarfliArama) || kod.contains(kucukHarfliArama);
      }).toList();
    });
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

  Future<void> _urunSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silme Onayı"),
        content: const Text("Silmek istediğinize emin misiniz?"),
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
      final hataMesaji = await _apiService.deleteUrun(id);
      if (hataMesaji == null && mounted) {
        _verileriCek();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Ürün silindi.")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hataMesaji ?? "Hata oluştu"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _urunDetayGoster(Map<String, dynamic> urun) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.indigo),
            const SizedBox(width: 8),
            Expanded(child: Text(urun["UrunAdi"]?.toString() ?? "Ürün Detayı")),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detaySatiri("Ürün Adı:", urun["UrunAdi"]),
              _detaySatiri(
                "Ürün Kodu:",
                (urun["UrunKodu"] == null ||
                        urun["UrunKodu"].toString().isEmpty)
                    ? "-"
                    : urun["UrunKodu"],
              ),
              _detaySatiri(
                "Birim Fiyatı:",
                "${urun["BirimFiyati"]} ${urun["ParaBirimi"] ?? 'TRY'}",
              ),
              _detaySatiri("KDV Oranı:", "%${urun["KdvOrani"] ?? ''}"),
              const Divider(height: 24),
              const Text(
                "Açıklama:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                urun["Aciklama"]?.toString().isNotEmpty == true
                    ? urun["Aciklama"].toString()
                    : "Bu ürün için herhangi bir açıklama girilmemiş.",
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
  }

  Widget _detaySatiri(String baslik, dynamic deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              baslik,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              deger?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 600;

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
                      "Ürün Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _urunDialogGoster(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Yeni Ürün",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Ürün Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _urunDialogGoster(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Yeni Ürün",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _aramaController,
              onChanged: _urunFiltrele,
              decoration: InputDecoration(
                hintText: "Ürün adı veya kodu ile ara...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: _aramaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _aramaController.clear();
                          _urunFiltrele("");
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: _filtrelenmisUrunler.isEmpty
                        ? const Center(
                            child: Text(
                              "Aradığınız kritere uygun ürün bulunamadı.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filtrelenmisUrunler.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final urun = _filtrelenmisUrunler[index];
                              final urunKodu =
                                  (urun["UrunKodu"] ?? urun["UrunKodu"])
                                      ?.toString() ??
                                  "";

                              List<Widget> aksiyonButonlari() {
                                return [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      color: Colors.teal,
                                    ),
                                    tooltip: "Detaylar",
                                    onPressed: () => _urunDetayGoster(urun),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                    tooltip: "Düzenle",
                                    onPressed: () =>
                                        _urunDialogGoster(urun: urun),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    tooltip: "Sil",
                                    onPressed: () => _urunSil(urun["Id"]),
                                  ),
                                ];
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: ListTile(
                                  hoverColor: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  title: Text(
                                    urun["UrunAdi"]?.toString() ??
                                        "Bilinmeyen Ürün",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (urunKodu.isNotEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Text(
                                                "Ürün Kodu: $urunKodu",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.green.withOpacity(
                                                  0.3,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              "${urun["BirimFiyati"]} ${urun["ParaBirimi"] ?? 'TRY'}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isMobil) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: aksiyonButonlari(),
                                        ),
                                      ],
                                    ],
                                  ),

                                  trailing: isMobil
                                      ? null
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: aksiyonButonlari(),
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
