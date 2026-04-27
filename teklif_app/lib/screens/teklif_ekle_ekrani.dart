import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/teklif_model.dart';
import '../models/teklif_satiri_model.dart';

class TeklifEkleEkrani extends StatefulWidget {
  final Map<String, dynamic>? mevcutTeklif;
  final VoidCallback onSaved;

  const TeklifEkleEkrani({super.key, this.mevcutTeklif, required this.onSaved});

  @override
  State<TeklifEkleEkrani> createState() => _TeklifEkleEkraniState();
}

class _TeklifEkleEkraniState extends State<TeklifEkleEkrani> {
  final ApiService _apiService = ApiService();

  final TextEditingController _teklifNoController = TextEditingController();
  final TextEditingController _notController = TextEditingController();
  final TextEditingController _yFirmaController = TextEditingController();
  final TextEditingController _yYetkiliController = TextEditingController();
  final TextEditingController _yTelefonController = TextEditingController();
  final TextEditingController _yEpostaController = TextEditingController();
  final TextEditingController _yVergiDairesiController =
      TextEditingController();
  final TextEditingController _yVergiNoController = TextEditingController();
  final TextEditingController _yAdresController = TextEditingController();

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
    _verileriYukle();
    if (widget.mevcutTeklif != null) {
      _mevcutTeklifiYukle();
    }
  }

  Future<void> _mevcutTeklifiYukle() async {
    final t = widget.mevcutTeklif!;

    _teklifNoController.text = t["TeklifNo"]?.toString() ?? "";
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
            return satir;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Düzenleme için ürün detayları çekilemedi: $e");
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

  double _getAraToplam() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.hamToplam);

  double _getToplamIndirim() => _kalemler.fold(
    0,
    (toplam, satir) =>
        toplam + (satir.hamToplam * (satir.iskontoYuzdesi / 100)),
  );

  double _getGenelToplam() =>
      _kalemler.fold(0, (toplam, satir) => toplam + satir.indirimliToplam);

  Future<void> _kaydet() async {
    if (_teklifNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen bir Teklif No girin!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_yeniMusteri && _yFirmaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen yeni firma adını girin!"),
          backgroundColor: Colors.red,
        ),
      );
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
          yeniTelefon: _yeniMusteri ? _yTelefonController.text : null,
          yeniEposta: _yeniMusteri ? _yEpostaController.text : null,
          yeniVergiDairesi: _yeniMusteri ? _yVergiDairesiController.text : null,
          yeniVergiNo: _yeniMusteri ? _yVergiNoController.text : null,
          yeniAdres: _yeniMusteri ? _yAdresController.text : null,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kaydedilirken bir hata oluştu."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
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
                    _buildToplamlarKarti(isMobil),
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
                          Expanded(
                            flex: 1,
                            child: _buildToplamlarKarti(isMobil),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
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
              _secimButonu(
                "Kredi Kartı",
                _odemeTuru == "Kredi Kartı",
                () => setState(() => _odemeTuru = "Kredi Kartı"),
              ),
              _secimButonu(
                "Havale/EFT",
                _odemeTuru == "Havale/EFT",
                () => setState(() => _odemeTuru = "Havale/EFT"),
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
            onChanged: (val) => setState(() {
              _yeniMusteri = val;
              _secilenMusteriId = null;
            }),
            activeTrackColor: Colors.indigo,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_yeniMusteri) ...[
            _kucukTextField("Firma Adı", _yFirmaController),
            const SizedBox(height: 8),
            isMobil
                ? Column(
                    children: [
                      _kucukTextField("Yetkili Kişi", _yYetkiliController),
                      const SizedBox(height: 8),
                      _kucukTextField("Telefon", _yTelefonController),
                      const SizedBox(height: 8),
                      _kucukTextField("E-posta", _yEpostaController),
                      const SizedBox(height: 8),
                      _kucukTextField(
                        "Vergi Dairesi",
                        _yVergiDairesiController,
                      ),
                      const SizedBox(height: 8),
                      _kucukTextField("Vergi No", _yVergiNoController),
                      const SizedBox(height: 8),
                      _kucukTextField("Adres", _yAdresController),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _kucukTextField(
                              "Yetkili Kişi",
                              _yYetkiliController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _kucukTextField(
                              "Telefon",
                              _yTelefonController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _kucukTextField(
                              "E-posta",
                              _yEpostaController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _kucukTextField(
                              "Vergi Dairesi",
                              _yVergiDairesiController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _kucukTextField(
                              "Vergi No",
                              _yVergiNoController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _kucukTextField("Adres", _yAdresController),
                          ),
                        ],
                      ),
                    ],
                  ),
            const SizedBox(height: 4),
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
        Padding(
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
                flex: 2,
                child: Text(
                  "Satır Toplamı",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _kalemler.length,
          itemBuilder: (context, index) {
            final kalem = _kalemler[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      hint: const Text(
                        "Ürün Seçin...",
                        style: TextStyle(fontSize: 13),
                      ),
                      initialValue: kalem.urunId,
                      items: _kayitliUrunler
                          .map(
                            (u) => DropdownMenuItem<int>(
                              value: u["Id"],
                              child: Text(
                                u["UrunAdi"]?.toString() ?? "-",
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
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
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
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
                      key: ValueKey("fiyat_${index}_${kalem.urunId}"),
                      initialValue: kalem.birimFiyat.toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
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
                      initialValue: kalem.iskontoYuzdesi.toString(),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        suffixText: "%",
                      ),
                      onChanged: (val) => setState(
                        () =>
                            kalem.iskontoYuzdesi = double.tryParse(val) ?? 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "${kalem.indirimliToplam.toStringAsFixed(2)} $_doviz",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _kalemler.removeAt(index)),
                    ),
                  ),
                ],
              ),
            );
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

  Widget _buildToplamlarKarti(bool isMobil) {
    return _kutuTasarimi(
      baslik: "Toplamlar",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ara Toplam:",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "${_getAraToplam().toStringAsFixed(2)} $_doviz",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Toplam İndirim:",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "-${_getToplamIndirim().toStringAsFixed(2)} $_doviz",
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Genel Toplam:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "${_getGenelToplam().toStringAsFixed(2)} $_doviz",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
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

  Widget _kucukTextField(String etiket, TextEditingController controller) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: etiket,
          labelStyle: const TextStyle(fontSize: 13),
          border: const OutlineInputBorder(),
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
}
