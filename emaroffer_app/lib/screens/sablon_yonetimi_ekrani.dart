import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../services/api_service.dart';

class SablonYonetimiEkrani extends StatefulWidget {
  final Map<String, dynamic>? mevcutSablon;
  const SablonYonetimiEkrani({super.key, this.mevcutSablon});

  @override
  State<SablonYonetimiEkrani> createState() => _SablonYonetimiEkraniState();
}

class _SablonYonetimiEkraniState extends State<SablonYonetimiEkrani> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  int? _seciliSablonId;
  final TextEditingController _sablonAdiController = TextEditingController();

  Color _anaRenk = const Color(0xFF4F46E5);
  Color _ikinciRenk = const Color(0xFFF8FAFC);
  String _seciliYaziTipi = 'Inter';
  bool _logoGoster = true;

  List<String> _bloklar = [
    'BASLIK',
    'SIRKET',
    'MUSTERI',
    'TABLO',
    'NOTLAR',
    'TOPLAMLAR',
    'IMZA',
  ];

  Map<String, Map<String, dynamic>> _blokAyarlari = {};
  Map<String, Map<String, dynamic>> _pdfMetinleri = {};
  Map<String, dynamic> _genelAyarlar = {};

  final List<String> _desteklenenFontlar = [
    'Barlow',
    'Caveat',
    'Dancing Script',
    'Fira Sans',
    'Inconsolata',
    'Inter',
    'Josefin Sans',
    'Karla',
    'Lato',
    'Libre Baskerville',
    'Merriweather',
    'Montserrat',
    'Mukta',
    'Mulish',
    'Noto Sans',
    'Nunito',
    'Open Sans',
    'Oswald',
    'Pacifico',
    'Playfair Display',
    'Poppins',
    'PT Serif',
    'Quicksand',
    'Raleway',
    'Roboto',
    'Rubik',
    'Space Grotesk',
    'Titillium Web',
    'Ubuntu',
    'Work Sans',
  ];

  String _blokBasligiGetir(String key) {
    switch (key) {
      case 'BASLIK':
        return 'Firma Logosu / Başlık';
      case 'SIRKET':
        return 'Şirket Bilgileri';
      case 'MUSTERI':
        return 'Müşteri Bilgileri';
      case 'TABLO':
        return 'Ürün ve Fiyat Tablosu';
      case 'NOTLAR':
        return 'Şartlar ve Açıklamalar';
      case 'TOPLAMLAR':
        return 'Ara Toplam ve KDV';
      case 'IMZA':
        return 'Kaşe ve İmza Alanı';
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _metinleriSifirla();
    if (widget.mevcutSablon != null) {
      _sablonSec(widget.mevcutSablon);
    }
  }

  Map<String, dynamic> _varsayilanAyarOlustur() {
    return {
      'goster': true,
      'hizalama': 'sol',
      'boslukSol': 0.0,
      'boslukSag': 0.0,
      'boslukUst': 0.0,
      'boslukAlt': 20.0,
      'olcek': 1.0,
    };
  }

  Map<String, dynamic> _m(
    String metin,
    double boyut, {
    String weight = '400',
    String color = '#0F172A',
    String? font,
  }) {
    Map<String, dynamic> veri = {
      'm': metin,
      'b': boyut,
      'w': weight,
      'c': color,
    };
    if (font != null && font != 'Varsayılan') {
      veri['f'] = font;
    }
    return veri;
  }

  void _metinleriSifirla() {
    _genelAyarlar = {
      'sayfaBoslukSol': 40.0,
      'sayfaBoslukSag': 40.0,
      'sayfaBoslukUst': 40.0,
      'sayfaBoslukAlt': 40.0,
      'satirYuksekligi': 1.3,
    };

    _blokAyarlari = {
      'BASLIK': _varsayilanAyarOlustur(),
      'SIRKET': _varsayilanAyarOlustur(),
      'MUSTERI': _varsayilanAyarOlustur(),
      'TABLO': _varsayilanAyarOlustur(),
      'NOTLAR': _varsayilanAyarOlustur(),
      'IMZA': _varsayilanAyarOlustur(),
      'TOPLAMLAR': {
        'goster': true,
        'hizalama': 'sag',
        'boslukSol': 0.0,
        'boslukSag': 0.0,
        'boslukUst': 0.0,
        'boslukAlt': 20.0,
        'olcek': 1.0,
      },
    };

    _pdfMetinleri = {
      'sirketBilgi': _m(
        '[Şirket Adres Bilgileri]\n[Şirket İletişim Bilgileri]',
        10.0,
      ),
      'musteriUnvan': _m(
        '[Müşteri Unvanı]',
        13.0,
        weight: '700',
        color: '#4F46E5',
      ),
      'musteriBilgi': _m(
        '[Müşteri Adres ve İletişim Bilgileri]\n[Müşteri Vergi Bilgileri]',
        10.0,
      ),
      'tarih': _m('Düzenleme Tarihi: [Bugünün Tarihi]', 10.0),

      'kolon1': _m('SIRA', 9.0, weight: '700', color: '#FFFFFF'),
      'kolon2': _m(
        'ÜRÜN / HİZMET AÇIKLAMASI',
        9.0,
        weight: '700',
        color: '#FFFFFF',
      ),
      'kolon3': _m('MİKTAR', 9.0, weight: '700', color: '#FFFFFF'),
      'kolon4': _m('BİRİM FİYAT', 9.0, weight: '700', color: '#FFFFFF'),
      'kolon5': _m('İSK.', 9.0, weight: '700', color: '#FFFFFF'),
      'kolon6': _m('%KDV', 9.0, weight: '700', color: '#FFFFFF'),
      'kolon7': _m('TUTAR', 9.0, weight: '700', color: '#FFFFFF'),

      'satir1_1': _m('1', 9.0),
      'satir1_2': _m('[Ürün / Hizmet Kalemi]', 9.0),
      'satir1_3': _m('1 Adet', 9.0),
      'satir1_4': _m('1.500,00 ₺', 9.0),
      'satir1_5': _m('-', 9.0),
      'satir1_6': _m('%20', 9.0),
      'satir1_7': _m('1.500,00 ₺', 9.0, weight: '700'),

      'sartlarBaslik': _m(
        'TİCARİ ŞARTLAR VE NOTLAR',
        10.0,
        weight: '700',
        color: '#4F46E5',
      ),
      'sartlarIcerik': _m(
        '[Seçilen Ödeme Türü]\nTeklif Geçerlilik Tarihi: [Tarih]',
        9.0,
      ),
      'bankaBaslik': _m('Banka ve Hesap Bilgileri:', 9.0, weight: '700'),
      'altBilgiDeger': _m('[Ayarlardan Girilecek Alt Bilgi]', 9.0),

      'araToplam': _m('Ara Toplam', 10.0),
      'araToplamDeger': _m('3.500,00 ₺', 10.0),
      'indirim': _m('Toplam İndirim', 10.0, color: '#991B1B'),
      'indirimDeger': _m('-0,00 ₺', 10.0, color: '#991B1B'),
      'kdvHaric': _m('KDV Hariç Tutar', 10.0),
      'kdvHaricDeger': _m('3.500,00 ₺', 10.0),
      'kdv': _m('Toplam KDV', 10.0, color: '#4B5563'),
      'kdvDeger': _m('+700,00 ₺', 10.0, color: '#4B5563'),
      'genelToplamBaslik': _m('GENEL TOPLAM', 11.0, weight: '900'),
      'genelToplamDeger': _m('4.200,00 ₺', 11.0, weight: '900'),

      'imzaDuzenleyenBaslik': _m('TEKLİFİ DÜZENLEYEN', 10.0, weight: '700'),
      'imzaDuzenleyenIsim': _m('[Yetkili Kişi]', 10.0),
      'imzaDuzenleyenKase': _m('Kaşe / İmza', 9.0, color: '#4B5563'),
      'imzaMusteriBaslik': _m('MÜŞTERİ ONAYI', 10.0, weight: '700'),
      'imzaMusteriIsim': _m('[Müşteri Unvanı]', 10.0),
      'imzaMusteriKase': _m('Kaşe / İmza', 9.0, color: '#4B5563'),
    };
  }

  Color _hexToColor(String hexString) {
    int val = int.parse(hexString.replaceFirst('#', 'FF'), radix: 16);
    return Color.fromARGB(
      (val >> 24) & 0xFF,
      (val >> 16) & 0xFF,
      (val >> 8) & 0xFF,
      val & 0xFF,
    );
  }

  String _colorToHex(Color c) {
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _sablonSec(dynamic sablon) {
    setState(() {
      _seciliSablonId = sablon['Id'];
      _sablonAdiController.text = sablon['SablonAdi'] ?? '';
      _anaRenk = _hexToColor(sablon['AnaRenk'] ?? '#4F46E5');
      _ikinciRenk = _hexToColor(sablon['IkinciRenk'] ?? '#F8FAFC');

      _seciliYaziTipi = _desteklenenFontlar.contains(sablon['YaziTipi'])
          ? sablon['YaziTipi']
          : 'Inter';
      _logoGoster = sablon['LogoGoster'] ?? true;

      if (sablon['BlokSiralamasi'] != null &&
          sablon['BlokSiralamasi'].toString().isNotEmpty) {
        _bloklar = sablon['BlokSiralamasi'].toString().split(',');
        _bloklar.remove('LOGO');
      }

      if (sablon['BlokAyarlari'] != null &&
          sablon['BlokAyarlari'].toString().isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(
            sablon['BlokAyarlari'],
          );
          _blokAyarlari.clear();
          for (var entry in decoded.entries) {
            if (entry.key == 'GENEL_AYARLAR') {
              _genelAyarlar = Map<String, dynamic>.from(entry.value);
            } else if (entry.key == 'METIN_AYARLARI') {
              _pdfMetinleri = Map<String, Map<String, dynamic>>.from(
                entry.value.cast<String, Map<String, dynamic>>(),
              );
            } else {
              _blokAyarlari[entry.key] = Map<String, dynamic>.from(entry.value);
            }
          }
        } catch (e) {
          _metinleriSifirla();
        }
      }
    });
  }

  void _genelFontuDegistir(String yeniFont) {
    setState(() {
      _seciliYaziTipi = yeniFont;
      _pdfMetinleri.forEach((key, value) {
        value.remove('f');
      });
    });
  }

  Future<void> _kaydet({required bool yeniKayitGibiBas}) async {
    if (_sablonAdiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen şablona bir isim verin!',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    _blokAyarlari['GENEL_AYARLAR'] = _genelAyarlar;
    _blokAyarlari['METIN_AYARLARI'] = _pdfMetinleri;

    final veri = {
      'SablonAdi': _sablonAdiController.text,
      'AnaRenk': _colorToHex(_anaRenk),
      'IkinciRenk': _colorToHex(_ikinciRenk),
      'YaziTipi': _seciliYaziTipi,
      'LogoGoster': _logoGoster,
      'TabloTasarimi': 'OzelTasarim',
      'AltBilgiMetni': "",
      'BlokSiralamasi': _bloklar.join(','),
      'BlokAyarlari': jsonEncode(_blokAyarlari),
    };

    try {
      if (_seciliSablonId == null || yeniKayitGibiBas) {
        await _apiService.createSablon(veri);
      } else {
        await _apiService.updateSablon(_seciliSablonId!, veri);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      _blokAyarlari.remove('GENEL_AYARLAR');
      _blokAyarlari.remove('METIN_AYARLARI');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _renkSeciciAc(bool isAnaRenk) {
    Color geciciRenk = isAnaRenk ? _anaRenk : _ikinciRenk;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isAnaRenk ? 'Ana Rengi Seçin' : 'Tablo Rengi Seçin',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: geciciRenk,
              onColorChanged: (Color color) => geciciRenk = color,
              enableAlpha: false,
              labelTypes: const [ColorLabelType.hex],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
              ),
              child: const Text(
                'Uygula',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(
                  () => isAnaRenk
                      ? _anaRenk = geciciRenk
                      : _ikinciRenk = geciciRenk,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  TextStyle _getFont({
    double fontSize = 12,
    String weightStr = '400',
    Color color = Colors.black87,
    String? specificFont,
  }) {
    FontWeight fw = FontWeight.w400;
    if (weightStr == '300') fw = FontWeight.w300;
    if (weightStr == '500') fw = FontWeight.w500;
    if (weightStr == '700') fw = FontWeight.w700;
    if (weightStr == '900') fw = FontWeight.w900;

    double lineHeight = (_genelAyarlar['satirYuksekligi'] ?? 1.3).toDouble();
    String fontIsmi =
        (specificFont != null &&
            specificFont.isNotEmpty &&
            specificFont != 'Varsayılan')
        ? specificFont
        : _seciliYaziTipi;

    try {
      return GoogleFonts.getFont(
        fontIsmi,
        fontSize: fontSize,
        fontWeight: fw,
        color: color,
        height: lineHeight,
      );
    } catch (e) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fw,
        color: color,
        height: lineHeight,
      );
    }
  }

  Widget _ayarlanabilirMetin(
    String anahtar, {
    TextAlign textAlign = TextAlign.left,
  }) {
    final metinVerisi = _pdfMetinleri[anahtar]!;
    Color yaziRengi = _hexToColor(metinVerisi['c'] ?? '#0F172A');

    return InkWell(
      onTap: () => _yaziDuzenleDialogAc(anahtar),
      child: Text(
        metinVerisi['m'],
        style: _getFont(
          fontSize: metinVerisi['b'],
          weightStr: metinVerisi['w'] ?? '400',
          color: yaziRengi,
          specificFont: metinVerisi['f'],
        ),
        textAlign: textAlign,
      ),
    );
  }

  Future<void> _yaziDuzenleDialogAc(String anahtar) async {
    final mevcutVeri = _pdfMetinleri[anahtar]!;
    TextEditingController controller = TextEditingController(
      text: mevcutVeri['m'],
    );
    double geciciBoyut = mevcutVeri['b'];
    String geciciKalinlik = mevcutVeri['w'] ?? '400';
    Color geciciYaziRengi = _hexToColor(mevcutVeri['c'] ?? '#0F172A');
    String geciciFont = mevcutVeri['f'] ?? 'Varsayılan';
    List<String> dialogFontlari = ['Varsayılan', ..._desteklenenFontlar];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Metin ve Görünüm Düzenle",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'İçerik (Yer tutucu olabilir)',
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Yazı Tipi (Font)",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: ValueKey(geciciFont),
                        initialValue: dialogFontlari.contains(geciciFont)
                            ? geciciFont
                            : 'Varsayılan',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: dialogFontlari.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text(
                              f,
                              style: f == 'Varsayılan'
                                  ? GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    )
                                  : GoogleFonts.getFont(f, fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setStateDialog(() => geciciFont = v!),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Yazı Kalınlığı",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  key: ValueKey(geciciKalinlik),
                                  initialValue: geciciKalinlik,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: '300',
                                      child: Text('İnce'),
                                    ),
                                    DropdownMenuItem(
                                      value: '400',
                                      child: Text('Normal'),
                                    ),
                                    DropdownMenuItem(
                                      value: '500',
                                      child: Text('Orta'),
                                    ),
                                    DropdownMenuItem(
                                      value: '700',
                                      child: Text('Kalın'),
                                    ),
                                    DropdownMenuItem(
                                      value: '900',
                                      child: Text('Ekstra Kalın'),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setStateDialog(() => geciciKalinlik = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Metin Rengi",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text(
                                          'Metin Rengini Seçin',
                                        ),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: geciciYaziRengi,
                                            onColorChanged: (Color color) =>
                                                setStateDialog(
                                                  () => geciciYaziRengi = color,
                                                ),
                                            enableAlpha: false,
                                            labelTypes: const [
                                              ColorLabelType.hex,
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Tamam'),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: geciciYaziRengi,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Renk Seç",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Boyut: ${geciciBoyut.toInt()}px",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Slider(
                        value: geciciBoyut,
                        min: 6.0,
                        max: 48.0,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: (val) =>
                            setStateDialog(() => geciciBoyut = val),
                      ),
                    ],
                  ),
                ),
              ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _pdfMetinleri[anahtar]!['m'] = controller.text;
                      _pdfMetinleri[anahtar]!['b'] = geciciBoyut;
                      _pdfMetinleri[anahtar]!['w'] = geciciKalinlik;
                      _pdfMetinleri[anahtar]!['c'] = _colorToHex(
                        geciciYaziRengi,
                      );
                      if (geciciFont == 'Varsayılan') {
                        _pdfMetinleri[anahtar]!.remove('f');
                      } else {
                        _pdfMetinleri[anahtar]!['f'] = geciciFont;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Uygula",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _canliBlokSarmalayici(Widget icerik, String blokKey) {
    final ayar = _blokAyarlari[blokKey] ?? _varsayilanAyarOlustur();
    if (ayar['goster'] == false) {
      return const SizedBox.shrink();
    }

    Alignment alignment = Alignment.centerLeft;
    if (ayar['hizalama'] == 'orta') alignment = Alignment.center;
    if (ayar['hizalama'] == 'sag') alignment = Alignment.centerRight;

    return Padding(
      padding: EdgeInsets.only(
        left: (ayar['boslukSol'] ?? 0.0).toDouble(),
        right: (ayar['boslukSag'] ?? 0.0).toDouble(),
        top: (ayar['boslukUst'] ?? 0.0).toDouble(),
        bottom: (ayar['boslukAlt'] ?? 20.0).toDouble(),
      ),
      child: Align(
        alignment: alignment,
        child: Transform.scale(
          scale: (ayar['olcek'] ?? 1.0).toDouble(),
          alignment: alignment,
          child: icerik,
        ),
      ),
    );
  }

  Future<void> _genelAyarlariDialogAc() async {
    Map<String, dynamic> tempAyarlar = Map.from(_genelAyarlar);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Genel Sayfa Ayarları",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: StatefulBuilder(
          builder: (ctx, setS) => SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Satır Yüksekliği: ${tempAyarlar['satirYuksekligi'].toStringAsFixed(1)}x",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (tempAyarlar['satirYuksekligi'] ?? 1.3).toDouble(),
                    min: 1.0,
                    max: 2.5,
                    divisions: 15,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) =>
                        setS(() => tempAyarlar['satirYuksekligi'] = v),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 32),
                  Text(
                    "Sol Boşluk: ${(tempAyarlar['sayfaBoslukSol'] ?? 40).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (tempAyarlar['sayfaBoslukSol'] ?? 40.0).toDouble(),
                    min: 0,
                    max: 150,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) =>
                        setS(() => tempAyarlar['sayfaBoslukSol'] = v),
                  ),
                  Text(
                    "Sağ Boşluk: ${(tempAyarlar['sayfaBoslukSag'] ?? 40).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (tempAyarlar['sayfaBoslukSag'] ?? 40.0).toDouble(),
                    min: 0,
                    max: 150,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) =>
                        setS(() => tempAyarlar['sayfaBoslukSag'] = v),
                  ),
                  Text(
                    "Üst Boşluk: ${(tempAyarlar['sayfaBoslukUst'] ?? 40).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (tempAyarlar['sayfaBoslukUst'] ?? 40.0).toDouble(),
                    min: 0,
                    max: 150,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) =>
                        setS(() => tempAyarlar['sayfaBoslukUst'] = v),
                  ),
                  Text(
                    "Alt Boşluk: ${(tempAyarlar['sayfaBoslukAlt'] ?? 40).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (tempAyarlar['sayfaBoslukAlt'] ?? 40.0).toDouble(),
                    min: 0,
                    max: 150,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) =>
                        setS(() => tempAyarlar['sayfaBoslukAlt'] = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "İptal",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() => _genelAyarlar = tempAyarlar);
              Navigator.pop(ctx);
            },
            child: Text(
              "Uygula",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }
    final bool isMobil = MediaQuery.of(context).size.width < 1100;

    Widget solPanelArayuzu = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Color(0xFF4F46E5), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Metinleri, boyutları ve renkleri değiştirmek için önizleme üzerinde yazılara tıklayın.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF3730A3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _sablonAdiController,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Şablon İsmi',
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            initiallyExpanded: true,
            title: Text(
              "Görünüm ve Tasarım",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(_seciliYaziTipi),
                initialValue: _desteklenenFontlar.contains(_seciliYaziTipi)
                    ? _seciliYaziTipi
                    : 'Inter',
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                ),
                decoration: InputDecoration(
                  labelText: "Yazı Tipi (Font)",
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                  ),
                ),
                items: _desteklenenFontlar.map((fontAdi) {
                  return DropdownMenuItem(
                    value: fontAdi,
                    child: Text(
                      fontAdi,
                      style: GoogleFonts.getFont(
                        fontAdi,
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _genelFontuDegistir(val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _renkButonu(
                      "Ana Renk",
                      _anaRenk,
                      () => _renkSeciciAc(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _renkButonu(
                      "Tablo",
                      _ikinciRenk,
                      () => _renkSeciciAc(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  "Firma Logosunu Göster",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF4F46E5),
                value: _logoGoster,
                onChanged: (v) => setState(() => _logoGoster = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          ExpansionTile(
            title: Text(
              "Düzen ve Hizalama",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _genelAyarlariDialogAc,
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: Text(
                    "Genel Sayfa Margini & Satır Aralığı",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Blok Sıralaması (Sürükle-Bırak)",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              _buildBlokListesi(),
            ],
          ),
        ],
      ),
    );

    Widget sagPanelArayuzu = Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: InteractiveViewer(
          minScale: 0.2,
          maxScale: 3.0,
          boundaryMargin: const EdgeInsets.all(80),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 595,
              constraints: const BoxConstraints(minHeight: 842),
              padding: EdgeInsets.fromLTRB(
                (_genelAyarlar['sayfaBoslukSol'] ?? 40.0).toDouble(),
                (_genelAyarlar['sayfaBoslukUst'] ?? 40.0).toDouble(),
                (_genelAyarlar['sayfaBoslukSag'] ?? 40.0).toDouble(),
                (_genelAyarlar['sayfaBoslukAlt'] ?? 40.0).toDouble(),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 20),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _bloklar
                    .map((b) => _canliBlokSarmalayici(_getBlokWidget(b), b))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "PDF Tasarım Editörü",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _kaydet(yeniKayitGibiBas: false),
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: Text(
                'Kaydet',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isMobil
          ? DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: const TabBar(
                      labelColor: Color(0xFF4F46E5),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF4F46E5),
                      tabs: [
                        Tab(icon: Icon(Icons.settings), text: "Ayarlar"),
                        Tab(icon: Icon(Icons.picture_as_pdf), text: "Önizleme"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [solPanelArayuzu, sagPanelArayuzu],
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Expanded(flex: 3, child: solPanelArayuzu),
                Expanded(flex: 7, child: sagPanelArayuzu),
              ],
            ),
    );
  }

  Widget _getBlokWidget(String k) {
    switch (k) {
      case 'BASLIK':
        return _logoGoster
            ? Icon(Icons.business, size: 50, color: _anaRenk)
            : const SizedBox.shrink();
      case 'SIRKET':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ayarlanabilirMetin('sirketBilgi'),
            const SizedBox(height: 16),
            Divider(color: _anaRenk, thickness: 1.5),
          ],
        );
      case 'MUSTERI':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ayarlanabilirMetin('musteriUnvan'),
            const SizedBox(height: 4),
            _ayarlanabilirMetin('musteriBilgi'),
          ],
        );
      case 'TABLO':
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: _anaRenk)),
          child: Column(
            children: [
              Container(
                color: _anaRenk,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _ayarlanabilirMetin('kolon1')),
                    Expanded(flex: 4, child: _ayarlanabilirMetin('kolon2')),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'kolon3',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'kolon4',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'kolon5',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'kolon6',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'kolon7',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: _ikinciRenk,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _ayarlanabilirMetin('satir1_1')),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(child: _ayarlanabilirMetin('satir1_2')),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'satir1_3',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'satir1_4',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'satir1_5',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'satir1_6',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ayarlanabilirMetin(
                        'satir1_7',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'TOPLAMLAR':
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ayarlanabilirMetin('araToplam'),
                    _ayarlanabilirMetin(
                      'araToplamDeger',
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ayarlanabilirMetin('indirim'),
                    _ayarlanabilirMetin(
                      'indirimDeger',
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ayarlanabilirMetin('kdvHaric'),
                    _ayarlanabilirMetin(
                      'kdvHaricDeger',
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ayarlanabilirMetin('kdv'),
                    _ayarlanabilirMetin('kdvDeger', textAlign: TextAlign.right),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ayarlanabilirMetin('genelToplamBaslik'),
                    _ayarlanabilirMetin(
                      'genelToplamDeger',
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      case 'NOTLAR':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ayarlanabilirMetin('sartlarBaslik'),
            const SizedBox(height: 8),
            _ayarlanabilirMetin('tarih'),
            const SizedBox(height: 2),
            _ayarlanabilirMetin('sartlarIcerik'),
            const SizedBox(height: 8),
            _ayarlanabilirMetin('bankaBaslik'),
            _ayarlanabilirMetin('altBilgiDeger'),
          ],
        );
      case 'IMZA':
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _ayarlanabilirMetin('imzaDuzenleyenBaslik'),
                  const SizedBox(height: 6),
                  _ayarlanabilirMetin('imzaDuzenleyenIsim'),
                  const SizedBox(height: 40),
                  _ayarlanabilirMetin('imzaDuzenleyenKase'),
                ],
              ),
              Column(
                children: [
                  _ayarlanabilirMetin('imzaMusteriBaslik'),
                  const SizedBox(height: 6),
                  _ayarlanabilirMetin('imzaMusteriIsim'),
                  const SizedBox(height: 40),
                  _ayarlanabilirMetin('imzaMusteriKase'),
                ],
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _renkButonu(String t, Color c, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlokListesi() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorder: (o, n) => setState(() {
          if (n > o) n -= 1;
          final item = _bloklar.removeAt(o);
          _bloklar.insert(n, item);
        }),
        children: _bloklar.asMap().entries.map((entry) {
          int index = entry.key;
          String b = entry.value;
          return Container(
            key: ValueKey(b),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(
                  Icons.drag_indicator_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              title: Text(
                _blokBasligiGetir(b),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                onPressed: () => _blokAyarlariDialogAc(b),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              dense: true,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _hizalamaButonu(
    IconData icon,
    String deger,
    String secili,
    VoidCallback onTap,
  ) {
    bool isSelected = deger == secili;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Future<void> _blokAyarlariDialogAc(String blokKey) async {
    Map<String, dynamic> ayar = Map.from(
      _blokAyarlari[blokKey] ?? _varsayilanAyarOlustur(),
    );
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "${_blokBasligiGetir(blokKey)} Ayarları",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: StatefulBuilder(
          builder: (ctx, setS) => SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(
                      "Bu Bölümü Göster",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF4F46E5),
                    value: ayar['goster'],
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setS(() => ayar['goster'] = v),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 16),

                  Text(
                    "Hizalama Yönü",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _hizalamaButonu(
                        Icons.align_horizontal_left,
                        'sol',
                        ayar['hizalama'] ?? 'sol',
                        () => setS(() => ayar['hizalama'] = 'sol'),
                      ),
                      const SizedBox(width: 8),
                      _hizalamaButonu(
                        Icons.align_horizontal_center,
                        'orta',
                        ayar['hizalama'] ?? 'sol',
                        () => setS(() => ayar['hizalama'] = 'orta'),
                      ),
                      const SizedBox(width: 8),
                      _hizalamaButonu(
                        Icons.align_horizontal_right,
                        'sag',
                        ayar['hizalama'] ?? 'sol',
                        () => setS(() => ayar['hizalama'] = 'sag'),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 32),

                  Text(
                    "Sol Boşluk: ${(ayar['boslukSol'] ?? 0).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (ayar['boslukSol'] ?? 0.0).toDouble(),
                    min: 0,
                    max: 400,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) => setS(() => ayar['boslukSol'] = v),
                  ),
                  Text(
                    "Sağ Boşluk: ${(ayar['boslukSag'] ?? 0).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (ayar['boslukSag'] ?? 0.0).toDouble(),
                    min: 0,
                    max: 400,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) => setS(() => ayar['boslukSag'] = v),
                  ),
                  Text(
                    "Üst Boşluk: ${(ayar['boslukUst'] ?? 0).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (ayar['boslukUst'] ?? 0.0).toDouble(),
                    min: 0,
                    max: 300,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) => setS(() => ayar['boslukUst'] = v),
                  ),
                  Text(
                    "Alt Boşluk: ${(ayar['boslukAlt'] ?? 20).toInt()}px",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (ayar['boslukAlt'] ?? 20.0).toDouble(),
                    min: 0,
                    max: 300,
                    activeColor: const Color(0xFF4F46E5),
                    onChanged: (v) => setS(() => ayar['boslukAlt'] = v),
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 32),
                  Text(
                    "Büyüklük (Ölçek): %${((ayar['olcek'] ?? 1.0) * 100).toInt()}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Slider(
                    value: (ayar['olcek'] ?? 1.0).toDouble(),
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setS(() => ayar['olcek'] = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "İptal",
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() => _blokAyarlari[blokKey] = ayar);
              Navigator.pop(ctx);
            },
            child: Text(
              "Uygula",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
