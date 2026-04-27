import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/calisan_form_dialog.dart';

class CalisanlarEkrani extends StatefulWidget {
  const CalisanlarEkrani({super.key});

  @override
  State<CalisanlarEkrani> createState() => _CalisanlarEkraniState();
}

class _CalisanlarEkraniState extends State<CalisanlarEkrani> {
  final ApiService _apiService = ApiService();
  List<dynamic> _calisanlar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    setState(() => _isLoading = true);
    final veriler = await _apiService.getKullanicilar();
    if (mounted) {
      setState(() {
        _calisanlar = veriler;
        _isLoading = false;
      });
    }
  }

  void _calisanDialogGoster({Map<String, dynamic>? calisan}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CalisanFormDialog(
        calisan: calisan,
        apiService: _apiService,
        onKaydedildi: _verileriCek,
      ),
    );
  }

  Future<void> _calisanSil(int id) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Çalışanı Sil"),
        content: const Text("Bu kullanıcıyı silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (onay == true) {
      final hata = await _apiService.deleteKullanici(id);
      if (hata == null && mounted) {
        _verileriCek();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Çalışan silindi.")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hata ?? "Hata oluştu"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.all(isMobil ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobil
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Çalışan Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _calisanDialogGoster(),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Yeni Çalışan Ekle",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Çalışan Yönetimi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _calisanDialogGoster(),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Yeni Çalışan Ekle",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _calisanlar.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = _calisanlar[index];
                        final rolAdi = c["RolAdi"]?.toString() ?? "Bilinmiyor";
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: rolAdi == "Yönetici"
                                ? Colors.amber.withOpacity(0.1)
                                : Colors.indigo.withOpacity(0.1),
                            child: Icon(
                              rolAdi == "Yönetici"
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              color: rolAdi == "Yönetici"
                                  ? Colors.amber[800]
                                  : Colors.indigo,
                            ),
                          ),
                          title: Text(
                            c["AdSoyad"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${c["Eposta"]} • $rolAdi"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _calisanDialogGoster(calisan: c),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _calisanSil(c["Id"]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
