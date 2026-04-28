import 'package:flutter/material.dart';
import '../models/teklif_satiri_model.dart';
import 'base_card.dart';

class SatirYonetici {
  TeklifSatiri veri;
  TextEditingController miktarCtrl;
  TextEditingController fiyatCtrl;
  TextEditingController iskontoCtrl;

  SatirYonetici(this.veri)
    : miktarCtrl = TextEditingController(text: veri.miktar.toString()),
      fiyatCtrl = TextEditingController(
        text: veri.birimFiyat.toStringAsFixed(2),
      ),
      iskontoCtrl = TextEditingController(
        text: veri.iskontoYuzdesi.toStringAsFixed(0),
      );

  void urunGuncelle(int id, String ad, double fiyat) {
    veri.urunId = id;
    veri.urunAdi = ad;
    veri.birimFiyat = fiyat;
    fiyatCtrl.text = fiyat.toStringAsFixed(2);
    veri.iskontoYuzdesi = 0.0;
    iskontoCtrl.text = "0";
  }

  void dispose() {
    miktarCtrl.dispose();
    fiyatCtrl.dispose();
    iskontoCtrl.dispose();
  }
}

class UrunSecimTablosu extends StatelessWidget {
  final List<SatirYonetici> satirlar;
  final List<dynamic> sistemUrunleri;
  final String seciliDoviz;
  final VoidCallback onSatirEkle;
  final Function(int) onSatirSil;
  final VoidCallback onDegisiklik;

  const UrunSecimTablosu({
    super.key,
    required this.satirlar,
    required this.sistemUrunleri,
    required this.seciliDoviz,
    required this.onSatirEkle,
    required this.onSatirSil,
    required this.onDegisiklik,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: "Ürünler ve Kalemler",
      child: Column(
        children: [
          _buildBasliklar(),
          ...satirlar.asMap().entries.map(
            (entry) => _buildSatir(entry.key, entry.value),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onSatirEkle,
              icon: const Icon(Icons.add),
              label: const Text("Satır Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasliklar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              "Kayıtlı Ürün",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Miktar",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Birim Fiyat",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "% İskonto",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Satır Toplamı",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSatir(int index, SatirYonetici yonetici) {
    TeklifSatiri satir = yonetici.veri;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: satir.urunId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: "Ürün Seçin...",
              ),
              items: sistemUrunleri
                  .map(
                    (u) => DropdownMenuItem<int>(
                      value: u["Id"],
                      child: Text(u["UrunAdi"].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  final secilen = sistemUrunleri.firstWhere(
                    (e) => e["Id"] == val,
                  );
                  yonetici.urunGuncelle(
                    val,
                    secilen["UrunAdi"].toString(),
                    (secilen["BirimFiyati"] ?? 0).toDouble(),
                  );
                  onDegisiklik();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: yonetici.miktarCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) {
                satir.miktar = int.tryParse(v) ?? 1;
                onDegisiklik();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: yonetici.fiyatCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                prefixText: "$seciliDoviz ",
              ),
              onChanged: (v) {
                satir.birimFiyat = double.tryParse(v) ?? 0.0;
                onDegisiklik();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: yonetici.iskontoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                suffixText: "%",
              ),
              onChanged: (v) {
                satir.iskontoYuzdesi = double.tryParse(v) ?? 0.0;
                onDegisiklik();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "${satir.indirimliToplam.toStringAsFixed(2)} $seciliDoviz",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onSatirSil(index),
          ),
        ],
      ),
    );
  }
}
