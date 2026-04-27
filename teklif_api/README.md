# Teklif Yönetim Sistemi - Backend (Node.js API)

Bu modül, uygulamanın Frontend tarafıyla iletişim kuran ve veritabanı işlemlerini yöneten Backend servisidir. Mimari, RESTful standartlarına uygun olarak tasarlanmıştır.

## Kullanılan Teknolojiler

- **Node.js & Express.js:** API uç noktalarının (endpoints) oluşturulması ve isteklerin yönlendirilmesi.
- **SQL Server (MSSQL):** Sisteme ait tüm verilerin güvenli ve ilişkisel bir şekilde saklandığı veritabanı yönetim sistemi.

## Temel API Uç Noktaları

Geliştirilen servis üzerinden sağlanan temel veri akışları:

- `/api/teklifler`: Tekliflerin veritabanına eklenmesi, listelenmesi ve güncellenmesi.
- `/api/urunler`: Ürün kayıtlarının (CRUD) yönetimi.
- `/api/musteriler`: Firma ve müşteri bilgilerinin tutulması.
- `/api/sirket`: Şirket logolarının (Base64 formatında) ve profil verilerinin işlenmesi.

## Kurulum ve Yapılandırma

Sistemi ayağa kaldırmak için veritabanı bağlantı dizenizi (Connection String) kendi SQL Server bilgilerinize göre güncellemeniz gerekmektedir. Ardından aşağıdaki komutlarla sunucuyu başlatabilirsiniz:

```bash
npm install
npm start
```
