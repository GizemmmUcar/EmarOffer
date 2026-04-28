import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<Uint8List> teklifPdfOlustur({
    required Map<String, dynamic> teklif,
    required List<dynamic> urunler,
    required Map<String, dynamic> sirket,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    const primaryColor = PdfColor.fromInt(0xFF3F51B5);
    const secondaryColor = PdfColor.fromInt(0xFFE8EAF6);
    const textColor = PdfColor.fromInt(0xFF374151);

    final String doviz = teklif["Doviz"]?.toString() ?? "TRY";
    final String firmaAdi = teklif["FirmaAdi"]?.toString() ?? "Sayın Müşteri";
    final String notlar = teklif["GenelNot"]?.toString() ?? "";
    final String odemeTuru = teklif["OdemeTuru"]?.toString() ?? "-";
    final int gecerlilik = teklif["GecerlilikGunu"] ?? 7;
    final String hamTarih = teklif["OlusturmaTarihi"]?.toString() ?? "";
    DateTime tarihObj = DateTime.tryParse(hamTarih) ?? DateTime.now();
    final String formatliTarih =
        "${tarihObj.day.toString().padLeft(2, '0')}.${tarihObj.month.toString().padLeft(2, '0')}.${tarihObj.year}";

    final String sirketAdi =
        sirket["SirketAdi"]?.toString() ?? sirket["Unvan"]?.toString() ?? "";
    final String sirketAdres = sirket["Adres"]?.toString() ?? "";
    final String sirketTelefon = sirket["Telefon"]?.toString() ?? "";
    final String sirketEposta =
        sirket["Eposta"]?.toString() ?? sirket["Email"]?.toString() ?? "";
    final String sirketWeb = sirket["WebSitesi"]?.toString() ?? "";
    final String vergiDairesi = sirket["VergiDairesi"]?.toString() ?? "";
    final String vergiNo = sirket["VergiNo"]?.toString() ?? "";
    final String bankaBilgisi =
        sirket["BankaBilgileri"]?.toString() ??
        sirket["Iban"]?.toString() ??
        "";
    final String logoBase64 = sirket["Logo"]?.toString() ?? "";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
            font: fontRegular,
            color: textColor,
            fontSize: 10,
          ),
        ),
        header: (context) => _buildHeader(
          fontBold,
          primaryColor,
          sirketAdi,
          sirketAdres,
          sirketTelefon,
          sirketEposta,
          sirketWeb,
          vergiDairesi,
          vergiNo,
          logoBase64,
        ),
        footer: (context) =>
            _buildFooter(fontRegular, context.pageNumber, context.pagesCount),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildMusteriBilgileri(fontBold, fontRegular, teklif, formatliTarih),
          pw.SizedBox(height: 30),
          _buildUrunlerTablosu(
            urunler,
            fontBold,
            fontRegular,
            primaryColor,
            secondaryColor,
            doviz,
          ),
          pw.SizedBox(height: 20),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 4,
                child: _buildNotlar(
                  fontBold,
                  fontItalic,
                  notlar,
                  odemeTuru,
                  gecerlilik,
                  bankaBilgisi,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                flex: 3,
                child: _buildToplamlar(teklif, fontBold, primaryColor, doviz),
              ),
            ],
          ),

          pw.SizedBox(height: 50),
          _buildImzaAlani(
            fontBold,
            sirket["Yetkili"]?.toString() ?? sirketAdi,
            firmaAdi,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    pw.Font fontBold,
    PdfColor primaryColor,
    String sirketAdi,
    String adres,
    String telefon,
    String eposta,
    String web,
    String vDairesi,
    String vNo,
    String logoBase64,
  ) {
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
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  if (adres.isNotEmpty)
                    pw.Text(
                      adres,
                      style: pw.TextStyle(color: PdfColors.grey700),
                    ),
                  pw.SizedBox(height: 4),
                  if (telefon.isNotEmpty || eposta.isNotEmpty || web.isNotEmpty)
                    pw.Text(
                      [
                        if (telefon.isNotEmpty) "Tel: $telefon",
                        if (eposta.isNotEmpty) "E-posta: $eposta",
                        if (web.isNotEmpty) "Web: $web",
                      ].join("  |  "),
                      style: pw.TextStyle(color: PdfColors.grey700),
                    ),
                  if (vDairesi.isNotEmpty || vNo.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "V. Dairesi: ${vDairesi.isNotEmpty ? vDairesi : '-'}  |  V. No: ${vNo.isNotEmpty ? vNo : '-'}",
                      style: pw.TextStyle(
                        color: PdfColors.grey700,
                        font: fontBold,
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
              )
            else
              pw.SizedBox(width: 10),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: primaryColor, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildMusteriBilgileri(
    pw.Font fontBold,
    pw.Font fontRegular,
    Map<String, dynamic> teklif,
    String formatliTarih,
  ) {
    final String firmaAdi = teklif["FirmaAdi"]?.toString() ?? "Bilinmiyor";
    final String adres = teklif["Adres"]?.toString() ?? "";
    final String telefon = teklif["Telefon"]?.toString() ?? "";
    final String eposta = teklif["Eposta"]?.toString() ?? "";
    final String vDairesi = teklif["VergiDairesi"]?.toString() ?? "";
    final String vNo = teklif["VergiNo"]?.toString() ?? "";

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Müşteri / Alıcı:",
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  firmaAdi,
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 4),

                if (adres.isNotEmpty)
                  pw.Text(
                    adres,
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                if (adres.isNotEmpty) pw.SizedBox(height: 2),

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
                    "V. Dairesi: ${vDairesi.isNotEmpty ? vDairesi : '-'} | V. No: ${vNo.isNotEmpty ? vNo : '-'}",
                    style: pw.TextStyle(font: fontRegular, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Tarih:",
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                formatliTarih,
                style: pw.TextStyle(font: fontBold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildUrunlerTablosu(
    List<dynamic> urunler,
    pw.Font fontBold,
    pw.Font fontRegular,
    PdfColor primaryColor,
    PdfColor secondaryColor,
    String doviz,
  ) {
    final headers = [
      'Sıra',
      'Ürün / Hizmet Açıklaması',
      'Miktar',
      'B. Fiyat',
      'iskonto',
      'Tutar',
    ];
    final data = List<List<String>>.generate(urunler.length, (index) {
      final u = urunler[index];
      final miktar = u["Miktar"]?.toString() ?? "1";
      final birimFiyat =
          double.tryParse(
            u["BirimFiyat"]?.toString() ?? "0",
          )?.toStringAsFixed(2) ??
          "0.00";
      final iskonto = u["IskontoYuzdesi"]?.toString() ?? "0";
      double satirToplami =
          (double.parse(birimFiyat) * int.parse(miktar)) *
          (1 - (double.parse(iskonto) / 100));
      return [
        (index + 1).toString(),
        u["UrunAdi"]?.toString() ?? "Ürün",
        miktar,
        "$birimFiyat $doviz",
        (iskonto == "0" ? "-" : "%$iskonto"),
        "${satirToplami.toStringAsFixed(2)} $doviz",
      ];
    });

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
        font: fontBold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      cellHeight: 25,
      cellStyle: pw.TextStyle(font: fontRegular, fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      oddRowDecoration: pw.BoxDecoration(color: secondaryColor),
    );
  }

  static pw.Widget _buildToplamlar(
    Map<String, dynamic> teklif,
    pw.Font fontBold,
    PdfColor primaryColor,
    String doviz,
  ) {
    final araToplam =
        double.tryParse(
          teklif["AraToplam"]?.toString() ?? "0",
        )?.toStringAsFixed(2) ??
        "0.00";
    final indirim =
        double.tryParse(
          teklif["ToplamIndirim"]?.toString() ?? "0",
        )?.toStringAsFixed(2) ??
        "0.00";
    final genelToplam =
        double.tryParse(
          teklif["GenelToplam"]?.toString() ?? "0",
        )?.toStringAsFixed(2) ??
        "0.00";
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          _hesapSatiri("Ara Toplam:", "$araToplam $doviz", fontBold),
          pw.SizedBox(height: 4),
          _hesapSatiri(
            "İndirim:",
            "-$indirim $doviz",
            fontBold,
            color: PdfColors.red700,
          ),
          pw.Divider(color: PdfColors.grey400),
          _hesapSatiri(
            "Genel Toplam:",
            "$genelToplam $doviz",
            fontBold,
            fontSize: 12,
            color: primaryColor,
          ),
        ],
      ),
    );
  }

  static pw.Widget _hesapSatiri(
    String baslik,
    String deger,
    pw.Font fontBold, {
    PdfColor color = PdfColors.black,
    double fontSize = 10,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          baslik,
          style: pw.TextStyle(font: fontBold, fontSize: fontSize, color: color),
        ),
        pw.Text(
          deger,
          style: pw.TextStyle(font: fontBold, fontSize: fontSize, color: color),
        ),
      ],
    );
  }

  static pw.Widget _buildNotlar(
    pw.Font fontBold,
    pw.Font fontItalic,
    String notlar,
    String odemeTuru,
    int gecerlilik,
    String bankaBilgisi,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Ödeme ve Şartlar",
          style: pw.TextStyle(font: fontBold, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 6),
        pw.Text("• Ödeme Türü: $odemeTuru"),
        pw.Text("• Teklif Geçerlilik Süresi: $gecerlilik Gün"),
        if (bankaBilgisi.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            "Banka ve Ödeme Bilgileri:",
            style: pw.TextStyle(font: fontBold, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(bankaBilgisi, style: pw.TextStyle(color: PdfColors.grey800)),
        ],
        if (notlar.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(
            "Açıklama / Notlar:",
            style: pw.TextStyle(font: fontBold, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            notlar,
            style: pw.TextStyle(font: fontItalic, color: PdfColors.grey800),
          ),
        ],
      ],
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
        pw.Column(
          children: [
            pw.Text("TEKLİFİ HAZIRLAYAN", style: pw.TextStyle(font: fontBold)),
            pw.SizedBox(height: 4),
            pw.Text(
              sirketYetkilisi,
              style: pw.TextStyle(color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              "Kaşe / İmza",
              style: pw.TextStyle(color: PdfColors.grey500),
            ),
          ],
        ),
        pw.Column(
          children: [
            pw.Text("TEKLİFİ ONAYLAYAN", style: pw.TextStyle(font: fontBold)),
            pw.SizedBox(height: 4),
            pw.Text(firmaAdi, style: pw.TextStyle(color: PdfColors.grey700)),
            pw.SizedBox(height: 40),
            pw.Text(
              "Kaşe / İmza",
              style: pw.TextStyle(color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    pw.Font fontRegular,
    int pageNumber,
    int pagesCount,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "Bu belge sistem tarafından otomatik olarak oluşturulmuştur.",
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              "Sayfa $pageNumber / $pagesCount",
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
