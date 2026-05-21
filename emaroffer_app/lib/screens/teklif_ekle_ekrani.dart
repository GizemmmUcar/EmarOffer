import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import '../services/api_service.dart';
import '../models/teklif_model.dart';
import '../models/teklif_satiri_model.dart';
import '../widgets/teklif_toplamlar_karti.dart';
import '../widgets/urun_secim_tablosu.dart';
import '../widgets/teklif_ekle_kimlik_bilgileri_karti.dart';
import '../widgets/teklif_ekle_musteri_secim_karti.dart';
import '../widgets/teklif_ekle_not_ve_aciklama_karti.dart';

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
  final List<SatirYonetici> _satirYoneticileri = [];

  @override
  void initState() {
    super.initState();
    final mevcutTeklifNo = widget.mevcutTeklif?["TeklifNo"]?.toString() ?? "";
    _teklifNoController = TextEditingController(
      text: mevcutTeklifNo.isNotEmpty
          ? mevcutTeklifNo
          : _otomatikTeklifNoUret(),
    );

    _satirYoneticileri.add(SatirYonetici(TeklifSatiri()));
    _verileriYukle();
    _varsayilanIlleriYukle();

    if (widget.mevcutTeklif != null) _mevcutTeklifiYukle();
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
    for (var y in _satirYoneticileri) {
      y.dispose();
    }
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
      //
    }

    try {
      final urunler = await _apiService.getUrunler();
      if (mounted) {
        setState(() {
          _kayitliUrunler = urunler.isNotEmpty
              ? urunler
              : [
                  {"Id": 9999, "UrunAdi": "Örnek Ürün"},
                ];
        });
      }
    } catch (e) {
      //
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
      if (mounted && detaylar.isNotEmpty) {
        setState(() {
          _satirYoneticileri.clear();
          for (var d in detaylar) {
            final satir = TeklifSatiri();
            satir.urunId = d["UrunId"];
            satir.urunAdi = d["UrunAdi"] ?? "";
            satir.miktar = d["Miktar"] ?? 1;
            satir.birimFiyat =
                double.tryParse(d["BirimFiyat"]?.toString() ?? "0") ?? 0.0;
            satir.iskontoYuzdesi =
                double.tryParse(d["IskontoYuzdesi"]?.toString() ?? "0") ?? 0.0;
            satir.kdvOrani =
                double.tryParse(d["KdvOrani"]?.toString() ?? "0") ?? 0.0;
            _satirYoneticileri.add(SatirYonetici(satir));
          }
        });
      }
    } catch (e) {
      //
    }
  }

  Future<void> _ulkeSecildi(Country country) async {
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
    if (mounted) setState(() => _bolgeler = bolgeler);
  }

  Future<void> _bolgeSecildi(csc.State? yeniBolge) async {
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
        } else if (temizAd.contains(RegExp(r'[çğıöşüÇĞİÖŞÜ]')))
          benzersizMap[k] = s;
      }
      var sirali = benzersizMap.values.toList();
      sirali.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) setState(() => _sehirler = sirali);
    }
  }

  double _getAraToplam() =>
      _satirYoneticileri.fold(0, (t, y) => t + y.veri.hamToplam);
  double _getToplamIndirim() =>
      _satirYoneticileri.fold(0, (t, y) => t + y.veri.indirimTutari);
  double _getKdvHaricTutar() =>
      _satirYoneticileri.fold(0, (t, y) => t + y.veri.kdvHaricTutar);
  double _getToplamKdv() =>
      _satirYoneticileri.fold(0, (t, y) => t + y.veri.kdvTutari);
  double _getGenelToplam() =>
      _satirYoneticileri.fold(0, (t, y) => t + y.veri.genelToplam);

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
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
      ),
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
      List<TeklifSatiri> kaydedilecekSatirlar = _satirYoneticileri
          .map((y) => y.veri)
          .toList();

      if (widget.mevcutTeklif == null) {
        basarili = await _apiService.createTeklif(
          teklif: yeniTeklif,
          satirlar: kaydedilecekSatirlar,
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
          "urunler": kaydedilecekSatirlar.map((k) => k.toJson()).toList(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context);

      if (basarili) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Teklif kaydedildi!", style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF10B981),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final bool isMobil = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mevcutTeklif == null
              ? "Yeni Teklif Oluştur"
              : "Teklifi Düzenle",
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              onPressed: _kaydet,
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                "Teklifi Kaydet",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobil ? 16.0 : 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isMobil
                  ? Column(
                      children: [
                        TeklifEkleKimlikBilgileriKarti(
                          teklifNoController: _teklifNoController,
                          gecerlilikGunu: _gecerlilikGunu,
                          onGecerlilikGunuChanged: (val) =>
                              setState(() => _gecerlilikGunu = val),
                          doviz: _doviz,
                          onDovizChanged: (val) => setState(() => _doviz = val),
                          odemeTuru: _odemeTuru,
                          onOdemeTuruChanged: (val) =>
                              setState(() => _odemeTuru = val),
                        ),
                        const SizedBox(height: 24),
                        TeklifEkleMusteriSecimKarti(
                          yeniMusteri: _yeniMusteri,
                          onYeniMusteriChanged: (val) => setState(() {
                            _yeniMusteri = val;
                            _secilenMusteriId = null;
                          }),
                          mevcutTeklif: widget.mevcutTeklif,
                          musteriler: _musteriler,
                          onMusteriSecildi: (val) =>
                              setState(() => _secilenMusteriId = val),
                          yFirmaController: _yFirmaController,
                          yYetkiliController: _yYetkiliController,
                          telefonKodu: _telefonKodu,
                          yTelefonController: _yTelefonController,
                          yEpostaController: _yEpostaController,
                          secilenUlkeAdi: _secilenUlkeAdi,
                          secilenUlkeKodu: _secilenUlkeKodu,
                          onUlkeSecildi: _ulkeSecildi,
                          bolgeler: _bolgeler,
                          secilenBolge: _secilenBolge,
                          onBolgeSecildi: _bolgeSecildi,
                          sehirler: _sehirler,
                          secilenSehir: _secilenSehir,
                          onSehirSecildi: (val) =>
                              setState(() => _secilenSehir = val),
                          yVergiDairesiController: _yVergiDairesiController,
                          yVergiNoController: _yVergiNoController,
                          yAdresController: _yAdresController,
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TeklifEkleKimlikBilgileriKarti(
                              teklifNoController: _teklifNoController,
                              gecerlilikGunu: _gecerlilikGunu,
                              onGecerlilikGunuChanged: (val) =>
                                  setState(() => _gecerlilikGunu = val),
                              doviz: _doviz,
                              onDovizChanged: (val) =>
                                  setState(() => _doviz = val),
                              odemeTuru: _odemeTuru,
                              onOdemeTuruChanged: (val) =>
                                  setState(() => _odemeTuru = val),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: TeklifEkleMusteriSecimKarti(
                              yeniMusteri: _yeniMusteri,
                              onYeniMusteriChanged: (val) => setState(() {
                                _yeniMusteri = val;
                                _secilenMusteriId = null;
                              }),
                              mevcutTeklif: widget.mevcutTeklif,
                              musteriler: _musteriler,
                              onMusteriSecildi: (val) =>
                                  setState(() => _secilenMusteriId = val),
                              yFirmaController: _yFirmaController,
                              yYetkiliController: _yYetkiliController,
                              telefonKodu: _telefonKodu,
                              yTelefonController: _yTelefonController,
                              yEpostaController: _yEpostaController,
                              secilenUlkeAdi: _secilenUlkeAdi,
                              secilenUlkeKodu: _secilenUlkeKodu,
                              onUlkeSecildi: _ulkeSecildi,
                              bolgeler: _bolgeler,
                              secilenBolge: _secilenBolge,
                              onBolgeSecildi: _bolgeSecildi,
                              sehirler: _sehirler,
                              secilenSehir: _secilenSehir,
                              onSehirSecildi: (val) =>
                                  setState(() => _secilenSehir = val),
                              yVergiDairesiController: _yVergiDairesiController,
                              yVergiNoController: _yVergiNoController,
                              yAdresController: _yAdresController,
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 24),

              UrunSecimTablosu(
                satirlar: _satirYoneticileri,
                sistemUrunleri: _kayitliUrunler,
                seciliDoviz: _doviz,
                onSatirEkle: () => setState(
                  () => _satirYoneticileri.add(SatirYonetici(TeklifSatiri())),
                ),
                onSatirSil: (index) {
                  if (_satirYoneticileri.length > 1) {
                    setState(() {
                      _satirYoneticileri[index].dispose();
                      _satirYoneticileri.removeAt(index);
                    });
                  }
                },
                onDegisiklik: () => setState(() {}),
              ),
              const SizedBox(height: 24),

              isMobil
                  ? Column(
                      children: [
                        TeklifEkleNotVeAciklamaKarti(
                          notController: _notController,
                        ),
                        const SizedBox(height: 24),
                        TeklifToplamlarKarti(
                          araToplam: _getAraToplam(),
                          toplamIndirim: _getToplamIndirim(),
                          kdvHaricTutar: _getKdvHaricTutar(),
                          toplamKdv: _getToplamKdv(),
                          genelToplam: _getGenelToplam(),
                          doviz: _doviz,
                        ),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TeklifEkleNotVeAciklamaKarti(
                              notController: _notController,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: TeklifToplamlarKarti(
                              araToplam: _getAraToplam(),
                              toplamIndirim: _getToplamIndirim(),
                              kdvHaricTutar: _getKdvHaricTutar(),
                              toplamKdv: _getToplamKdv(),
                              genelToplam: _getGenelToplam(),
                              doviz: _doviz,
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
