# Emar Offer - End-to-End Proposal Management System

![Flutter](https://img.shields.io/badge/Frontend-Flutter_3.x-02569B?style=for-the-badge&logo=flutter)
![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=nodedotjs)
![MSSQL](https://img.shields.io/badge/Database-SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver)

Emar Offer, kurumsal firmaların müşteri, ürün ve teklif süreçlerini uçtan uca (Full-Stack) dijitalleştiren kapsamlı bir CRM ve teklif yönetim platformudur. Sistem, kod yönetiminin kolaylaştırılması ve modüler bir mimari elde edilmesi amacıyla bağımsız **Backend** ve **Frontend** servislerinden oluşmaktadır.

---

## Proje Yapısı ve Mimari

Uygulama, kurumsal yazılım standartlarına (Layered & Modular Architecture) uygun şekilde iki parça halinde tasarlanmıştır:

- **`backend/`**: Sistemin veri güvenliğini, iş mantığını ve SQL Server entegrasyonunu yürüten Node.js tabanlı RESTful API servisidir.
- **`frontend/`**: Kullanıcı etkileşimini sağlayan, tek bir kod tabanından hem Web hem de Mobil (Android/iOS) platformlarda çalışan Flutter arayüz uygulamasıdır.

---

## Öne Çıkan Özellikler

- ** Kusursuz Responsive UI:** Cihaz ekran genişliğini dinamik ölçen altyapı sayesinde masaüstünde geniş veri tabloları, mobilde ise dikey akışkan kart mimarisi sunar.
- ** Dinamik PDF Önizleme ve Düzenleme:** Hazırlanan teklifler anlık olarak PDF formatına dönüştürülür. Ayarlar üzerinden şablon rengi, font tipi ve blok sıralaması canlı olarak değiştirilebilir.
- ** Gerçek Zamanlı Finansal Hesaplama:** Ürün girişleri esnasında miktar, birim fiyat, iskonto ve KDV oranlarına göre ara toplam ve genel toplamlar anlık hesaplanır.
- ** Çoklu Dil Desteği:** Tek bir dokunuşla tekliflerin Türkçe (TR) veya İngilizce (EN) formatta üretilmesi sağlanır.
- ** Hızlı Entegrasyon:** Oluşturulan PDF bağlantıları WhatsApp ve E-Posta entegrasyonuyla doğrudan müşterilere iletilebilir.

---

## Ekran Görüntüleri (Screenshots)

![Giriş Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094618.png>)
![Ana Ekran](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094637.png>)
![Teklifler Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094648.png>)
![Yeni Teklif Oluştur Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094750.png>)
![Müşteriler Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094820-1.png>)
![Ürünler Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094836.png>)
![Çalışanlar Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094905.png>)

### Canlı PDF Editörü ve Tasarım Yönetimi

![PDF Şablonları Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094913.png>)
![PDF Şablon Oluşturma Ekranı](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 095003.png>)
![alt text](<ekrangoruntuleri/Ekran görüntüsü 2026-05-21 094714.png>)

## Hızlı Kurulum (Getting Started)

Sistemi yerel ortamınızda ayağa kaldırmak için sırasıyla aşağıdaki adımları takip edin:

1.  **Veritabanı ve Sunucu:** `backend` dizinine giderek veritabanı bağlantılarını yapılandırın ve API'yi başlatın.
2.  **Kullanıcı Arayüzü:** Sunucu aktif olduktan sonra `frontend` dizinine geçerek Flutter uygulamasını çalıştırın.

Detaylı kurulum adımları alt dizinlerdeki README dosyalarında yer almaktadır.
