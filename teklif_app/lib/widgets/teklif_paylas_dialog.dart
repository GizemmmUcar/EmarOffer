import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

class TeklifPaylasDialog extends StatefulWidget {
  final Map<String, dynamic> teklif;

  const TeklifPaylasDialog({super.key, required this.teklif});

  @override
  State<TeklifPaylasDialog> createState() => _TeklifPaylasDialogState();
}

class _TeklifPaylasDialogState extends State<TeklifPaylasDialog> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _pdfLink;

  @override
  void initState() {
    super.initState();
    _pdfHazirlaVeYukle();
  }

  Future<void> _pdfHazirlaVeYukle() async {
    try {
      final urunler = await _apiService.getTeklifDetaylari(widget.teklif["Id"]);
      final sirketBilgileri = await _apiService.getSirketBilgileri();
      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: widget.teklif,
        urunler: urunler,
        sirket: sirketBilgileri ?? {},
      );
      final teklifNo = widget.teklif["TeklifNo"] ?? "Yeni";
      final link = await _apiService.uploadPdfVeLinkAl(pdfBytes, teklifNo);

      if (mounted) {
        setState(() {
          _pdfLink = link;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PDF yüklenirken hata oluştu."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _whatsappIlePaylas() async {
    if (_pdfLink == null) return;
    final firma = widget.teklif["FirmaAdi"] ?? "Müşterimiz";
    final teklifNo = widget.teklif["TeklifNo"] ?? "";
    final mesaj =
        "Sayın $firma yetkilisi,\n\nGörüşmemize istinaden hazırlanan $teklifNo numaralı teklif dosyamızı aşağıdaki bağlantıdan güvenle görüntüleyebilir ve bilgisayarınıza indirebilirsiniz:\n\n $_pdfLink\n\nTeklifimizle ilgili her türlü sorunuz veya detaylı bilgi talebiniz için bizimle iletişime geçebilirsiniz.\n\nİyi çalışmalar dileriz.";
    final url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(mesaj)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _mailIlePaylas() async {
    if (_pdfLink == null) return;
    final firma = widget.teklif["FirmaAdi"] ?? "Müşterimiz";
    final teklifNo = widget.teklif["TeklifNo"] ?? "";
    final eposta = widget.teklif["Eposta"] ?? "";

    final konu = "$firma - $teklifNo Numaralı Teklif Dosyası";
    final mesaj =
        "Sayın $firma yetkilisi,\n\nGörüşmemize istinaden hazırlanan $teklifNo numaralı teklif dosyamızı aşağıdaki bağlantı üzerinden güvenle görüntüleyebilir ve bilgisayarınıza indirebilirsiniz:\n\n$_pdfLink\n\nTeklifimizle ilgili her türlü sorunuz veya detaylı bilgi talebiniz için bizimle bu e-posta üzerinden veya telefonla iletişime geçebilirsiniz.\n\nİyi çalışmalar dileriz.";

    final url = Uri.parse(
      "mailto:$eposta?subject=${Uri.encodeComponent(konu)}&body=${Uri.encodeComponent(mesaj)}",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Teklifi Paylaş",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        height: 180,
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(
                    "Güvenli Paylaşım Linki Oluşturuluyor...",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Teklifiniz paylaşıma hazır!",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _paylasButonu(
                        renk: Colors.green,
                        icon: Icons.chat,
                        etiket: "WhatsApp",
                        onTap: _whatsappIlePaylas,
                      ),
                      _paylasButonu(
                        renk: Colors.blue.shade600,
                        icon: Icons.mail,
                        etiket: "E-Posta",
                        onTap: _mailIlePaylas,
                      ),
                    ],
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Kapat", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _paylasButonu({
    required Color renk,
    required IconData icon,
    required String etiket,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: renk, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            etiket,
            style: TextStyle(
              color: renk,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
