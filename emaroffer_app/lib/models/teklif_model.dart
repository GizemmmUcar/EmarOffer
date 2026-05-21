class TeklifModel {
  final int id;
  final String teklifNo;
  final int musteriId;
  final String firmaAdi;
  final double araToplam;
  final double toplamIndirim;
  final double genelToplam;
  final String durum;
  final String genelNot;
  final int gecerlilikGunu;

  TeklifModel({
    required this.id,
    required this.teklifNo,
    required this.musteriId,
    required this.firmaAdi,
    required this.araToplam,
    required this.toplamIndirim,
    required this.genelToplam,
    required this.durum,
    required this.genelNot,
    required this.gecerlilikGunu,
  });

  factory TeklifModel.fromJson(Map<String, dynamic> json) {
    return TeklifModel(
      id: json['Id'] ?? 0,
      teklifNo: json['TeklifNo'] ?? '',
      musteriId: json['MusteriId'] ?? 0,
      firmaAdi: json['FirmaAdi'] ?? 'Bilinmeyen Müşteri',
      araToplam: (json['AraToplam'] as num?)?.toDouble() ?? 0.0,
      toplamIndirim: (json['ToplamIndirim'] as num?)?.toDouble() ?? 0.0,
      genelToplam: (json['GenelToplam'] as num?)?.toDouble() ?? 0.0,
      durum: json['Durum'] ?? 'Bekliyor',
      genelNot: json['GenelNot'] ?? '',
      gecerlilikGunu: json['GecerlilikGunu'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "teklifNo": teklifNo,
      "musteriId": musteriId,
      "araToplam": araToplam,
      "toplamIndirim": toplamIndirim,
      "genelToplam": genelToplam,
      "durum": durum,
      "genelNot": genelNot,
    };
  }
}
