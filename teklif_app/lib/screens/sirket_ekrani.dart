import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class SirketEkrani extends StatefulWidget {
  const SirketEkrani({super.key});

  @override
  State<SirketEkrani> createState() => _SirketEkraniState();
}

class _SirketEkraniState extends State<SirketEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;

  final TextEditingController _sirketAdiController = TextEditingController();
  final TextEditingController _yetkiliController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _epostaController = TextEditingController();
  final TextEditingController _webController = TextEditingController();
  final TextEditingController _vergiDairesiController = TextEditingController();
  final TextEditingController _vergiNoController = TextEditingController();
  final TextEditingController _bankaController = TextEditingController();
  final TextEditingController _adresController = TextEditingController();

  String? _logoBase64;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    try {
      final sirket = await _apiService.getSirketBilgileri();
      if (sirket != null && mounted) {
        setState(() {
          _sirketAdiController.text = sirket["SirketAdi"]?.toString() ?? "";
          _yetkiliController.text = sirket["Yetkili"]?.toString() ?? "";
          _telefonController.text = sirket["Telefon"]?.toString() ?? "";
          _epostaController.text = sirket["Eposta"]?.toString() ?? "";
          _webController.text = sirket["WebSitesi"]?.toString() ?? "";
          _vergiDairesiController.text =
              sirket["VergiDairesi"]?.toString() ?? "";
          _vergiNoController.text = sirket["VergiNo"]?.toString() ?? "";
          _bankaController.text = sirket["BankaBilgileri"]?.toString() ?? "";
          _adresController.text = sirket["Adres"]?.toString() ?? "";
          _logoBase64 = sirket["Logo"]?.toString();
        });
      }
    } catch (e) {
      debugPrint("Şirket verileri çekilemedi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logoSec() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _logoBase64 = base64Encode(bytes);
      });
    }
  }

  void _logoTemizle() {
    setState(() {
      _logoBase64 = null;
    });
  }

  Future<void> _kaydet() async {
    setState(() => _isLoading = true);
    try {
      final basarili = await _apiService.updateSirketBilgileri({
        "SirketAdi": _sirketAdiController.text,
        "Yetkili": _yetkiliController.text,
        "Telefon": _telefonController.text,
        "Eposta": _epostaController.text,
        "WebSitesi": _webController.text,
        "VergiDairesi": _vergiDairesiController.text,
        "VergiNo": _vergiNoController.text,
        "BankaBilgileri": _bankaController.text,
        "Adres": _adresController.text,
        "Logo": _logoBase64 ?? "",
      });

      if (!mounted) return;

      if (basarili) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Şirket bilgileri güncellendi!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hata: Kaydedilemedi! Node.js konsoluna bakın."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("Hata: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 800;
    final solSutun = Column(
      children: [
        _buildKutu("Şirket Logosu", Icons.image, [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _logoSec,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    image: _logoBase64 != null && _logoBase64!.isNotEmpty
                        ? DecorationImage(
                            image: MemoryImage(base64Decode(_logoBase64!)),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: _logoBase64 == null || _logoBase64!.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Logo Seç",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              if (_logoBase64 != null && _logoBase64!.isNotEmpty)
                TextButton.icon(
                  onPressed: _logoTemizle,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "Logoyu Kaldır",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ]),
        const SizedBox(height: 16),
        _buildKutu("Genel Bilgiler", Icons.business, [
          _buildInput("Şirket Ünvanı", _sirketAdiController),
          _buildInput("Yetkili Kişi", _yetkiliController),
        ]),
      ],
    );

    final sagSutun = Column(
      children: [
        _buildKutu("İletişim Bilgileri", Icons.contact_mail, [
          _buildInput("Telefon Numarası", _telefonController),
          _buildInput("E-posta Adresi", _epostaController),
          _buildInput("Web Sitesi", _webController),
          _buildInput("Açık Adres", _adresController, maxLines: 2),
        ]),
        const SizedBox(height: 16),
        _buildKutu("Resmi Bilgiler", Icons.account_balance, [
          _buildInput("Vergi Dairesi", _vergiDairesiController),
          _buildInput("Vergi Numarası", _vergiNoController),
          _buildInput(
            "Banka ve TR IBAN Bilgileri",
            _bankaController,
            maxLines: 3,
          ),
        ]),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(isMobil ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Şirket Ayarları",
                style: TextStyle(
                  fontSize: isMobil ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF374151),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _kaydet,
                icon: const Icon(Icons.save, color: Colors.white, size: 18),
                label: Text(
                  _isLoading ? "Kaydediliyor..." : "Ayarları Kaydet",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobil ? 12 : 20,
                    vertical: isMobil ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: isMobil
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        solSutun,
                        const SizedBox(height: 16),
                        sagSutun,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: solSutun),
                        const SizedBox(width: 16),
                        Expanded(child: sagSutun),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKutu(String baslik, IconData ikon, List<Widget> cocuklar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...cocuklar.map(
            (c) =>
                Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String etiket,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiket,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
