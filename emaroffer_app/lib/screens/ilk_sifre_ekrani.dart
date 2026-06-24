import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'ana_panel_ekrani.dart';

class IlkSifreEkrani extends StatefulWidget {
  final Map<String, dynamic> aktifKullanici;
  const IlkSifreEkrani({super.key, required this.aktifKullanici});

  @override
  State<IlkSifreEkrani> createState() => _IlkSifreEkraniState();
}

class _IlkSifreEkraniState extends State<IlkSifreEkrani> {
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _sifreyiKaydet() async {
    if (_sifreController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre en az 6 haneli olmalıdır.")),
      );
      return;
    }
    if (_sifreController.text != _sifreTekrarController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Şifreler uyuşmuyor.")));
      return;
    }

    setState(() => _isLoading = true);

    bool basarili = await _apiService.ilkSifreyiDegistir(
      _sifreController.text.trim(),
    );

    if (!mounted) return;

    if (basarili) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AnaPanelEkrani(aktifKullanici: widget.aktifKullanici),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Şifre değiştirilemedi.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 60, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                "Güvenlik Uyarısı",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sisteme ilk kez giriş yapıyorsunuz. Hesabınızın güvenliği için lütfen geçici şifrenizi kalıcı bir şifreyle değiştirin.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _sifreController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Yeni Şifre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sifreTekrarController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Yeni Şifre (Tekrar)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sifreyiKaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Şifreyi Güncelle ve Devam Et",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
