import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CalisanFormDialog extends StatefulWidget {
  final Map<String, dynamic>? calisan;
  final ApiService apiService;
  final VoidCallback onKaydedildi;

  const CalisanFormDialog({
    super.key,
    this.calisan,
    required this.apiService,
    required this.onKaydedildi,
  });

  @override
  State<CalisanFormDialog> createState() => _CalisanFormDialogState();
}

class _CalisanFormDialogState extends State<CalisanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isRolesLoading = true;

  late final TextEditingController _adController;
  late final TextEditingController _mailController;
  late final TextEditingController _sifreController;

  List<dynamic> _roller = [];
  int? _seciliRolId;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(
      text: widget.calisan?["AdSoyad"] ?? "",
    );
    _mailController = TextEditingController(
      text: widget.calisan?["Eposta"] ?? "",
    );
    _sifreController = TextEditingController();
    _seciliRolId = widget.calisan?["RolId"];
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    final roller = await widget.apiService.getRoller();
    if (mounted) {
      setState(() {
        _roller = roller;
        if (_seciliRolId == null && _roller.isNotEmpty) {
          _seciliRolId = _roller.first["Id"];
        }
        _isRolesLoading = false;
      });
    }
  }

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate() || _seciliRolId == null) return;
    setState(() => _isSaving = true);

    bool basarili;
    if (widget.calisan == null) {
      basarili = await widget.apiService.createKullanici(
        _adController.text,
        _mailController.text,
        _sifreController.text,
        _seciliRolId!,
      );
    } else {
      basarili = await widget.apiService.updateKullanici(
        widget.calisan!["Id"],
        _adController.text,
        _mailController.text,
        _sifreController.text,
        _seciliRolId!,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (basarili) {
        widget.onKaydedildi();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Çalışan başarıyla kaydedildi!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İşlem başarısız. Lütfen tekrar deneyin."),
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
        widget.calisan == null ? "Yeni Çalışan" : "Çalışan Düzenle",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: "Ad Soyad *",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                  labelText: "E-Posta *",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Zorunlu" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sifreController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.calisan == null
                      ? "Şifre *"
                      : "Yeni Şifre (Değişmeyecekse boş bırakın)",
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    widget.calisan == null && v!.isEmpty ? "Zorunlu" : null,
              ),
              const SizedBox(height: 12),
              _isRolesLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: _seciliRolId,
                      decoration: const InputDecoration(
                        labelText: "Yetki Rolü",
                        border: OutlineInputBorder(),
                      ),
                      items: _roller
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r["Id"],
                              child: Text(r["RolAdi"].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _seciliRolId = v),
                      validator: (v) => v == null ? "Rol seçiniz" : null,
                    ),
            ],
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
