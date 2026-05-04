import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import '../services/api_service.dart';
import '../models/teklif_model.dart';
import '../models/teklif_satiri_model.dart';
import '../widgets/teklif_toplamlar_karti.dart';
import 'dart:convert';

class TeklifEkleEkrani extends StatefulWidget {
  final Map<String, dynamic>? mevcutTeklif;
  final VoidCallback onSaved;

  const TeklifEkleEkrani({super.key, this.mevcutTeklif, required this.onSaved});

  @override
  State<TeklifEkleEkrani> createState() => _TeklifEkleEkraniState();
}

class _TeklifEkleEkraniState extends State<TeklifEkleEkrani> {
  final ApiService _apiService = ApiService();

  late final TextEditingController _teklifNoController;
  final TextEditingController _notController = TextEditingController();
  final TextEditingController _yFirmaController = TextEditingController();
  final TextEditingController _yYetkiliController = TextEditingController();
  final TextEditingController _yTelefonController = TextEditingController();
  final TextEditingController _yEpostaController = TextEditingController();
  final TextEditingController _yVergiDairesiController =
      TextEditingController();
  final TextEditingController _yVergiNoController = TextEditingController();
  final TextEditingController _yAdresController = TextEditingController();

  String? _secilenUlkeAdi = "Türkiye";
  String? _secilenUlkeKodu = "TR";
  String _telefonKodu = "+90";

  List<csc.State> _bolgeler = [];
  csc.State? _secilenBolge;

  List<csc.City> _sehirler = [];
  csc.City? _secilenSehir;

  int _gecerlilikGunu = 7;
  String _doviz = "TRY";
  String _odemeTuru = "Nakit";
  bool _yeniMusteri = false;
  int? _secilenMusteriId;

  List<dynamic> _musteriler = [];
  List<dynamic> _kayitliUrunler = [];
  List<TeklifSatiri> _kalemler = [TeklifSatiri()];

  @override
  void initState() {
    super.initState();
    final mevcutTeklifNo = widget.mevcutTeklif?["TeklifNo"]?.toString() ?? "";
    _teklifNoController = TextEditingController(
      text: mevcutTeklifNo.isNotEmpty
          ? mevcutTeklifNo
          : _otomatikTeklifNoUret(),
    );

    _verileriYukle();
    _varsayilanIlleriYukle();

    if (widget.mevcutTeklif != null) {
      _mevcutTeklifiYukle();
    }
  }

  @override
  void dispose() {
    _teklifNoController.dispose();
    _notController.dispose();
    _yFirmaController.dispose();
    _yYetkiliController.dispose();
    _yTelefonController.dispose();
    _yEpostaController.dispose();
    _yVergiDairesiController.dispose();
    _yVergiNoController.dispose();
    _yAdresController.dispose();
    super.dispose();
  }

  String _otomatikTeklifNoUret() {
    final now = DateTime.now();
    final tarih =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final rastgele = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    return "TK-$tarih-$rastgele";
  }

  Future<void> _varsayilanIlleriYukle() async {
    final bolgeler = await csc.getStatesOfCountry("TR");
    if (mounted) setState(() => _bolgeler = bolgeler);
  }

  Future<void> _verileriYukle() async {
    try {
      final musteriler = await _apiService.getMusteriler();
      if (mounted) setState(() => _musteriler = musteriler);
    } catch (e) {
      debugPrint("Müşteriler yüklenemedi: $e");
    }

    try {
      final urunler = await _apiService.getUrunler();
      if (mounted) {
        setState(() {
          _kayitliUrunler = urunler.isNotEmpty
              ? urunler
              : [
                  {"Id": 9999, "UrunAdi": "Örnek Ürün (Veritabanı Boş)"},
                ];
        });
      }
    } catch (e) {
      debugPrint("Ürünler yüklenemedi: $e");
    }
  }

