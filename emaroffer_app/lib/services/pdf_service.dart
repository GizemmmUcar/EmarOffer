import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/teklif_satiri_model.dart';

class PdfService {
  static const PdfColor _textColor = PdfColor.fromInt(0xFF1F2937);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFD1D5DB);

  static const Map<String, Map<String, String>> _ceviri = {
    'TR': {
      'sayfa': 'Sayfa',
      'footer': 'Bu belge mali ve ticari nitelik taşımaktadır.',
    },
    'EN': {
      'sayfa': 'Page',
      'footer': 'This document is of a financial and commercial nature.',
      'SIRA': '#',
      'ÜRÜN / HİZMET AÇIKLAMASI': 'PRODUCT / SERVICE',
      'MİKTAR': 'QTY',
      'BİRİM FİYAT': 'UNIT PRICE',
      'İSK.': 'DISC.',
      '%KDV': 'VAT%',
      'TUTAR': 'AMOUNT',
      'Ara Toplam': 'Subtotal',
      'Toplam İndirim': 'Total Discount',
      'KDV Hariç Tutar': 'Amount excl. VAT',
      'Toplam KDV': 'Total VAT',
      'GENEL TOPLAM': 'GRAND TOTAL',
      'TİCARİ ŞARTLAR VE NOTLAR': 'TERMS AND CONDITIONS',
      'Banka ve Hesap Bilgileri:': 'Bank & Account Details:',
      'TEKLİFİ DÜZENLEYEN': 'ISSUED BY',
      'MÜŞTERİ ONAYI': 'CUSTOMER APPROVAL',
      'Kaşe / İmza': 'Stamp / Signature',
    },
  };

  static PdfColor _hexToPdfColor(String? hexString, PdfColor fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      String hex = hexString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return PdfColor.fromInt(int.parse(hex, radix: 16));
    } catch (e) {
      return fallback;
    }
  }

  static Future<pw.Font> _dinamikFontGetir(
    String fontIsmi, {
    bool isBold = false,
  }) async {
    switch (fontIsmi) {
      case 'Barlow':
        return isBold
            ? await PdfGoogleFonts.barlowBold()
            : await PdfGoogleFonts.barlowRegular();
      case 'Caveat':
        return isBold
            ? await PdfGoogleFonts.caveatBold()
            : await PdfGoogleFonts.caveatRegular();
      case 'Dancing Script':
        return isBold
            ? await PdfGoogleFonts.dancingScriptBold()
            : await PdfGoogleFonts.dancingScriptRegular();
      case 'Lato':
        return isBold
            ? await PdfGoogleFonts.latoBold()
            : await PdfGoogleFonts.latoRegular();
      case 'Montserrat':
        return isBold
            ? await PdfGoogleFonts.montserratBold()
            : await PdfGoogleFonts.montserratRegular();
      case 'Open Sans':
        return isBold
            ? await PdfGoogleFonts.openSansBold()
            : await PdfGoogleFonts.openSansRegular();
      case 'Poppins':
        return isBold
            ? await PdfGoogleFonts.poppinsBold()
            : await PdfGoogleFonts.poppinsRegular();
      case 'Roboto':
        return isBold
            ? await PdfGoogleFonts.robotoBold()
            : await PdfGoogleFonts.robotoRegular();
      case 'Ubuntu':
        return isBold
            ? await PdfGoogleFonts.ubuntuBold()
            : await PdfGoogleFonts.ubuntuRegular();
      default:
        return isBold
            ? await PdfGoogleFonts.interBold()
            : await PdfGoogleFonts.interRegular();
    }
  }

  static pw.Widget? _sarmala(
    pw.Widget? icerik,
    String blokKey,
    Map<String, dynamic> tumAyarlar,
  ) {
    if (icerik == null) return null;
    final ayar =
        tumAyarlar[blokKey] ??
        {
          'goster': true,
          'hizalama': 'sol',
          'boslukSol': 0.0,
          'boslukSag': 0.0,
          'boslukUst': 0.0,
          'boslukAlt': 20.0,
          'olcek': 1.0,
        };
    if (ayar['goster'] == false) return null;

    pw.Alignment alignment = pw.Alignment.topLeft;
    if (ayar['hizalama'] == 'orta') alignment = pw.Alignment.topCenter;
    if (ayar['hizalama'] == 'sag') alignment = pw.Alignment.topRight;

    return pw.Padding(
      padding: pw.EdgeInsets.only(
        left: (ayar['boslukSol'] ?? 0.0).toDouble(),
        right: (ayar['boslukSag'] ?? 0.0).toDouble(),
        top: (ayar['boslukUst'] ?? 0.0).toDouble(),
        bottom: (ayar['boslukAlt'] ?? 20.0).toDouble(),
      ),
      child: pw.Align(
        alignment: alignment,
        child: pw.Transform.scale(
          scale: (ayar['olcek'] ?? 1.0).toDouble(),
          child: icerik,
        ),
      ),
    );
  }

  static pw.Widget _dinamikMetin(
    String anahtar,
    Map<String, dynamic> metinAyarlari,
    pw.Font fontRegular,
    pw.Font fontBold,
    String gercekDeger,
    String dil, {
    pw.TextAlign textAlign = pw.TextAlign.left,
  }) {
    final ayar = metinAyarlari[anahtar] ?? {};
    final double boyut = (ayar['b'] ?? 10.0).toDouble();
    final String kalinlik = ayar['w'] ?? '400';
    final String hexRenk = ayar['c'] ?? '#0F172A';

    pw.Font seciliFont = (kalinlik == '700' || kalinlik == '900')
        ? fontBold
        : fontRegular;
    PdfColor yaziRengi = _hexToPdfColor(hexRenk, _textColor);

    String gosterilecekMetin = gercekDeger;
    if (dil == 'EN' && _ceviri['EN']!.containsKey(gercekDeger)) {
      gosterilecekMetin = _ceviri['EN']![gercekDeger]!;
    }

    return pw.Text(
      gosterilecekMetin,
      style: pw.TextStyle(font: seciliFont, fontSize: boyut, color: yaziRengi),
      textAlign: textAlign,
    );
  }

  static Future<Uint8List> teklifPdfOlustur({
    required Map<String, dynamic> teklif,
    required List<dynamic> urunler,
    required Map<String, dynamic> sirket,
    String dil = 'TR',
    Map<String, dynamic>? sablon,
  }) async {
    final pdf = pw.Document();
    final t = _ceviri[dil] ?? _ceviri['TR']!;

    Map<String, dynamic> blokAyarlari = {};
    Map<String, dynamic> genelAyarlar = {
      'sayfaBoslukSol': 40.0,
      'sayfaBoslukSag': 40.0,
      'sayfaBoslukUst': 40.0,
      'sayfaBoslukAlt': 40.0,
      'satirYuksekligi': 1.3,
    };
    Map<String, dynamic> metinAyarlari = {};
    List<String> blokSiralamasi = [
      'BASLIK',
      'SIRKET',
      'MUSTERI',
      'TABLO',
      'NOTLAR',
      'TOPLAMLAR',
      'IMZA',
    ];

    if (sablon != null) {
      if (sablon['BlokSiralamasi'] != null) {
        blokSiralamasi = sablon['BlokSiralamasi'].toString().split(',');
      }
      if (sablon['BlokAyarlari'] != null) {
        try {
          final decoded = jsonDecode(sablon['BlokAyarlari']);
          decoded.forEach((k, v) {
            if (k == 'GENEL_AYARLAR') {
              genelAyarlar = Map<String, dynamic>.from(v);
            } else if (k == 'METIN_AYARLARI') {
              metinAyarlari = Map<String, dynamic>.from(v);
            } else {
              blokAyarlari[k] = Map<String, dynamic>.from(v);
            }
          });
        } catch (_) {}
      }
    }

    PdfColor pColor = _hexToPdfColor(
      sablon?['AnaRenk']?.toString(),
      PdfColor.fromInt(0xFF4F46E5),
    );
    PdfColor sColor = _hexToPdfColor(
      sablon?['IkinciRenk']?.toString(),
      PdfColor.fromInt(0xFFF8FAFC),
    );

    String fontIsmi = sablon?['YaziTipi'] ?? 'Inter';
    bool logoGoster = sablon?['LogoGoster'] ?? true;
    double satirYuksekligi = (genelAyarlar['satirYuksekligi'] ?? 1.3)
        .toDouble();

    final fontRegular = await _dinamikFontGetir(fontIsmi);
    final fontBold = await _dinamikFontGetir(fontIsmi, isBold: true);

    final String doviz = teklif["Doviz"]?.toString() ?? "TRY";
    DateTime tarihObj =
        DateTime.tryParse(teklif["OlusturmaTarihi"]?.toString() ?? "") ??
        DateTime.now();
    final String formatliTarih =
        "${tarihObj.day.toString().padLeft(2, '0')}.${tarihObj.month.toString().padLeft(2, '0')}.${tarihObj.year}";
    DateTime bitisObj = tarihObj.add(
      Duration(days: teklif["GecerlilikGunu"] ?? 7),
    );
    final String gecerlilikTarihi =
        "${bitisObj.day.toString().padLeft(2, '0')}.${bitisObj.month.toString().padLeft(2, '0')}.${bitisObj.year}";

    final firmaAdi = teklif["FirmaAdi"]?.toString() ?? "MÜŞTERİ";
    final sirketAdres = sirket["Adres"]?.toString() ?? "";
    final sirketIletisim =
        "${sirket["Telefon"] ?? ""}  |  ${sirket["Eposta"] ?? ""}";
    final musteriIletisim =
        "${teklif["Adres"] ?? ""}\n${teklif["Telefon"] ?? ""}  |  ${teklif["Eposta"] ?? ""}";
    final musteriVergi =
        "V.Dairesi: ${teklif["VergiDairesi"] ?? "-"}  |  V.No: ${teklif["VergiNo"] ?? "-"}";

    String veriyiDoldur(String anahtar, String varsayilan) {
      String hamMetin = metinAyarlari[anahtar]?['m'] ?? varsayilan;
      return hamMetin
          .replaceAll('[Şirket Adres Bilgileri]', sirketAdres)
          .replaceAll('[Şirket İletişim Bilgileri]', sirketIletisim)
          .replaceAll('[Müşteri Unvanı]', firmaAdi)
          .replaceAll('[Müşteri Adres ve İletişim Bilgileri]', musteriIletisim)
          .replaceAll('[Müşteri Vergi Bilgileri]', musteriVergi)
          .replaceAll('[Bugünün Tarihi]', formatliTarih)
          .replaceAll('[Seçilen Ödeme Türü]', teklif["OdemeTuru"] ?? "Nakit")
          .replaceAll('[Tarih]', gecerlilikTarihi)
          .replaceAll(
            '[Ayarlardan Girilecek Alt Bilgi]',
            sirket["BankaBilgileri"] ?? "",
          )
          .replaceAll('[Yetkili Kişi]', sirket["Yetkili"]?.toString() ?? "");
    }

    final List<TeklifSatiri> satirlar = urunler
        .map((u) => TeklifSatiri.fromJson(u))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.fromLTRB(
          (genelAyarlar['sayfaBoslukSol'] ?? 40.0).toDouble(),
          (genelAyarlar['sayfaBoslukUst'] ?? 40.0).toDouble(),
          (genelAyarlar['sayfaBoslukSag'] ?? 40.0).toDouble(),
          (genelAyarlar['sayfaBoslukAlt'] ?? 40.0).toDouble(),
        ),
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
            font: fontRegular,
            color: _textColor,
            fontSize: 10,
            lineSpacing: (satirYuksekligi - 1.0) * 10,
          ),
        ),
        footer: (context) => _buildFooter(
          context.pageNumber,
          context.pagesCount,
          t,
          _borderColor,
        ),
        build: (context) {
          List<pw.Widget> pdfIcerigi = [];
          for (var blok in blokSiralamasi) {
            pw.Widget? safIcerik;
            switch (blok) {
              case 'BASLIK':
                final String logoBase64 = sirket["Logo"]?.toString() ?? "";
                safIcerik = (logoGoster && logoBase64.isNotEmpty)
                    ? pw.Container(
                        height: 45,
                        child: pw.Image(
                          pw.MemoryImage(base64Decode(logoBase64)),
                          fit: pw.BoxFit.contain,
                        ),
                      )
                    : pw.SizedBox.shrink();
                break;
              case 'SIRKET':
                safIcerik = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _dinamikMetin(
                      'sirketBilgi',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur(
                        'sirketBilgi',
                        '$sirketAdres\n$sirketIletisim',
                      ),
                      dil,
                    ),
                    pw.SizedBox(height: 16),
                    pw.Divider(color: pColor, thickness: 1.5),
                  ],
                );
                break;
              case 'MUSTERI':
                safIcerik = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _dinamikMetin(
                      'musteriUnvan',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur('musteriUnvan', firmaAdi.toUpperCase()),
                      dil,
                    ),
                    pw.SizedBox(height: 4),
                    _dinamikMetin(
                      'musteriBilgi',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur(
                        'musteriBilgi',
                        '$musteriIletisim\n$musteriVergi',
                      ),
                      dil,
                    ),
                  ],
                );
                break;
              case 'TABLO':
                safIcerik = _buildUrunlerTablosu(
                  satirlar,
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  doviz,
                  pColor,
                  sColor,
                  dil,
                  urunler,
                );
                break;
              case 'NOTLAR':
                safIcerik = pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _dinamikMetin(
                      'sartlarBaslik',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur('sartlarBaslik', 'TİCARİ ŞARTLAR VE NOTLAR'),
                      dil,
                    ),
                    pw.SizedBox(height: 8),
                    _dinamikMetin(
                      'tarih',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur(
                        'tarih',
                        dil == 'EN'
                            ? 'Issue Date: $formatliTarih'
                            : 'Düzenleme Tarihi: $formatliTarih',
                      ),
                      dil,
                    ),
                    pw.SizedBox(height: 2),
                    _dinamikMetin(
                      'sartlarIcerik',
                      metinAyarlari,
                      fontRegular,
                      fontBold,
                      veriyiDoldur(
                        'sartlarIcerik',
                        dil == 'EN'
                            ? 'Payment Method: ${teklif["OdemeTuru"]}\nValid Until: $gecerlilikTarihi'
                            : 'Ödeme Türü: ${teklif["OdemeTuru"]}\nGeçerlilik: $gecerlilikTarihi',
                      ),
                      dil,
                    ),
                    if (sirket["BankaBilgileri"] != null) ...[
                      pw.SizedBox(height: 8),
                      _dinamikMetin(
                        'bankaBaslik',
                        metinAyarlari,
                        fontRegular,
                        fontBold,
                        veriyiDoldur(
                          'bankaBaslik',
                          'Banka ve Hesap Bilgileri:',
                        ),
                        dil,
                      ),
                      _dinamikMetin(
                        'altBilgiDeger',
                        metinAyarlari,
                        fontRegular,
                        fontBold,
                        veriyiDoldur('altBilgiDeger', sirket["BankaBilgileri"]),
                        dil,
                      ),
                    ],
                  ],
                );
                break;
              case 'TOPLAMLAR':
                safIcerik = pw.Container(
                  width: 280,
                  child: _buildToplamlar(
                    satirlar,
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    doviz,
                    dil,
                  ),
                );
                break;
              case 'IMZA':
                safIcerik = pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        _dinamikMetin(
                          'imzaDuzenleyenBaslik',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          dil == 'EN' ? "ISSUED BY" : "TEKLİFİ DÜZENLEYEN",
                          dil,
                        ),
                        pw.SizedBox(height: 6),
                        _dinamikMetin(
                          'imzaDuzenleyenIsim',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          veriyiDoldur(
                            'imzaDuzenleyenIsim',
                            sirket["Yetkili"] ?? "",
                          ),
                          dil,
                        ),
                        pw.SizedBox(height: 40),
                        _dinamikMetin(
                          'imzaDuzenleyenKase',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          dil == 'EN' ? "Stamp / Signature" : "Kaşe / İmza",
                          dil,
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        _dinamikMetin(
                          'imzaMusteriBaslik',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          dil == 'EN' ? "CUSTOMER APPROVAL" : "MÜŞTERİ ONAYI",
                          dil,
                        ),
                        pw.SizedBox(height: 6),
                        _dinamikMetin(
                          'imzaMusteriIsim',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          veriyiDoldur('imzaMusteriIsim', firmaAdi),
                          dil,
                        ),
                        pw.SizedBox(height: 40),
                        _dinamikMetin(
                          'imzaMusteriKase',
                          metinAyarlari,
                          fontRegular,
                          fontBold,
                          dil == 'EN' ? "Stamp / Signature" : "Kaşe / İmza",
                          dil,
                        ),
                      ],
                    ),
                  ],
                );
                break;
            }
            final sarmalanmisBlok = _sarmala(safIcerik, blok, blokAyarlari);
            if (sarmalanmisBlok != null) pdfIcerigi.add(sarmalanmisBlok);
          }
          return pdfIcerigi;
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildUrunlerTablosu(
    List<TeklifSatiri> satirlar,
    Map<String, dynamic> metinAyarlari,
    pw.Font fontRegular,
    pw.Font fontBold,
    String doviz,
    PdfColor pColor,
    PdfColor sColor,
    String dil,
    List<dynamic> hamUrunler,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pColor),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Center(
                child: _dinamikMetin(
                  'kolon1',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'SIRA',
                  dil,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: _dinamikMetin(
                'kolon2',
                metinAyarlari,
                fontRegular,
                fontBold,
                'ÜRÜN / HİZMET AÇIKLAMASI',
                dil,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Center(
                child: _dinamikMetin(
                  'kolon3',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'MİKTAR',
                  dil,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Center(
                child: _dinamikMetin(
                  'kolon4',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'BİRİM FİYAT',
                  dil,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Center(
                child: _dinamikMetin(
                  'kolon5',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'İSK.',
                  dil,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Center(
                child: _dinamikMetin(
                  'kolon6',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  '%KDV',
                  dil,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: _dinamikMetin(
                  'kolon7',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'TUTAR',
                  dil,
                ),
              ),
            ),
          ],
        ),
        ...List.generate(satirlar.length, (index) {
          final satir = satirlar[index];
          final hamUrun = hamUrunler.length > index ? hamUrunler[index] : {};
          String? ilkGorsel;
          var rawGorsel =
              hamUrun["UrunGorsel"] ??
              (hamUrun["Urun"] != null ? hamUrun["Urun"]["UrunGorsel"] : null);
          if (rawGorsel != null && rawGorsel.toString().isNotEmpty) {
            String rg = rawGorsel.toString();
            if (rg.trimLeft().startsWith('[')) {
              try {
                List<dynamic> dec = jsonDecode(rg);
                if (dec.isNotEmpty) {
                  ilkGorsel = dec.first.toString();
                }
              } catch (_) {
                ilkGorsel = rg;
              }
            } else {
              ilkGorsel = rg;
            }
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? sColor : PdfColors.white,
            ),
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: _dinamikMetin(
                    'satir1_1',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    (index + 1).toString(),
                    dil,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (ilkGorsel != null)
                      pw.Container(
                        width: 28,
                        height: 28,
                        margin: const pw.EdgeInsets.only(right: 6),
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(4),
                          image: pw.DecorationImage(
                            image: pw.MemoryImage(
                              base64Decode(
                                ilkGorsel.replaceAll(RegExp(r'\s+'), ''),
                              ),
                            ),
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),
                    pw.Expanded(
                      child: _dinamikMetin(
                        'satir1_2',
                        metinAyarlari,
                        fontRegular,
                        fontBold,
                        satir.urunAdi,
                        dil,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: _dinamikMetin(
                    'satir1_3',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    satir.miktar.toString(),
                    dil,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: _dinamikMetin(
                    'satir1_4',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    "${satir.birimFiyat.toStringAsFixed(2)} $doviz",
                    dil,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: _dinamikMetin(
                    'satir1_5',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    satir.iskontoYuzdesi == 0
                        ? "-"
                        : "%${satir.iskontoYuzdesi.toStringAsFixed(0)}",
                    dil,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: _dinamikMetin(
                    'satir1_6',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    satir.kdvOrani == 0
                        ? "-"
                        : "%${satir.kdvOrani.toStringAsFixed(0)}",
                    dil,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: _dinamikMetin(
                    'satir1_7',
                    metinAyarlari,
                    fontRegular,
                    fontBold,
                    "${satir.genelToplam.toStringAsFixed(2)} $doviz",
                    dil,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildToplamlar(
    List<TeklifSatiri> satirlar,
    Map<String, dynamic> metinAyarlari,
    pw.Font fontRegular,
    pw.Font fontBold,
    String doviz,
    String dil,
  ) {
    double araToplam = satirlar.fold(0, (sum, item) => sum + item.hamToplam);
    double toplamIndirim = satirlar.fold(
      0,
      (sum, item) => sum + item.indirimTutari,
    );
    double kdvHaricTutar = satirlar.fold(
      0,
      (sum, item) => sum + item.kdvHaricTutar,
    );
    double toplamKdv = satirlar.fold(0, (sum, item) => sum + item.kdvTutari);
    double genelToplam = satirlar.fold(
      0,
      (sum, item) => sum + item.genelToplam,
    );

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _dinamikMetin(
                'araToplam',
                metinAyarlari,
                fontRegular,
                fontBold,
                'Ara Toplam',
                dil,
              ),
              _dinamikMetin(
                'araToplamDeger',
                metinAyarlari,
                fontRegular,
                fontBold,
                "${araToplam.toStringAsFixed(2)} $doviz",
                dil,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          if (toplamIndirim > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _dinamikMetin(
                  'indirim',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'Toplam İndirim',
                  dil,
                ),
                _dinamikMetin(
                  'indirimDeger',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  "-${toplamIndirim.toStringAsFixed(2)} $doviz",
                  dil,
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          if (toplamIndirim > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _dinamikMetin(
                  'kdvHaric',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  'KDV Hariç Tutar',
                  dil,
                ),
                _dinamikMetin(
                  'kdvHaricDeger',
                  metinAyarlari,
                  fontRegular,
                  fontBold,
                  "${kdvHaricTutar.toStringAsFixed(2)} $doviz",
                  dil,
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _dinamikMetin(
                'kdv',
                metinAyarlari,
                fontRegular,
                fontBold,
                'Toplam KDV',
                dil,
              ),
              _dinamikMetin(
                'kdvDeger',
                metinAyarlari,
                fontRegular,
                fontBold,
                "+${toplamKdv.toStringAsFixed(2)} $doviz",
                dil,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Divider(color: _borderColor, thickness: 0.5),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _dinamikMetin(
                'genelToplamBaslik',
                metinAyarlari,
                fontRegular,
                fontBold,
                'GENEL TOPLAM',
                dil,
              ),
              _dinamikMetin(
                'genelToplamDeger',
                metinAyarlari,
                fontRegular,
                fontBold,
                "${genelToplam.toStringAsFixed(2)} $doviz",
                dil,
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(
    int pageNumber,
    int pagesCount,
    Map<String, String> t,
    PdfColor borderColor,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: borderColor, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              t['footer']!,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              "${t['sayfa']} $pageNumber / $pagesCount",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
