import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class UrunFormDialog extends StatefulWidget {
  final Map<String, dynamic>? urun;
  final ApiService apiService;
  final VoidCallback onKaydedildi;

  const UrunFormDialog({
    super.key,
    this.urun,
    required this.apiService,
    required this.onKaydedildi,
  });

  @override
  State<UrunFormDialog> createState() => _UrunFormDialogState();
}

class _UrunFormDialogState extends State<UrunFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  List<String> _secilenGorsellerBase64 = [];

  late final TextEditingController _adController;
  late final TextEditingController _urunController;
  late final TextEditingController _kategoriController;
  late final TextEditingController _altKategoriController;
  late final TextEditingController _fiyatController;
  late final TextEditingController _paraController;
  late final TextEditingController _kdvController;
  late final TextEditingController _aciklamaController;

  String _otomatikUrunKoduUret() {
    final now = DateTime.now();
    final tarih =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final rastgele = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    return "URN-$tarih-$rastgele";
  }

  @override
  void initState() {
    super.initState();

    _adController = TextEditingController(
      text: widget.urun?["UrunAdi"]?.toString() ?? "",
    );
    final mevcutKod = widget.urun?["UrunKodu"]?.toString() ?? "";
    _urunController = TextEditingController(
      text: mevcutKod.isNotEmpty ? mevcutKod : _otomatikUrunKoduUret(),
    );

    _kategoriController = TextEditingController(
      text: widget.urun?["Kategori"]?.toString() ?? "",
    );
    _altKategoriController = TextEditingController(
      text: widget.urun?["AltKategori"]?.toString() ?? "",
    );

    _fiyatController = TextEditingController(
      text: widget.urun?["BirimFiyati"]?.toString() ?? "",
    );
    _paraController = TextEditingController(
      text: widget.urun?["ParaBirimi"]?.toString() ?? "TRY",
    );
    _kdvController = TextEditingController(
      text: widget.urun?["KdvOrani"]?.toString() ?? "",
    );
    _aciklamaController = TextEditingController(
      text: widget.urun?["Aciklama"]?.toString() ?? "",
    );

    if (widget.urun != null && widget.urun!["UrunGorsel"] != null) {
      String rawGorsel = widget.urun!["UrunGorsel"].toString();
      if (rawGorsel.isNotEmpty) {
        if (rawGorsel.trimLeft().startsWith('[')) {
          try {
            List<dynamic> decodedList = jsonDecode(rawGorsel);
            _secilenGorsellerBase64 = decodedList
                .map((e) => e.toString())
                .toList();
          } catch (e) {
            _secilenGorsellerBase64 = [rawGorsel];
          }
        } else {
          _secilenGorsellerBase64 = [rawGorsel];
        }
      }
    }
  }

  @override
  void dispose() {
    _adController.dispose();
    _urunController.dispose();
    _kategoriController.dispose();
    _altKategoriController.dispose();
    _fiyatController.dispose();
    _paraController.dispose();
    _kdvController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _gorselleriSec() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);

      if (images.isNotEmpty) {
        for (var img in images) {
          final imageBytes = await img.readAsBytes();
          setState(() {
            _secilenGorsellerBase64.add(base64Encode(imageBytes));
          });
        }
      }
    } catch (e) {
      debugPrint("Görsel seçilirken hata: $e");
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final fiyat = double.tryParse(_fiyatController.text) ?? 0.0;
    final kdv = int.tryParse(_kdvController.text) ?? 0;

    String? finalGorseller = _secilenGorsellerBase64.isEmpty
        ? null
        : jsonEncode(_secilenGorsellerBase64);

    bool basarili;
    if (widget.urun == null) {
      basarili = await widget.apiService.createUrun(
        _adController.text,
        _urunController.text,
        fiyat,
        _paraController.text,
        kdv,
        _aciklamaController.text,
        finalGorseller,
        _kategoriController.text.trim(),
        _altKategoriController.text.trim(),
      );
    } else {
      basarili = await widget.apiService.updateUrun(
        widget.urun!["Id"],
        _adController.text,
        _urunController.text,
        fiyat,
        _paraController.text,
        kdv,
        _aciklamaController.text,
        finalGorseller,
        _kategoriController.text.trim(),
        _altKategoriController.text.trim(),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (basarili) {
        widget.onKaydedildi();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Ürün başarıyla kaydedildi!",
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("İşlem başarısız.", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.urun == null ? "Yeni Ürün Ekle" : "Ürünü Düzenle",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ürün Görselleri",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._secilenGorsellerBase64.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String base64 = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(
                                  base64.replaceAll(RegExp(r'\s+'), ''),
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: InkWell(
                              onTap: () => setState(
                                () => _secilenGorsellerBase64.removeAt(idx),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    InkWell(
                      onTap: _gorselleriSec,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Color(0xFF64748B),
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Ekle",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField(_adController, "Ürün Adı *", isRequired: true),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_urunController, "Ürün Kodu"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _kategoriController,
                        "Ana Kategori",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        _altKategoriController,
                        "Alt Kategori",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _fiyatController,
                        "Fiyat *",
                        isRequired: true,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(_paraController, "Döviz"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        _kdvController,
                        "% KDV",
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_aciklamaController, "Açıklama", maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 24, bottom: 24, top: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "İptal",
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _kaydet,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Kaydet",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF64748B),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Zorunlu alan" : null : null,
    );
  }
}