  Future<void> _mevcutTeklifiYukle() async {
    final t = widget.mevcutTeklif!;

    _notController.text = t["GenelNot"]?.toString() ?? "";
    _doviz = t["Doviz"]?.toString() ?? "TRY";
    _odemeTuru = t["OdemeTuru"]?.toString() ?? "Nakit";
    _secilenMusteriId = t["MusteriId"];
    _gecerlilikGunu = t["GecerlilikGunu"] ?? 7;

    try {
      final detaylar = await _apiService.getTeklifDetaylari(t["Id"]);
      if (mounted) {
        setState(() {
          _kalemler = detaylar.map((d) {
            final satir = TeklifSatiri();
            satir.urunId = d["UrunId"];
            satir.miktar = d["Miktar"] ?? 1;
            satir.birimFiyat =
                double.tryParse(d["BirimFiyat"]?.toString() ?? "0") ?? 0.0;
            satir.iskontoYuzdesi =
                double.tryParse(d["IskontoYuzdesi"]?.toString() ?? "0") ?? 0.0;
            satir.kdvOrani =
                double.tryParse(d["KdvOrani"]?.toString() ?? "0") ?? 0.0;
            return satir;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Düzenleme için ürün detayları çekilemedi: $e");
    }
  }

  double _getAraToplam() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.hamToplam);
  double _getToplamIndirim() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.indirimTutari);
  double _getKdvHaricTutar() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.kdvHaricTutar);
  double _getToplamKdv() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.kdvTutari);
  double _getGenelToplam() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.genelToplam);

