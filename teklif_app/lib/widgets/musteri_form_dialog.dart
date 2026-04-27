import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MusteriFormDialog extends StatefulWidget {
  final Map<String, dynamic>? musteri;
  final ApiService apiService;
  final VoidCallback onKaydedildi;

  const MusteriFormDialog({
    super.key,
    this.musteri,
    required this.apiService,
    required this.onKaydedildi,
  });

  @override
  State<MusteriFormDialog> createState() => _MusteriFormDialogState();
}

class _MusteriFormDialogState extends State<MusteriFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _firmaController;
  late final TextEditingController _yetkiliController;
  late final TextEditingController _telefonController;
  late final TextEditingController _epostaController;
  late final TextEditingController _vdController;
  late final TextEditingController _vnoController;
  late final TextEditingController _adresController;

  @override
  void initState() {
    super.initState();
    final m = widget.musteri;
    _firmaController = TextEditingController(
      text: m?["FirmaAdi"]?.toString() ?? "",
    );
    _yetkiliController = TextEditingController(
      text: m?["YetkiliKisi"]?.toString() ?? "",
    );
    _telefonController = TextEditingController(
      text: m?["Telefon"]?.toString() ?? "",
    );
    _epostaController = TextEditingController(
      text: m?["Eposta"]?.toString() ?? "",
    );
    _vdController = TextEditingController(
      text: m?["VergiDairesi"]?.toString() ?? "",
    );
    _vnoController = TextEditingController(
      text: m?["VergiNo"]?.toString() ?? "",
    );
    _adresController = TextEditingController(
      text: m?["Adres"]?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _firmaController.dispose();
    _yetkiliController.dispose();
    _telefonController.dispose();
    _epostaController.dispose();
    _vdController.dispose();
    _vnoController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    bool basarili = false;
    if (widget.musteri == null) {
      basarili = await widget.apiService.createMusteri(
        _firmaController.text,
        _yetkiliController.text,
        _telefonController.text,
        _epostaController.text,
        _vdController.text,
        _vnoController.text,
        _adresController.text,
      );
    } else {
      basarili = await widget.apiService.updateMusteri(
        widget.musteri!["Id"],
        _firmaController.text,
        _yetkiliController.text,
        _telefonController.text,
        _epostaController.text,
        _vdController.text,
        _vnoController.text,
        _adresController.text,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (basarili) {
      widget.onKaydedildi();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Müşteri başarıyla kaydedildi!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştu. Lütfen tekrar deneyin."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.musteri == null ? "Yeni Müşteri Ekle" : "Müşteriyi Düzenle",
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
                _buildTextField(
                  _firmaController,
                  "Firma Adı / Unvan *",
                  isRequired: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _yetkiliController,
                  "Yetkili Kişi",
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _telefonController,
                        "Telefon *",
                        isRequired: true,
                        icon: Icons.phone,
                        inputType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        _epostaController,
                        "E-Posta",
                        icon: Icons.email,
                        inputType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_vdController, "Vergi Dairesi"),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(_vnoController, "Vergi No"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  _adresController,
                  "Açık Adres",
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("İptal", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          onPressed: _isSaving ? null : _kaydet,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    IconData? icon,
    TextInputType? inputType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Zorunlu alan" : null : null,
    );
  }
}
