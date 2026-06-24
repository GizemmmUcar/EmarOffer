# Emar Offer - Backend (Node.js RESTful API)

Bu modül, Emar Offer sisteminin iş mantığını yöneten, güvenlik ve veri doğruluğunu sağlayan, ilişkisel veritabanı katmanı ile kararlı bir köprü kuran arka yüz servisidir. **SaaS güvenlik duvarı** bu katmanda işletilmektedir.

## Kullanılan Teknolojiler

- **Node.js & Express.js:** API uç noktalarının (endpoints) performanslı ve asenkron yönetimi.
- **SQL Server (MSSQL):** Kurumsal verilerin ilişkisel standartlarda, indexlenmiş ve Multi-tenant izolasyonuna uygun şekilde saklanması.
- **Bcryptjs & JWT:** Şifreleme algoritmaları ve Çoklu Firma (Firma Kodu) erişim güvenlik kalkanı.
- **Multer & Nodemailer:** Sunucu tarafında PDF dosyalarının işlenmesi ve doğrudan ek (attachment) olarak müşterilere e-postalanması.
- **RESTful Standartları:** HTTP metotları (GET, POST, PUT, DELETE) ile modüler rotalama.

## Temel API Uç Noktaları (Endpoints)

Geliştirilen servis üzerinden sağlanan veri akış mimarisi (Tüm kilit rotalar JWT Middleware ile korunmaktadır):

- ` /kullanicilar/login` -> Firma Kodu ve şifre doğrulaması ile mühürlü Token üretimi.
- ` /firmalar` -> Sistem yönetimi, yeni firma oluşturma ve veritabanı izolasyonu işlemleri.
- ` /teklifler` -> Tekliflerin veritabanına işlenmesi, güncellenmesi, durum takibi ve listelenmesi.
- ` /mail-gonder` -> Nodemailer kullanılarak PDF belgelerinin arka plandan e-posta ile iletilmesi.
- ` /urunler` & `/musteriler` -> Müşteri ve Ürün havuzunun CRUD operasyonları.
- ` /sirket` -> Şirket profili, banka bilgileri ve Base64 formatında logo işleme süreçleri.

## Kurulum ve Yapılandırma

1. Bağımlılıkları yükleyin:
   ```bash
   npm install
   ```
