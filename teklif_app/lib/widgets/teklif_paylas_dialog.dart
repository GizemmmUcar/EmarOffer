import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pdf_service.dart';
import '../services/api_service.dart';

class TeklifPaylasDialog extends StatefulWidget {
  final Map<String, dynamic> teklif;

  const TeklifPaylasDialog({super.key, required this.teklif});

  @override
  State<TeklifPaylasDialog> createState() => _TeklifPaylasDialogState();
}

class _TeklifPaylasDialogState extends State<TeklifPaylasDialog> {
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;

  late TextEditingController _mesajController;
  late TextEditingController _telefonController;

  @override
  void initState() {
    super.initState();

    String firmaAdi =
        widget.teklif["FirmaAdi"]?.toString() ?? "Değerli Müşterimiz";
    String teklifNo = widget.teklif["TeklifNo"]?.toString() ?? "";
    String tutar = widget.teklif["GenelToplam"]?.toString() ?? "";
    String doviz = widget.teklif["Doviz"]?.toString() ?? "TRY";
    String kayitliTelefon = widget.teklif["Telefon"]?.toString() ?? "";

    _telefonController = TextEditingController(text: kayitliTelefon);

    _mesajController = TextEditingController(
      text:
          "Merhaba $firmaAdi,\n\n"
          "İhtiyaçlarınız doğrultusunda hazırladığımız $teklifNo numaralı teklifimiz ekteki PDF dosyasında sunulmuştur.\n\n"
          "Teklif Tutarı: $tutar $doviz\n\n"
          "İyi çalışmalar dileriz.",
    );
  }

  @override
  void dispose() {
    _mesajController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  Future<void> _whatsappIlePaylas() async {
    setState(() => _isGenerating = true);

    try {
      String numara = _telefonController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (numara.isEmpty) {
        throw "Lütfen geçerli bir telefon numarası girin.";
      }
      if (!numara.startsWith('90') && numara.length == 10) {
        numara = '90$numara';
      }

      final urunler = await _apiService.getTeklifDetaylari(widget.teklif["Id"]);
      final sirketAyarlari = await _apiService.getSirketBilgileri();

      final pdfBytes = await PdfService.teklifPdfOlustur(
        teklif: widget.teklif,
        urunler: urunler,
        sirket: sirketAyarlari ?? {},
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Teklif_${widget.teklif["TeklifNo"]}.pdf',
      );

      final mesaj = Uri.encodeComponent(_mesajController.text);
      final url = Uri.parse("https://wa.me/$numara?text=$mesaj");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "WhatsApp açılamadı. Tarayıcınız engelleyici kullanıyor olabilir.";
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "WhatsApp ile Paylaş",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Paylaş butonuna bastığınızda PDF dosyası bilgisayarınıza iner ve WhatsApp açılır. PDF dosyasını sohbete sürükleyerek kolayca gönderebilirsiniz.",
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              "WhatsApp Numarası",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _telefonController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Örn: 905xxxxxxxxx",
                prefixIcon: const Icon(Icons.phone_android, color: Colors.teal),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Mesaj",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _mesajController,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isGenerating
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    "İptal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _whatsappIlePaylas,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                  label: Text(
                    _isGenerating ? "Hazırlanıyor..." : "WhatsApp'ta Paylaş",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
