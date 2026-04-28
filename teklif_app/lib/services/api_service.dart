import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/teklif_model.dart';
import '../utils/constants.dart';
import '../models/teklif_satiri_model.dart';

class ApiService {
  static final String _baseUrl = AppConstants.apiUrl;
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static int? aktifKullaniciId;

  // Teklif

  Future<List<dynamic>> getTeklifler() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/teklifler'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createTeklif({
    required TeklifModel teklif,
    required List<TeklifSatiri> satirlar,
    required double araToplam,
    required double toplamIndirim,
    String? genelNot,
    int? gecerlilikGunu,
    int? secilenMusteriId,
    String? yeniFirmaAdi,
    String? yeniYetkiliKisi,
    String? yeniTelefon,
    String? yeniEposta,
    String? yeniVergiDairesi,
    String? yeniVergiNo,
    String? yeniAdres,
    String? doviz,
    String? odemeTuru,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/teklifler'),
        headers: _headers,
        body: jsonEncode({
          "teklifNo": teklif.teklifNo,
          "kullaniciId": ApiService.aktifKullaniciId,
          "musteriId": secilenMusteriId,
          "yeniFirmaAdi": yeniFirmaAdi,
          "yeniYetkiliKisi": yeniYetkiliKisi,
          "yeniTelefon": yeniTelefon,
          "yeniEposta": yeniEposta,
          "yeniVergiDairesi": yeniVergiDairesi,
          "yeniVergiNo": yeniVergiNo,
          "yeniAdres": yeniAdres,
          "araToplam": araToplam,
          "toplamIndirim": toplamIndirim,
          "genelToplam": teklif.genelToplam,
          "genelNot": genelNot,
          "gecerlilikGunu": gecerlilikGunu,
          "doviz": doviz,
          "odemeTuru": odemeTuru,
          "urunler": satirlar,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Teklif oluşturma hatası: $e");
      return false;
    }
  }

  Future<String?> deleteTeklif(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/teklifler/$id'));
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  Future<bool> updateTeklifDurumu(int id, String yeniDurum) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/teklifler/$id/durum'),
        headers: _headers,
        body: jsonEncode({"durum": yeniDurum}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTeklif(int teklifId, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/teklifler/$teklifId/guncelle'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Teklif güncelleme hatası: $e");
      return false;
    }
  }

  Future<List<dynamic>> getTeklifDetaylari(int teklifId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/teklifler/$teklifId/detay'),
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      debugPrint("Teklif detay hatası: $e");
      return [];
    }
  }

  // Müşteri

  Future<List<dynamic>> getMusteriler() async {
    final response = await http.get(Uri.parse('$_baseUrl/musteriler'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  Future<bool> createMusteri(
    String firmaAdi,
    String yetkili,
    String telefon,
    String eposta,
    String vDairesi,
    String vNo,
    String adres,
  ) async {
    try {
      final body = jsonEncode({
        "firmaAdi": firmaAdi,
        "yetkiliKisi": yetkili,
        "telefon": telefon,
        "eposta": eposta,
        "vergiDairesi": vDairesi,
        "vergiNo": vNo,
        "adres": adres,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/musteriler'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMusteri(
    int id,
    String firmaAdi,
    String yetkili,
    String telefon,
    String eposta,
    String vDairesi,
    String vNo,
    String adres,
  ) async {
    try {
      final body = jsonEncode({
        "firmaAdi": firmaAdi,
        "yetkiliKisi": yetkili,
        "telefon": telefon,
        "eposta": eposta,
        "vergiDairesi": vDairesi,
        "vergiNo": vNo,
        "adres": adres,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/musteriler/$id'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteMusteri(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/musteriler/$id'));
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  // Ürün

  Future<List<dynamic>> getUrunler() async {
    final response = await http.get(Uri.parse('$_baseUrl/urunler'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  Future<bool> createUrun(
    String ad,
    String urunKodu,
    double fiyat,
    String paraBirimi,
    int kdv,
    String aciklama,
  ) async {
    try {
      final body = jsonEncode({
        "urunAdi": ad,
        "urunKodu": urunKodu,
        "birimFiyati": fiyat,
        "paraBirimi": paraBirimi,
        "kdvOrani": kdv,
        "aciklama": aciklama,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/urunler'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUrun(
    int id,
    String ad,
    String urunKodu,
    double fiyat,
    String paraBirimi,
    int kdv,
    String aciklama,
  ) async {
    try {
      final body = jsonEncode({
        "urunAdi": ad,
        "urunKodu": urunKodu,
        "birimFiyati": fiyat,
        "paraBirimi": paraBirimi,
        "kdvOrani": kdv,
        "aciklama": aciklama,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/urunler/$id'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteUrun(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/urunler/$id'));
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  // Kullanıcı / Çalışan

  Future<List<dynamic>> getKullanicilar() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/kullanicilar'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createKullanici(
    String adSoyad,
    String eposta,
    String sifre,
    int rolId,
  ) async {
    try {
      final body = jsonEncode({
        "adSoyad": adSoyad,
        "eposta": eposta,
        "sifre": sifre,
        "rolId": rolId,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/kullanicilar'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateKullanici(
    int id,
    String adSoyad,
    String eposta,
    String sifre,
    int rolId,
  ) async {
    try {
      final body = jsonEncode({
        "adSoyad": adSoyad,
        "eposta": eposta,
        "sifre": sifre,
        "rolId": rolId,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/kullanicilar/$id'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteKullanici(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/kullanicilar/$id'),
      );
      if (response.statusCode == 200) {
        return null;
      }
      return response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  Future<List<dynamic>> getRoller() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/roller'));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // Giriş Yapma

  Future<Map<String, dynamic>?> girisYap(
    String kullaniciBilgisi,
    String sifre,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kullanicilar/login'),
        headers: _headers,
        body: jsonEncode({
          "kullaniciBilgisi": kullaniciBilgisi,
          "sifre": sifre,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint("Giriş Başarısız: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Bağlantı Hatası: $e");
      return null;
    }
  }

  // Dashboard

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/dashboard-stats'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("API Hatası: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Dashboard Veri Çekme Hatası: $e");
      throw Exception("Bağlantı kurulamadı.");
    }
  }

  // Şirket bilgileri

  Future<Map<String, dynamic>?> getSirketBilgileri() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sirket'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Şirket bilgileri çekilemedi: $e");
      return null;
    }
  }

  Future<bool> updateSirketBilgileri(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/sirket'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("API Hatası (Şirket Güncelleme): ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Sunucuya bağlanılamadı (Şirket Güncelleme): $e");
      return false;
    }
  }
}
