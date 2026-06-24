import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teklif_model.dart';
import '../utils/constants.dart';
import '../models/teklif_satiri_model.dart';

class ApiService {
  static final String _baseUrl = AppConstants.apiUrl;

  static int? aktifKullaniciId;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Giriş yapma

  Future<Map<String, dynamic>?> girisYap(
    String firmaKodu,
    String kullaniciBilgisi,
    String sifre,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kullanicilar/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firmaKodu": firmaKodu,
          "kullaniciBilgisi": kullaniciBilgisi,
          "sifre": sifre,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        aktifKullaniciId = data['user']['Id'];

        return data;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Giriş Hatası: $e");
      rethrow;
    }
  }

  // Çıkış yapma

  Future<void> cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    aktifKullaniciId = null;
  }

  // şifre değiştirme

  Future<bool> ilkSifreyiDegistir(String yeniSifre) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/kullanicilar/sifre-degistir'),
        headers: headers,
        body: jsonEncode({"yeniSifre": yeniSifre}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Teklifler

  Future<List<dynamic>> getTeklifler() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/teklifler'),
        headers: headers,
      );
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
    String? yeniUlke,
    String? yeniSehir,
    String? yeniIlce,
    String? doviz,
    String? odemeTuru,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/teklifler'),
        headers: headers,
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
          "yeniUlke": yeniUlke,
          "yeniSehir": yeniSehir,
          "yeniIlce": yeniIlce,
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
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/teklifler/$id'),
        headers: headers,
      );
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  Future<bool> updateTeklifDurumu(int id, String yeniDurum) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/teklifler/$id/durum'),
        headers: headers,
        body: jsonEncode({"durum": yeniDurum}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTeklif(int teklifId, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/teklifler/$teklifId/guncelle'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/teklifler/$teklifId/detay'),
        headers: headers,
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      debugPrint("Teklif detay hatası: $e");
      return [];
    }
  }

  // PDF

  Future<String?> uploadPdfVeLinkAl(Uint8List pdfBytes, String teklifNo) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/teklifler/pdf-yukle'),
      );

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      request.files.add(
        http.MultipartFile.fromBytes(
          'pdf',
          pdfBytes,
          filename: '$teklifNo.pdf',
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final veri = json.decode(response.body);
        return veri['url'];
      }
      return null;
    } catch (e) {
      debugPrint("PDF Yükleme Hatası: $e");
      return null;
    }
  }

  Future<List<dynamic>> getSablonlar() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/sablonlar'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Şablonlar yüklenemedi');
    }
  }

  Future<void> createSablon(Map<String, dynamic> sablonVerisi) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/sablonlar'),
      headers: headers,
      body: jsonEncode(sablonVerisi),
    );
    if (response.statusCode != 201) {
      throw Exception('Şablon oluşturulamadı');
    }
  }

  Future<void> updateSablon(int id, Map<String, dynamic> sablonVerisi) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/sablonlar/$id'),
      headers: headers,
      body: jsonEncode(sablonVerisi),
    );
    if (response.statusCode != 200) {
      throw Exception('Şablon güncellenemedi');
    }
  }

  Future<void> deleteSablon(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl/sablonlar/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Şablon silinemedi');
    }
  }

  Future<bool> setVarsayilanSablon(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/sablonlar/$id/varsayilan'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Müşteri

  Future<List<dynamic>> getMusteriler() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/musteriler'),
      headers: headers,
    );
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
    String ulke,
    String sehir,
    String ilce,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "firmaAdi": firmaAdi,
        "yetkiliKisi": yetkili,
        "telefon": telefon,
        "eposta": eposta,
        "vergiDairesi": vDairesi,
        "vergiNo": vNo,
        "adres": adres,
        "ulke": ulke,
        "sehir": sehir,
        "ilce": ilce,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/musteriler'),
        headers: headers,
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
    String ulke,
    String sehir,
    String ilce,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "firmaAdi": firmaAdi,
        "yetkiliKisi": yetkili,
        "telefon": telefon,
        "eposta": eposta,
        "vergiDairesi": vDairesi,
        "vergiNo": vNo,
        "adres": adres,
        "ulke": ulke,
        "sehir": sehir,
        "ilce": ilce,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/musteriler/$id'),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteMusteri(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/musteriler/$id'),
        headers: headers,
      );
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  // Ürün

  Future<List<dynamic>> getUrunler() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/urunler'),
      headers: headers,
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  Future<bool> createUrun(
    String ad,
    String urunKodu,
    double fiyat,
    String paraBirimi,
    int kdv,
    String aciklama,
    String? urunGorsel,
    String kategori,
    String altKategori,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "urunAdi": ad,
        "urunKodu": urunKodu,
        "birimFiyati": fiyat,
        "paraBirimi": paraBirimi,
        "kdvOrani": kdv,
        "aciklama": aciklama,
        "urunGorsel": urunGorsel,
        "kategori": kategori,
        "altKategori": altKategori,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/urunler'),
        headers: headers,
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
    String? urunGorsel,
    String kategori,
    String altKategori,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "urunAdi": ad,
        "urunKodu": urunKodu,
        "birimFiyati": fiyat,
        "paraBirimi": paraBirimi,
        "kdvOrani": kdv,
        "aciklama": aciklama,
        "urunGorsel": urunGorsel,
        "kategori": kategori,
        "altKategori": altKategori,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/urunler/$id'),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteUrun(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/urunler/$id'),
        headers: headers,
      );
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }

  // Kullanıcı Çalışan

  Future<List<dynamic>> getKullanicilar() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/kullanicilar'),
        headers: headers,
      );
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
      final headers = await _getHeaders();
      final body = jsonEncode({
        "adSoyad": adSoyad,
        "eposta": eposta,
        "sifre": sifre,
        "rolId": rolId,
      });
      final response = await http.post(
        Uri.parse('$_baseUrl/kullanicilar'),
        headers: headers,
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
      final headers = await _getHeaders();
      final body = jsonEncode({
        "adSoyad": adSoyad,
        "eposta": eposta,
        "sifre": sifre,
        "rolId": rolId,
      });
      final response = await http.put(
        Uri.parse('$_baseUrl/kullanicilar/$id'),
        headers: headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> deleteKullanici(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/kullanicilar/$id'),
        headers: headers,
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/roller'),
        headers: headers,
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      return [];
    }
  }

  // Dashboard

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard-stats'),
        headers: headers,
      );

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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/sirket'),
        headers: headers,
      );
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
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/api/sirket'),
        headers: headers,
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

  // Firma yönetimi

  Future<List<dynamic>> getFirmalar() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/firmalar'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createFirma(
    String firmaKodu,
    String firmaAdi,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/firmalar'),
        headers: headers,
        body: jsonEncode({"firmaKodu": firmaKodu, "firmaAdi": firmaAdi}),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> updateFirma(int id, String firmaAdi, bool aktifMi) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/firmalar/$id'),
        headers: headers,
        body: jsonEncode({"firmaAdi": firmaAdi, "aktifMi": aktifMi}),
      );
      if (response.statusCode != 200) throw Exception(response.body);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> deleteFirma(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/firmalar/$id'),
        headers: headers,
      );
      return response.statusCode == 200 ? null : response.body;
    } catch (e) {
      return "Silme hatası.";
    }
  }
}
