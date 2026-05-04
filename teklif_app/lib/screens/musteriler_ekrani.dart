import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/musteri_form_dialog.dart';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
      }
    }
  }

  void _musteriDetayGoster(Map<String, dynamic> musteri) {
    List<String> lokasyonList = [];
    if (musteri["Ilce"] != null && musteri["Ilce"].toString().isNotEmpty)
      lokasyonList.add(musteri["Ilce"]);
    if (musteri["Sehir"] != null && musteri["Sehir"].toString().isNotEmpty)
      lokasyonList.add(musteri["Sehir"]);
    if (musteri["Ulke"] != null && musteri["Ulke"].toString().isNotEmpty)
      lokasyonList.add(musteri["Ulke"]);

    String adresFormatli = musteri["Adres"]?.toString() ?? "";
    if (lokasyonList.isNotEmpty) {
      String hiyerarsi = lokasyonList.join(" / ");
      adresFormatli = adresFormatli.isNotEmpty
          ? "$adresFormatli\n\n$hiyerarsi"
          : hiyerarsi;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.business, color: Colors.indigo),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                musteri["FirmaAdi"]?.toString() ?? "Müşteri Detayı",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detayKart(Icons.person, "Yetkili Kişi", musteri["YetkiliKisi"]),
              _detayKart(Icons.phone, "Telefon", musteri["Telefon"]),
              _detayKart(Icons.email, "E-posta", musteri["Eposta"]),
              _detayKart(Icons.location_on, "Adres & Konum", adresFormatli),
              _detayKart(
                Icons.account_balance,
                "Vergi Dairesi / No",
                "${musteri["VergiDairesi"] ?? "-"} / ${musteri["VergiNo"] ?? "-"}",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Kapat",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detayKart(IconData icon, String baslik, dynamic deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.indigo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deger?.toString() ?? "-",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      builder: (context) => AlertDialog(
        title: const Text("Silme Onayı"),
        content: const Text("Bu müşteriyi silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (onay == true) {
      final hataMesaji = await _apiService.deleteMusteri(id);
      if (mounted) {
        if (hataMesaji == null) {
          _verileriCek();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Müşteri başarıyla silindi.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(hataMesaji), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Müşteri Yönetimi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _musteriDialogGoster(),
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text(
                  "Yeni Müşteri",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _musteriler.isEmpty
                ? const Center(
                    child: Text(
                      "Henüz müşteri bulunmuyor.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _musteriler.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final musteri = _musteriler[index];
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
                                Icons.business,
                                color: Colors.indigo,
                              ),
                            ),

                            title: Text(
                              musteri["FirmaAdi"]?.toString() ??
                                  "Bilinmeyen Firma",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),

                            subtitle: Text(
                              musteri["Sehir"] != null &&
                                      musteri["Sehir"].toString().isNotEmpty
                                  ? (musteri["Ilce"] != null &&
                                            musteri["Ilce"]
                                                .toString()
                                                .isNotEmpty
                                        ? "${musteri["Ilce"]} / ${musteri["Sehir"]}"
                                        : musteri["Sehir"])
                                  : "Müşteri Kaydı",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.teal,
                                  ),
                                  tooltip: "Detayları Gör",
                                  onPressed: () => _musteriDetayGoster(musteri),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                  ),
                                  tooltip: "Düzenle",
                                  onPressed: () =>
                                      _musteriDialogGoster(musteri: musteri),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Sil",
                                  onPressed: () => _musteriSil(musteri["Id"]),
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
