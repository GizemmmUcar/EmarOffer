import 'package:flutter/material.dart';
import '../widgets/sol_yan_menu.dart';
import '../widgets/ust_profil_bari.dart';
import 'dashboard_icerik.dart';
import 'teklifler_ekrani.dart';
import 'urunler_ekrani.dart';
import 'musteriler_ekrani.dart';
import 'calisanlar_ekrani.dart';
import 'sirket_ekrani.dart';
import 'sablon_listesi_ekrani.dart';

class AnaPanelEkrani extends StatefulWidget {
  final Map<String, dynamic> aktifKullanici;

  const AnaPanelEkrani({super.key, required this.aktifKullanici});

  @override
  State<AnaPanelEkrani> createState() => _AnaPanelEkraniState();
}

class _AnaPanelEkraniState extends State<AnaPanelEkrani> {
  int _aktifSayfaIndex = 0;

  Widget _aktifIcerigiGetir() {
    switch (_aktifSayfaIndex) {
      case 0:
        return const DashboardIcerik();
      case 1:
        return const TekliflerEkrani();
      case 2:
        return const MusterilerEkrani();
      case 3:
        return const UrunlerEkrani();
      case 4:
        return const SirketEkrani();
      case 5:
        return const CalisanlarEkrani();
      case 6:
        return const SablonListesiEkrani();
      default:
        return const Center(child: Text("Bu sayfa yapım aşamasında..."));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      appBar: isMobil
          ? AppBar(
              title: const Text(
                "Emar Offer",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              backgroundColor: const Color(0xFF374151),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            )
          : null,

      drawer: isMobil
          ? Drawer(
              child: SolYanMenu(
                aktifSayfa: _aktifSayfaIndex,
                aktifRol: widget.aktifKullanici['RolAdi'] ?? 'Personel',
                onSayfaDegisti: (yeniIndex) {
                  setState(() => _aktifSayfaIndex = yeniIndex);
                  Navigator.pop(context);
                },
              ),
            )
          : null,

      body: Row(
        children: [
          if (!isMobil)
            SolYanMenu(
              aktifSayfa: _aktifSayfaIndex,
              aktifRol: widget.aktifKullanici['RolAdi'] ?? 'Personel',
              onSayfaDegisti: (yeniIndex) =>
                  setState(() => _aktifSayfaIndex = yeniIndex),
            ),

          Expanded(
            child: Column(
              children: [
                UstProfilBari(kullaniciAdi: widget.aktifKullanici['AdSoyad']),
                Expanded(child: _aktifIcerigiGetir()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
