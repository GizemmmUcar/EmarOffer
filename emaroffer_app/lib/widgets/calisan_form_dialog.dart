import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _sifreGizli = true;

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
          SnackBar(
            content: Text(
              "Çalışan başarıyla kaydedildi!",
              style: GoogleFonts.inter(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "İşlem başarısız. Lütfen tekrar deneyin.",
              style: GoogleFonts.inter(),
            ),
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
        widget.calisan == null ? "Yeni Çalışan" : "Çalışan Düzenle",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width < 600 ? double.maxFinite : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                _adController,
                "Ad Soyad *",
                isRequired: true,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _mailController,
                "E-Posta *",
                isRequired: true,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sifreController,
                obscureText: _sifreGizli,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: widget.calisan == null
                      ? "Şifre *"
                      : "Yeni Şifre (Değişmeyecekse boş bırakın)",
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
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _sifreGizli
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                  ),
                ),
                validator: (v) => widget.calisan == null && v!.isEmpty
                    ? "Zorunlu alan"
                    : null,
              ),
              const SizedBox(height: 16),
              _isRolesLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5),
                      ),
                    )
                  : DropdownButtonFormField<int>(
                      initialValue: _seciliRolId,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: "Yetki Rolü",
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      items: _roller.map((r) {
                        return DropdownMenuItem<int>(
                          value: r["Id"],
                          child: Text(
                            r["RolAdi"].toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _seciliRolId = v),
                      validator: (v) => v == null ? "Rol seçiniz" : null,
                    ),
            ],
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
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
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
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: const Color(0xFF64748B))
            : null,
      ),
      validator: isRequired ? (v) => v!.isEmpty ? "Zorunlu alan" : null : null,
    );
  }
}