  Future<void> _kaydet() async {
    if (_teklifNoController.text.trim().isEmpty) {
      _hataGoster("Lütfen bir Teklif No girin!");
      return;
    }
    if (_yeniMusteri && _yFirmaController.text.trim().isEmpty) {
      _hataGoster("Lütfen yeni firma adını girin!");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.indigo)),
    );

    try {
      final yeniTeklif = TeklifModel(
        id: widget.mevcutTeklif?["Id"] ?? 0,
        teklifNo: _teklifNoController.text.trim(),
        musteriId: _secilenMusteriId ?? 0,
        firmaAdi: "",
        araToplam: _getAraToplam(),
        toplamIndirim: _getToplamIndirim(),
        genelToplam: _getGenelToplam(),
        durum: widget.mevcutTeklif?["Durum"] ?? "Bekliyor",
        genelNot: _notController.text,
        gecerlilikGunu: _gecerlilikGunu,
      );

      bool basarili = false;
      String temizSehir =
          _secilenBolge?.name
              .replaceAll(' Province', '')
              .replaceAll(' State', '')
              .trim() ??
          "";
      String temizIlce =
          _secilenSehir?.name
              .replaceAll(' İlçesi', '')
              .replaceAll(' District', '')
              .replaceAll(' Merkez', '')
              .trim() ??
          "";

      if (widget.mevcutTeklif == null) {
        basarili = await _apiService.createTeklif(
          teklif: yeniTeklif,
          satirlar: _kalemler,
          araToplam: _getAraToplam(),
          toplamIndirim: _getToplamIndirim(),
          genelNot: _notController.text,
          gecerlilikGunu: _gecerlilikGunu,
          secilenMusteriId: _secilenMusteriId,
          yeniFirmaAdi: _yeniMusteri ? _yFirmaController.text : null,
          yeniYetkiliKisi: _yeniMusteri ? _yYetkiliController.text : null,
          yeniTelefon: _yeniMusteri
              ? "$_telefonKodu ${_yTelefonController.text.trim()}"
              : null,
          yeniEposta: _yeniMusteri ? _yEpostaController.text : null,
          yeniVergiDairesi: _yeniMusteri ? _yVergiDairesiController.text : null,
          yeniVergiNo: _yeniMusteri ? _yVergiNoController.text : null,
          yeniAdres: _yeniMusteri ? _yAdresController.text : null,
          yeniUlke: _yeniMusteri ? _secilenUlkeAdi : null,
          yeniSehir: _yeniMusteri ? temizSehir : null,
          yeniIlce: _yeniMusteri ? temizIlce : null,
          doviz: _doviz,
          odemeTuru: _odemeTuru,
        );
      } else {
        basarili = await _apiService.updateTeklif(widget.mevcutTeklif!["Id"], {
          "teklifNo": _teklifNoController.text.trim(),
          "musteriId": _secilenMusteriId ?? widget.mevcutTeklif!["MusteriId"],
          "araToplam": _getAraToplam(),
          "toplamIndirim": _getToplamIndirim(),
          "genelToplam": _getGenelToplam(),
          "genelNot": _notController.text,
          "gecerlilikGunu": _gecerlilikGunu,
          "doviz": _doviz,
          "odemeTuru": _odemeTuru,
          "urunler": _kalemler.map((k) => k.toJson()).toList(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context);

      if (basarili) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Teklif başarıyla kaydedildi!"),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved();
        Navigator.pop(context);
      } else {
        _hataGoster("Kaydedilirken bir hata oluştu.");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _hataGoster("Hata: $e");
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Yeni Teklif",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isMobil)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Vazgeç",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: _kaydet,
              icon: const Icon(Icons.save, size: 18, color: Colors.white),
              label: const Text(
                "Kaydet",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobil ? 12.0 : 16.0),
        child: isMobil
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildKimlikKarti(isMobil),
                    const SizedBox(height: 12),
                    _buildMusteriKarti(isMobil),
                    const SizedBox(height: 12),
                    _buildUrunlerKarti(isMobil),
                    const SizedBox(height: 12),
                    _buildNotKarti(isMobil),
                    const SizedBox(height: 12),
                    _buildToplamlarKarti(),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildKimlikKarti(isMobil)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMusteriKarti(isMobil)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUrunlerKarti(isMobil),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: _buildNotKarti(isMobil)),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _buildToplamlarKarti()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildToplamlarKarti() {
    return TeklifToplamlarKarti(
      araToplam: _getAraToplam(),
      toplamIndirim: _getToplamIndirim(),
      kdvHaricTutar: _getKdvHaricTutar(),
      toplamKdv: _getToplamKdv(),
      genelToplam: _getGenelToplam(),
      doviz: _doviz,
    );
  }

  Widget _buildKimlikKarti(bool isMobil) {
    return _kutuTasarimi(
      baslik: "Kimlik Bilgileri",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kucukTextField("Teklif No", _teklifNoController),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(
                width: 70,
                child: Text(
                  "Geçerlilik:",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              _secimButonu(
                "7 Gün",
                _gecerlilikGunu == 7,
                () => setState(() => _gecerlilikGunu = 7),
              ),
              _secimButonu(
                "14 Gün",
                _gecerlilikGunu == 14,
                () => setState(() => _gecerlilikGunu = 14),
              ),
              _secimButonu(
                "30 Gün",
                _gecerlilikGunu == 30,
                () => setState(() => _gecerlilikGunu = 30),
              ),
              SizedBox(
                width: 60,
                height: 30,
                child: TextFormField(
                  initialValue: [7, 14, 30].contains(_gecerlilikGunu)
                      ? ""
                      : _gecerlilikGunu.toString(),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: "Özel",
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final gun = int.tryParse(v);
                    if (gun != null) setState(() => _gecerlilikGunu = gun);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(
                width: 70,
                child: Text("Döviz:", style: TextStyle(color: Colors.grey)),
              ),
              _secimButonu(
                "TRY",
                _doviz == "TRY",
                () => setState(() => _doviz = "TRY"),
              ),
              _secimButonu(
                "EUR",
                _doviz == "EUR",
                () => setState(() => _doviz = "EUR"),
              ),
              _secimButonu(
                "USD",
                _doviz == "USD",
                () => setState(() => _doviz = "USD"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const SizedBox(
                width: 70,
                child: Text("Ödeme:", style: TextStyle(color: Colors.grey)),
              ),

              _secimButonu(
                "Nakit",
                _odemeTuru == "Nakit",
                () => setState(() => _odemeTuru = "Nakit"),
              ),
              /*
              _secimButonu(
                "Havale/EFT",
                _odemeTuru == "Havale/EFT",
                () => setState(() => _odemeTuru = "Havale/EFT"),
              ),
              */
              _secimButonu(
                "Kredi Kartı",
                _odemeTuru == "Kredi Kartı",
                () => setState(() => _odemeTuru = "Kredi Kartı"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusteriKarti(bool isMobil) {
    return _kutuTasarimi(
      baslik: "Müşteri Bilgileri",
      sagUstWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Yeni Müşteri",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Switch(
            value: _yeniMusteri,
            activeTrackColor: Colors.indigo,
            onChanged: (val) => setState(() {
              _yeniMusteri = val;
              _secilenMusteriId = null;
            }),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_yeniMusteri) ...[
            _kucukTextField("Firma Adı", _yFirmaController),
            const SizedBox(height: 8),
            if (isMobil) ...[
              _kucukTextField("Yetkili Kişi", _yYetkiliController),
              const SizedBox(height: 8),
              _kucukTextField(
                "Telefon",
                _yTelefonController,
                prefixText: "$_telefonKodu ",
              ),
              const SizedBox(height: 8),
              _kucukTextField("E-posta", _yEpostaController),
              const SizedBox(height: 8),
              _buildUlkeSecici(),
              const SizedBox(height: 8),
              _buildIlIlceSecici(),
              const SizedBox(height: 8),
              _kucukTextField("Vergi Dairesi", _yVergiDairesiController),
              const SizedBox(height: 8),
              _kucukTextField("Vergi No", _yVergiNoController),
              const SizedBox(height: 8),
              _kucukTextField("Adres", _yAdresController),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _kucukTextField("Yetkili Kişi", _yYetkiliController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kucukTextField(
                      "Telefon",
                      _yTelefonController,
                      prefixText: "$_telefonKodu ",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _kucukTextField("E-posta", _yEpostaController),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildUlkeSecici()),
                ],
              ),
              const SizedBox(height: 8),
              _buildIlIlceSecici(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _kucukTextField(
                      "Vergi Dairesi",
                      _yVergiDairesiController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _kucukTextField("Vergi No", _yVergiNoController),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _kucukTextField("Adres", _yAdresController),
            ],
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: const Text(
                  "Kayıtlı Müşterilerinizden Seçin",
                  style: TextStyle(fontSize: 13),
                ),
                initialValue: _secilenMusteriId,
                items: _musteriler.map((m) {
                  return DropdownMenuItem<int>(
                    value: m["Id"],
                    child: Text(
                      m["FirmaAdi"]?.toString() ?? "Bilinmeyen Firma",
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _secilenMusteriId = val),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrunlerKarti(bool isMobil) {
    return _kutuTasarimi(
      baslik: "Ürünler ve Kalemler",
      child: isMobil
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: 700, child: _urunTablosuGovdesi()),
            )
          : _urunTablosuGovdesi(),
    );
  }

  Widget _urunTablosuGovdesi() {
    return Column(
      children: [
        _buildUrunBasliklari(),
        const Divider(height: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _kalemler.length,
          itemBuilder: (context, index) {
            final kalem = _kalemler[index];
            return _buildUrunSatiri(kalem, index);
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _kalemler.add(TeklifSatiri())),
            icon: const Icon(Icons.add, color: Colors.black87, size: 18),
            label: const Text(
              "Satır Ekle",
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200),
          ),
        ),
      ],
    );
  }

  Widget _buildUrunBasliklari() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              "Kayıtlı Ürün",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "Miktar",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "Birim Fiyat",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "% İsk.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              "% KDV",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "Satır Toplamı",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUrunSatiri(TeklifSatiri kalem, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              isExpanded: true,
              itemHeight: 60,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              hint: const Text("Ürün Seçin...", style: TextStyle(fontSize: 13)),
              initialValue: kalem.urunId,

              selectedItemBuilder: (BuildContext context) {
                return _kayitliUrunler.map<Widget>((u) {
                  return Text(
                    u["UrunAdi"]?.toString() ?? "-",
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  );
                }).toList();
              },

              items: _kayitliUrunler.map((u) {
                String? gorselBase64 = u["UrunGorsel"]?.toString();
                if (gorselBase64 != null) {
                  gorselBase64 = gorselBase64.replaceAll(RegExp(r'\s+'), '');
                }
                String aciklama =
                    u["Aciklama"]?.toString() ??
                    u["UrunAciklamasi"]?.toString() ??
                    "Açıklama bulunmuyor";

                return DropdownMenuItem<int>(
                  value: u["Id"],
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: (gorselBase64 != null && gorselBase64.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  base64Decode(gorselBase64),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.inventory_2,
                                color: Colors.indigo,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              u["UrunAdi"]?.toString() ?? "-",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              aciklama,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  kalem.urunId = val;
                  final secilenUrun = _kayitliUrunler.firstWhere(
                    (u) => u["Id"] == val,
                    orElse: () => null,
                  );
                  if (secilenUrun != null) {
                    kalem.birimFiyat =
                        double.tryParse(
                          secilenUrun["BirimFiyati"]?.toString() ?? "0",
                        ) ??
                        0.0;
                    kalem.kdvOrani =
                        double.tryParse(
                          secilenUrun["KdvOrani"]?.toString() ?? "0",
                        ) ??
                        0.0;
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              key: ValueKey("miktar_${index}_${kalem.miktar}"),
              initialValue: kalem.miktar.toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: (val) =>
                  setState(() => kalem.miktar = int.tryParse(val) ?? 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: ValueKey("fiyat_${index}_${kalem.birimFiyat}"),
              initialValue: kalem.birimFiyat == 0
                  ? "0"
                  : kalem.birimFiyat.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                suffixText: _doviz,
              ),
              onChanged: (val) => setState(
                () => kalem.birimFiyat = double.tryParse(val) ?? 0.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              key: ValueKey("iskonto_${index}_${kalem.iskontoYuzdesi}"),
              initialValue: kalem.iskontoYuzdesi == 0
                  ? "0"
                  : kalem.iskontoYuzdesi.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                suffixText: "%",
              ),
              onChanged: (val) => setState(
                () => kalem.iskontoYuzdesi = double.tryParse(val) ?? 0.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              key: ValueKey("kdv_${index}_${kalem.kdvOrani}"),
              initialValue: kalem.kdvOrani == 0
                  ? "0"
                  : kalem.kdvOrani.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                suffixText: "%",
              ),
              onChanged: (val) =>
                  setState(() => kalem.kdvOrani = double.tryParse(val) ?? 0.0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "${kalem.genelToplam.toStringAsFixed(2)} $_doviz",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => setState(() => _kalemler.removeAt(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotKarti(bool isMobil) {
    return _kutuTasarimi(
      baslik: "Genel Not / Açıklama",
      child: TextField(
        controller: _notController,
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          hintText: "Notları buraya girebilirsiniz...",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _kutuTasarimi({
    required String baslik,
    required Widget child,
    Widget? sagUstWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                baslik,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              sagUstWidget ?? const SizedBox.shrink(),
            ],
          ),
          const Divider(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _kucukTextField(
    String etiket,
    TextEditingController controller, {
    String? prefixText,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: etiket,
          labelStyle: const TextStyle(fontSize: 13),
          border: const OutlineInputBorder(),
          prefixText: prefixText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
        ),
      ),
    );
  }

  Widget _secimButonu(String metin, bool seciliMi, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: seciliMi ? Colors.blue.withAlpha(26) : Colors.white,
          border: Border.all(
            color: seciliMi ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          metin,
          style: TextStyle(
            color: seciliMi ? Colors.blue : Colors.black87,
            fontSize: 12,
            fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUlkeSecici() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          countryListTheme: CountryListThemeData(
            bottomSheetHeight: 500,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            inputDecoration: InputDecoration(
              labelText: 'Ülke Ara',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onSelect: (Country country) async {
            String gelenUlke = country.nameLocalized ?? country.name;
            if (gelenUlke == "Turkey") gelenUlke = "Türkiye";
            setState(() {
              _secilenUlkeAdi = gelenUlke;
              _secilenUlkeKodu = country.countryCode;
              _telefonKodu = "+${country.phoneCode}";
              _secilenBolge = null;
              _secilenSehir = null;
              _sehirler = [];
            });
            final bolgeler = await csc.getStatesOfCountry(country.countryCode);
            setState(() => _bolgeler = bolgeler);
          },
        );
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _secilenUlkeAdi ?? "Ülke Seç",
              style: TextStyle(
                fontSize: 13,
                color: _secilenUlkeAdi == null
                    ? Colors.grey.shade700
                    : Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildIlIlceSecici() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: DropdownButtonFormField<csc.State>(
              key: ValueKey("il_$_secilenUlkeKodu"),
              decoration: const InputDecoration(
                labelText: "İl",
                labelStyle: TextStyle(fontSize: 13),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              isExpanded: true,
              initialValue: _secilenBolge,
              items: _bolgeler
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(
                        b.name
                            .replaceAll(' Province', '')
                            .replaceAll(' State', '')
                            .trim(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (yeniBolge) async {
                setState(() {
                  _secilenBolge = yeniBolge;
                  _secilenSehir = null;
                  _sehirler = [];
                });
                if (yeniBolge != null && _secilenUlkeKodu != null) {
                  final hamSehirler = await csc.getStateCities(
                    _secilenUlkeKodu!,
                    yeniBolge.isoCode,
                  );
                  final Map<String, csc.City> benzersizMap = {};
                  for (var s in hamSehirler) {
                    String temizAd = s.name
                        .replaceAll(' İlçesi', '')
                        .replaceAll(' District', '')
                        .replaceAll(' Merkez', '')
                        .trim();
                    String k = temizAd
                        .toLowerCase()
                        .replaceAll('ı', 'i')
                        .replaceAll('ş', 's')
                        .replaceAll('ğ', 'g')
                        .replaceAll('ç', 'c')
                        .replaceAll('ö', 'o')
                        .replaceAll('ü', 'u')
                        .replaceAll('i̇', 'i');
                    if (!benzersizMap.containsKey(k)) {
                      benzersizMap[k] = s;
                    } else if (temizAd.contains(RegExp(r'[çğıöşüÇĞİÖŞÜ]'))) {
                      benzersizMap[k] = s;
                    }
                  }
                  var sirali = benzersizMap.values.toList();
                  sirali.sort((a, b) => a.name.compareTo(b.name));
                  setState(() => _sehirler = sirali);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 48,
            child: DropdownButtonFormField<csc.City>(
              key: ValueKey("ilce_${_secilenBolge?.isoCode}"),
              decoration: const InputDecoration(
                labelText: "İlçe",
                labelStyle: TextStyle(fontSize: 13),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              isExpanded: true,
              initialValue: _secilenSehir,
              items: _sehirler
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.name
                            .replaceAll(' İlçesi', '')
                            .replaceAll(' District', '')
                            .replaceAll(' Merkez', '')
                            .trim(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (yeniSehir) =>
                  setState(() => _secilenSehir = yeniSehir),
            ),
          ),
        ),
      ],
    );
  }
}
