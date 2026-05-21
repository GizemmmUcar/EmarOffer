# Emar Offer - Backend (Node.js RESTful API)

Bu modül, Emar Offer sisteminin iş mantığını yöneten, güvenlik ve veri doğruluğunu sağlayan, ilişkisel veritabanı katmanı ile kararlı bir köprü kuran arka yüz servisidir.

## Kullanılan Teknolojiler

- **Node.js & Express.js:** API uç noktalarının (endpoints) performanslı ve asenkron yönetimi.
- **SQL Server (MSSQL):** Kurumsal verilerin ilişkisel standartlarda, indexlenmiş ve optimize edilmiş şekilde saklanması.
- **RESTful Standartları:** HTTP metotları (GET, POST, PUT, DELETE) ile modüler rotalama.

## Temel API Uç Noktaları (Endpoints)

Geliştirilen servis üzerinden sağlanan veri akış mimarisi:

- ` /api/teklifler` -> Tekliflerin veritabanına işlenmesi, güncellenmesi, durum takibi ve listelenmesi.
- ` /api/urunler` -> Ürün havuzunun yönetimi ve CRUD operasyonları.
- ` /api/musteriler` -> Firma, yetkili ve kurumsal müşteri bilgilerinin kaydı.
- ` /api/sirket` -> Şirket profili, banka bilgileri ve Base64 formatında logo işleme süreçleri.

## Kurulum ve Yapılandırma

1. Bağımlılıkları yükleyin:
   ```bash
   npm install
   ```
