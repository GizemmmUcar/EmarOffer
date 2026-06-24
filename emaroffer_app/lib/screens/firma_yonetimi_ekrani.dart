import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class FirmaYonetimiEkrani extends StatefulWidget {
  const FirmaYonetimiEkrani({super.key});

  @override
  State<FirmaYonetimiEkrani> createState() => _FirmaYonetimiEkraniState();
}

class _FirmaYonetimiEkraniState extends State<FirmaYonetimiEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _firmalar = [];
  List<dynamic> _filtrelenmisFirmalar = [];
  final TextEditingController _aramaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firmalariCek();
    _aramaController.addListener(_aramaYap);
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  Future<void> _firmalariCek() async {
    setState(() => _isLoading = true);
    final veriler = await _apiService.getFirmalar();
    if (mounted) {
      setState(() {
        _firmalar = veriler;
        _filtrelenmisFirmalar = veriler;
        _isLoading = false;
      });
    }
  }

  void _aramaYap() {
    final query = _aramaController.text.toLowerCase();
    setState(() {
      _filtrelenmisFirmalar = _firmalar.where((firma) {
        return firma['FirmaAdi'].toString().toLowerCase().contains(query) ||
            firma['FirmaKodu'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  String _otomatikKodUret(String firmaAdi) {
    String temiz = firmaAdi.toUpperCase().trim();
    temiz = temiz
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ş', 'S')
        .replaceAll('İ', 'I')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
    temiz = temiz.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (temiz.length > 8) temiz = temiz.substring(0, 8);
    int rastgeleSayi = Random().nextInt(9000) + 1000;
    return "${temiz}_$rastgeleSayi";
  }

  void _firmaIslemDialog({Map<String, dynamic>? mevcutFirma}) {
    final bool isUpdate = mevcutFirma != null;
    final TextEditingController adController = TextEditingController(
      text: isUpdate ? mevcutFirma['FirmaAdi'] : "",
    );
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              isUpdate ? "Firmayı Düzenle" : "Sisteme Yeni Firma Tanımla",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: adController,
                  decoration: const InputDecoration(
                    labelText: "Firma / İşletme Adı",
                    border: OutlineInputBorder(),
                  ),
                ),
                if (!isUpdate) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Not: Benzersiz firma giriş kodu otomatik üretilecektir.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text("İptal"),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (adController.text.trim().isEmpty) return;
                        setDialogState(() => isSaving = true);

                        if (isUpdate) {
                          bool basarili = await _apiService.updateFirma(
                            mevcutFirma['Id'],
                            adController.text.trim(),
                            mevcutFirma['AktifMi'],
                          );
                          if (basarili && mounted) {
                            Navigator.pop(ctx);
                            _firmalariCek();
                          } else {
                            setDialogState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Güncelleme başarısız oldu."),
                              ),
                            );
                          }
                        } else {
                          String uretilenKod = _otomatikKodUret(
                            adController.text,
                          );
                          final sonuc = await _apiService.createFirma(
                            uretilenKod,
                            adController.text.trim(),
                          );

                          if (sonuc != null && mounted) {
                            Navigator.pop(ctx);
                            _firmalariCek();

                            final String mesaj =
                                "Merhaba,\nEmar Offer sistemine firmanız tanımlanmıştır.\n\n"
                                "🏢 Firma Kodu: $uretilenKod\n"
                                "👤 Kullanıcı Adı: ${sonuc['kullaniciAdi']}\n"
                                "🔑 Geçici Şifre: ${sonuc['sifre']}\n\n"
                                "Sisteme giriş yaptığınızda güvenlik gereği şifrenizi değiştirmeniz istenecektir.";

                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text(
                                  "Firma Kurulumu Tamamlandı! 🎉",
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(mesaj),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Giriş Bilgilerini Paylaş:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => launchUrl(
                                            Uri.parse(
                                              "https://wa.me/?text=${Uri.encodeComponent(mesaj)}",
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "WhatsApp",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () => launchUrl(
                                            Uri.parse(
                                              "mailto:?subject=Sistem Giriş Bilgileri&body=${Uri.encodeComponent(mesaj)}",
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.mail,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "E-Posta",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text("Kapat"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            setDialogState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Firma eklenemedi veya kod zaten var.",
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isUpdate ? "Kaydet" : "Tanımla"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _firmaDurumDegistir(Map<String, dynamic> firma) async {
    bool yeniDurum = !firma['AktifMi'];
    bool basarili = await _apiService.updateFirma(
      firma['Id'],
      firma['FirmaAdi'],
      yeniDurum,
    );
    if (basarili) _firmalariCek();
  }

  void _firmaSil(int id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Firmayı Sil"),
            content: const Text(
              "Bu firmayı kalıcı olarak silmek istediğinize emin misiniz? (Tüm geçmiş veriler kalıcı olarak silinecektir)",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("İptal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Evet, Sil",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      String? hata = await _apiService.deleteFirma(id);
      if (hata == null) {
        _firmalariCek();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(hata)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Firma Yönetimi / Lisanslı Firmalar",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _firmaIslemDialog(),
                icon: const Icon(Icons.business, color: Colors.white, size: 18),
                label: Text(
                  "Yeni Firma Ekle",
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _aramaController,
            decoration: InputDecoration(
              hintText: "Firma Adı veya Kodu ile ara...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : _filtrelenmisFirmalar.isEmpty
                ? const Center(child: Text("Firma bulunamadı."))
                : ListView.builder(
                    itemCount: _filtrelenmisFirmalar.length,
                    itemBuilder: (context, index) {
                      final firma = _filtrelenmisFirmalar[index];
                      final bool isEmar = firma['Id'] == 1;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isEmar
                                ? Colors.red.shade50
                                : (firma['AktifMi']
                                      ? Colors.indigo.shade50
                                      : Colors.grey.shade200),
                            child: Icon(
                              isEmar
                                  ? Icons.admin_panel_settings
                                  : Icons.business,
                              color: isEmar
                                  ? Colors.red
                                  : (firma['AktifMi']
                                        ? Colors.indigo
                                        : Colors.grey),
                            ),
                          ),
                          title: Text(
                            firma['FirmaAdi'],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("Giriş Kodu: ${firma['FirmaKodu']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: firma['AktifMi']
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  firma['AktifMi'] ? "Aktif" : "Askıda",
                                  style: TextStyle(
                                    color: firma['AktifMi']
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (!isEmar) ...[
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'duzenle')
                                      _firmaIslemDialog(mevcutFirma: firma);
                                    if (value == 'durum')
                                      _firmaDurumDegistir(firma);
                                    if (value == 'sil') _firmaSil(firma['Id']);
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'duzenle',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text("Düzenle"),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'durum',
                                      child: Row(
                                        children: [
                                          Icon(
                                            firma['AktifMi']
                                                ? Icons.pause_circle_outline
                                                : Icons.play_circle_outline,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            firma['AktifMi']
                                                ? "Askıya Al"
                                                : "Aktifleştir",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'sil',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Kalıcı Sil",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
