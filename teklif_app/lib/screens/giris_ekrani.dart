import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ana_panel_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _epostaController = TextEditingController();
  final _sifreController = TextEditingController();

  bool _isLoading = false;
  bool _sifreGizli = true;

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final kullanici = await _apiService.girisYap(
      _epostaController.text.trim(),
      _sifreController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (kullanici != null) {
        ApiService.aktifKullaniciId = kullanici['Id'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnaPanelEkrani(aktifKullanici: kullanici),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hatalı e-posta veya şifre!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sifremiUnuttumDialogGoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.indigo),
            SizedBox(width: 8),
            Text("Şifre Sıfırlama"),
          ],
        ),
        content: const Text(
          "Şifrenizi yenilemek için lütfen sistem yöneticiniz (Admin) ile iletişime geçin. Yöneticiniz 'Çalışan Yönetimi' panelinden size yeni bir şifre tanımlayabilir.",
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Tamam, Anladım",
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.business_center,
                    size: 64,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Teklif Sistemi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Lütfen e-posta ve şifrenizle giriş yapın",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _epostaController,
                    decoration: const InputDecoration(
                      labelText: "E-Posta",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty || !v.contains("@")
                        ? "Geçerli bir e-posta girin"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _sifreController,
                    obscureText: _sifreGizli,
                    decoration: InputDecoration(
                      labelText: "Şifre",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _sifreGizli ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _sifreGizli = !_sifreGizli),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Şifre boş bırakılamaz" : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _sifremiUnuttumDialogGoster(context),
                      child: const Text(
                        "Şifremi Unuttum?",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Giriş Yap",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
