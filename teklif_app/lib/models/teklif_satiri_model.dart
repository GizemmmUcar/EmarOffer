class TeklifSatiri {
  int? id;
  int? urunId;
  String urunAdi = "";
  int miktar = 1;
  double birimFiyat = 0.0;
  double iskontoYuzdesi = 0.0;

  double get hamToplam => miktar * birimFiyat;
  double get indirimliToplam =>
      hamToplam - (hamToplam * (iskontoYuzdesi / 100));

  TeklifSatiri();
  TeklifSatiri.fromJson(Map<String, dynamic> json) {
    id = json["Id"];
    urunId = json["UrunId"];
    urunAdi = json["UrunAdi"] ?? "";
    miktar = json["Miktar"]?.toInt() ?? 1;
    birimFiyat = (json["BirimFiyat"] as num?)?.toDouble() ?? 0.0;
    iskontoYuzdesi = (json["IskontoYuzdesi"] as num?)?.toDouble() ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      "urunId": urunId,
      "miktar": miktar,
      "birimFiyat": birimFiyat,
      "iskontoYuzdesi": iskontoYuzdesi,
    };
  }
}
