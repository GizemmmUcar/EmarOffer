# Teklif Yönetim Sistemi - Frontend (Flutter)

Bu modül, projenin son kullanıcı arayüzünü (UI) oluşturmaktadır. Çapraz platform (Web ve Mobil) desteği sağlamak ve aynı kod tabanını kullanmak amacıyla **Flutter** çerçevesi (framework) tercih edilmiştir.

## Tasarım Yaklaşımı

Arayüz geliştirilirken minimalist ve kullanıcı dostu bir deneyim (UX) hedeflenmiştir. Uygulama, cihazın ekran genişliğini dinamik olarak ölçerek tasarımını günceller:

- Masaüstü/Web görünümlerinde geniş veri tabloları kullanılır.
- Mobil görünümlerde ise yatay kaydırma ihtiyacını ortadan kaldıran, alt alta dizilmiş detaylı "Kart (Card)" yapıları tercih edilmiştir.

## Kullanılan Teknolojiler ve Paketler

- **Flutter & Dart:** Uygulamanın temel programlama dili ve altyapısı.
- **printing:** Uygulama içi verilerin PDF formatına dönüştürülmesi ve önizlenmesi.
- **image_picker:** Ayarlar bölümünde cihazdan şirket logosu seçimi yapılması.

## Klasör Mimarisi

Proje içi bağımlılıkları azaltmak için modüler bir yapı kullanılmıştır:

- `screens/`: Uygulamanın ana ekran görünümleri (Teklifler, Ürünler vb.).
- `widgets/`: Birden fazla ekranda tekrar tekrar kullanılan UI bileşenleri (Menü, Teklif Satırı).
- `services/`: Node.js API'sine HTTP istekleri atan ve veri alışverişini sağlayan katman.

## Başlatma Komutları

```bash
flutter pub get
flutter run
```
