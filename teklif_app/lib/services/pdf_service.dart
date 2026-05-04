import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/teklif_satiri_model.dart';

class PdfService {
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF0F4C81);
  static const PdfColor _secondaryColor = PdfColor.fromInt(0xFFFAFAFA);
  static const PdfColor _textColor = PdfColor.fromInt(0xFF1F2937);
  static const PdfColor _accentColor = PdfColor.fromInt(0xFF4B5563);
  static const PdfColor _dangerColor = PdfColor.fromInt(0xFF991B1B);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFD1D5DB);

  static Future<Uint8List> teklifPdfOlustur({
    required Map<String, dynamic> teklif,
    required List<dynamic> urunler,
    required Map<String, dynamic> sirket,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final String doviz = teklif["Doviz"]?.toString() ?? "TRY";
    final String hamTarih = teklif["OlusturmaTarihi"]?.toString() ?? "";
    DateTime tarihObj = DateTime.tryParse(hamTarih) ?? DateTime.now();

    final String formatliTarih =
        "${tarihObj.day.toString().padLeft(2, '0')}.${tarihObj.month.toString().padLeft(2, '0')}.${tarihObj.year}";

    final int gecerlilikGunu = teklif["GecerlilikGunu"] ?? 7;
    DateTime bitisObj = tarihObj.add(Duration(days: gecerlilikGunu));

    final String gecerlilikTarihi =
        "${bitisObj.day.toString().padLeft(2, '0')}.${bitisObj.month.toString().padLeft(2, '0')}.${bitisObj.year}";

    final List<TeklifSatiri> satirlar = urunler
        .map((u) => TeklifSatiri.fromJson(u))
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
            font: fontRegular,
            color: _textColor,
            fontSize: 10,
          ),
        ),
        header: (context) => _buildHeader(fontBold, sirket),
        footer: (context) =>
            _buildFooter(context.pageNumber, context.pagesCount),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildMusteriBilgileri(fontBold, fontRegular, teklif, formatliTarih),
          pw.SizedBox(height: 25),
          _buildUrunlerTablosu(satirlar, urunler, fontBold, doviz),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 4,
                child: _buildNotlar(
                  fontBold,
                  fontItalic,
                  teklif,
                  sirket,
                  gecerlilikTarihi,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                flex: 3,
                child: _buildToplamlar(satirlar, fontBold, doviz),
              ),
            ],
          ),
          pw.SizedBox(height: 50),
          _buildImzaAlani(
            fontBold,
            sirket["Yetkili"]?.toString() ??
                sirket["SirketAdi"]?.toString() ??
                "",
            teklif["FirmaAdi"]?.toString() ?? "Müşteri",
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font fontBold, Map<String, dynamic> sirket) {
    final String sirketAdi =
        sirket["SirketAdi"]?.toString() ?? sirket["Unvan"]?.toString() ?? "";
    final String adres = sirket["Adres"]?.toString() ?? "";
    final String telefon = sirket["Telefon"]?.toString() ?? "";
    final String eposta =
        sirket["Eposta"]?.toString() ?? sirket["Email"]?.toString() ?? "";
    final String web = sirket["WebSitesi"]?.toString() ?? "";
    final String vDairesi = sirket["VergiDairesi"]?.toString() ?? "";
    final String vNo = sirket["VergiNo"]?.toString() ?? "";
    final String logoBase64 = sirket["Logo"]?.toString() ?? "";

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    sirketAdi.isNotEmpty
                        ? sirketAdi.toUpperCase()
                        : "ŞİRKET ÜNVANI",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 20,
                      color: _primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (adres.isNotEmpty)
                    pw.Text(
                      adres,
                      style: const pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 10,
                      ),
                    ),
                  pw.SizedBox(height: 4),
                  if (telefon.isNotEmpty || eposta.isNotEmpty || web.isNotEmpty)
                    pw.Text(
                      [
                        if (telefon.isNotEmpty) "Tel: $telefon",
                        if (eposta.isNotEmpty) "E-posta: $eposta",
                        if (web.isNotEmpty) "Web: $web",
                      ].join("  |  "),
                      style: const pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 10,
                      ),
                    ),
                  if (vDairesi.isNotEmpty || vNo.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "V.D: ${vDairesi.isNotEmpty ? vDairesi : '-'}   |   V.No: ${vNo.isNotEmpty ? vNo : '-'}",
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        font: fontBold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (logoBase64.isNotEmpty)
              pw.Container(
                height: 80,
                width: 160,
                alignment: pw.Alignment.centerRight,
                child: pw.Image(
                  pw.MemoryImage(base64Decode(logoBase64)),
                  fit: pw.BoxFit.contain,
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: _primaryColor, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildMusteriBilgileri(
    pw.Font fontBold,
    pw.Font fontRegular,
    Map<String, dynamic> teklif,
    String formatliTarih,
  ) {
    final String firmaAdi = teklif["FirmaAdi"]?.toString() ?? "MÜŞTERİ";
    final String telefon = teklif["Telefon"]?.toString() ?? "";
    final String eposta = teklif["Eposta"]?.toString() ?? "";
    final String vDairesi = teklif["VergiDairesi"]?.toString() ?? "";
    final String vNo = teklif["VergiNo"]?.toString() ?? "";
    final acikAdres = teklif["Adres"]?.toString().trim() ?? "";
    final ilce = teklif["Ilce"]?.toString().trim() ?? "";
    final sehir = teklif["Sehir"]?.toString().trim() ?? "";
    final ulke = teklif["Ulke"]?.toString().trim() ?? "";

    List<String> adresParcalari = [];
    if (acikAdres.isNotEmpty) adresParcalari.add(acikAdres);

    String lokasyon = "";
    if (ilce.isNotEmpty) lokasyon += ilce;
    if (sehir.isNotEmpty) lokasyon += lokasyon.isNotEmpty ? " / $sehir" : sehir;
    if (lokasyon.isNotEmpty) adresParcalari.add(lokasyon);
    if (ulke.isNotEmpty) adresParcalari.add(ulke);

    final tamAdresMetni = adresParcalari.join('\n');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          firmaAdi.toUpperCase(),
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 13,
            color: _primaryColor,
          ),
        ),
        pw.SizedBox(height: 6),

        if (tamAdresMetni.isNotEmpty)
          pw.Text(
            tamAdresMetni,
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),

        if (tamAdresMetni.isNotEmpty) pw.SizedBox(height: 4),

        if (telefon.isNotEmpty)
          pw.Text(
            "Tel: $telefon",
            style: pw.TextStyle(font: fontRegular, fontSize: 10),
          ),
        if (eposta.isNotEmpty)
          pw.Text(
            "E-posta: $eposta",
            style: pw.TextStyle(font: fontRegular, fontSize: 10),
          ),
        if (vDairesi.isNotEmpty || vNo.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            "V.D: ${vDairesi.isNotEmpty ? vDairesi : '-'}   |   V.No: ${vNo.isNotEmpty ? vNo : '-'}",
            style: pw.TextStyle(font: fontRegular, fontSize: 10),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          "Düzenleme Tarihi: $formatliTarih",
          style: pw.TextStyle(font: fontBold, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildUrunlerTablosu(
    List<TeklifSatiri> satirlar,
    List<dynamic> rawUrunler,
    pw.Font fontBold,
    String doviz,
  ) {
    final headers = [
      'Sıra',
      'Ürün / Hizmet Açıklaması',
      'Miktar',
      'Birim Fiyat',
      'İsk.',
      '% KDV',
      'Tutar',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(35),
        3: const pw.FixedColumnWidth(55),
        4: const pw.FixedColumnWidth(30),
        5: const pw.FixedColumnWidth(30),
        6: const pw.FixedColumnWidth(65),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primaryColor),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      h.toUpperCase(),
                      style: pw.TextStyle(
                        font: fontBold,
                        color: PdfColors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...List.generate(satirlar.length, (index) {
          final satir = satirlar[index];
          final bool isOdd = index % 2 != 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isOdd ? _secondaryColor : PdfColors.white,
            ),
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Text(
                    (index + 1).toString(),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  satir.urunAdi.isNotEmpty ? satir.urunAdi : "Ürün",
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Text(
                    satir.miktar.toString(),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "${satir.birimFiyat.toStringAsFixed(2)} $doviz",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Text(
                    satir.iskontoYuzdesi == 0
                        ? "-"
                        : "%${satir.iskontoYuzdesi.toStringAsFixed(0)}",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Text(
                    satir.kdvOrani == 0
                        ? "-"
                        : "%${satir.kdvOrani.toStringAsFixed(0)}",
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "${satir.genelToplam.toStringAsFixed(2)} $doviz",
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
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
    pw.Font fontBold,
    String doviz,
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
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _ozetSatiri("Ara Toplam", "${araToplam.toStringAsFixed(2)} $doviz"),

          if (toplamIndirim > 0)
            _ozetSatiri(
              "Toplam İndirim",
              "-${toplamIndirim.toStringAsFixed(2)} $doviz",
              renk: _dangerColor,
            ),

          if (toplamIndirim > 0)
            _ozetSatiri(
              "KDV Hariç Tutar",
              "${kdvHaricTutar.toStringAsFixed(2)} $doviz",
            ),

          pw.Divider(color: _borderColor, thickness: 0.5),

          _ozetSatiri(
            "Toplam KDV",
            "+${toplamKdv.toStringAsFixed(2)} $doviz",
            renk: _accentColor,
          ),

          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            color: _primaryColor,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "GENEL TOPLAM",
                  style: pw.TextStyle(
                    font: fontBold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  "${genelToplam.toStringAsFixed(2)} $doviz",
                  style: pw.TextStyle(
                    font: fontBold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotlar(
    pw.Font fontBold,
    pw.Font fontItalic,
    Map<String, dynamic> teklif,
    Map<String, dynamic> sirket,
    String gecerlilikTarihi,
  ) {
    final odemeTuru = teklif["OdemeTuru"]?.toString() ?? "-";
    final bankaBilgisi =
        sirket["BankaBilgileri"]?.toString() ??
        sirket["Iban"]?.toString() ??
        "";
    final notlar = teklif["GenelNot"]?.toString() ?? "";

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "TİCARİ ŞARTLAR VE NOTLAR",
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 9,
              color: _primaryColor,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Ödeme Türü: $odemeTuru",
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.Text(
            "Teklif Geçerlilik Tarihi: $gecerlilikTarihi",
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (bankaBilgisi.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              "Banka ve Hesap Bilgileri:",
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
            pw.SizedBox(height: 2),
            pw.Text(bankaBilgisi, style: const pw.TextStyle(fontSize: 9)),
          ],
          if (notlar.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              "Ek Açıklama:",
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              notlar,
              style: pw.TextStyle(
                font: fontItalic,
                fontSize: 9,
                color: _accentColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildImzaAlani(
    pw.Font fontBold,
    String sirketYetkilisi,
    String firmaAdi,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "TEKLİFİ DÜZENLEYEN",
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              pw.Text(sirketYetkilisi, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 40),
              pw.Text(
                "Kaşe / İmza",
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "MÜŞTERİ ONAYI",
                style: pw.TextStyle(font: fontBold, fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                firmaAdi,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
                maxLines: 1,
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                "Kaşe / İmza",
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _ozetSatiri(
    String etiket,
    String deger, {
    PdfColor? renk,
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            etiket,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            deger,
            style: pw.TextStyle(
              color: renk,
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(int pageNumber, int pagesCount) {
    return pw.Column(
      children: [
        pw.Divider(color: _borderColor, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Bu belge mali ve ticari nitelik taşımaktadır.",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              "Sayfa $pageNumber / $pagesCount",
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
