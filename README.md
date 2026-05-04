# Teklif Yönetim Sistemi

Bu proje, işletmelerin müşteri, ürün ve teklif süreçlerini tek bir merkezden yönetebilmesi amacıyla geliştirilmiş uçtan uca (Full-Stack) bir CRM uygulamasıdır. Sistem, kod yönetiminin kolaylaştırılması ve modüler bir yapı elde edilmesi amacıyla **Backend** ve **Frontend** olmak üzere iki bağımsız parça halinde tasarlanmıştır.

## Proje Yapısı

- **`teklif_api`**: Sistemin sunucu ve veritabanı (Backend) işlemlerini yürüten Node.js tabanlı RESTful API servisidir.
- **`teklif_app`**: Kullanıcı etkileşimini sağlayan (Frontend), Flutter ile geliştirilmiş platformlar arası (Web ve Mobil) arayüz uygulamasıdır.

## Temel Özellikler

- **Dinamik Hesaplama:** Teklif oluşturma sürecinde eklenen ürünlerin miktar, birim fiyat ve iskonto hesaplamaları anlık olarak yapılır.
- **Duyarlı (Responsive) Tasarım:** Uygulama arayüzü; geniş ekranlarda yatay paneller, mobil cihazlarda ise dikey kart yapıları sunarak ekran boyutuna otomatik uyum sağlar.
- **PDF Oluşturma:** Hazırlanan teklifler tek tıkla PDF formatına dönüştürülerek cihazda görüntülenebilir.

## Kurulum ve Çalıştırma

Projeyi yerel ortamda test etmek için:

1. `teklif_api` klasöründeki veritabanı bağlantı ayarlarını yapılandırarak sunucuyu başlatın.
2. Sunucu çalıştıktan sonra `teklif_app` klasörüne geçerek Flutter uygulamasını derleyin.
