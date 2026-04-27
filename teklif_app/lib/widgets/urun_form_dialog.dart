import 'package:flutter/material.dart';
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

  late final TextEditingController _adController;
  late final TextEditingController _urunController;
  late final TextEditingController _fiyatController;
  late final TextEditingController _paraController;
  late final TextEditingController _kdvController;
  late final TextEditingController _aciklamaController;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(
      text: widget.urun?["UrunAdi"]?.toString() ?? "",
    );
    _urunController = TextEditingController(
      text: widget.urun?["UrunKodu"]?.toString() ?? "",
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
  }

  @override
  void dispose() {
    _adController.dispose();
    _urunController.dispose();
    _fiyatController.dispose();
    _paraController.dispose();
    _kdvController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final fiyat = double.tryParse(_fiyatController.text) ?? 0.0;
    final kdv = int.tryParse(_kdvController.text) ?? 0;

    bool basarili;
    if (widget.urun == null) {
      basarili = await widget.apiService.createUrun(
        _adController.text,
        _urunController.text,
        fiyat,
        _paraController.text,
        kdv,
        _aciklamaController.text,
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
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (basarili) {
        widget.onKaydedildi();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İşlem başarılı!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İşlem başarısız."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.urun == null ? "Yeni Ürün Ekle" : "Ürünü Düzenle",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _adController,
                  decoration: const InputDecoration(
                    labelText: "Ürün Adı *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? "Zorunlu alan" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _urunController,
                  decoration: const InputDecoration(
                    labelText: "Ürün Kodu",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _fiyatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Fiyat *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Zorunlu alan" : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _paraController,
                        decoration: const InputDecoration(
                          labelText: "Döviz",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _kdvController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "% KDV",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aciklamaController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Açıklama",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("İptal"),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _kaydet,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text("Kaydet", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
