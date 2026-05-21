# Emar Offer - Frontend (Flutter Cross-Platform App)

Bu modül, projenin web ve mobil platformlarda kusursuz çalışan kullanıcı arayüzünü (UI/UX) oluşturmaktadır. Tek kod tabanından maksimum performans elde etmek amacıyla **Flutter & Dart** ekosistemi kullanılmıştır.

## Tasarım Yaklaşımı ve Responsive Mimari

Kullanıcı deneyimini (UX) en üst seviyede tutmak için **Responsive Yerleşim** kuralları uygulanmıştır. Uygulama, ekran genişliğini anlık ölçerek arayüzü şekillendirir:

- **Masaüstü/Web:** Geniş ekran alanları avantajıyla çok sütunlu gelişmiş veri tabloları, split-screen (bölünmüş ekran) PDF editörü ve yan paneller aktif olur.
- **Mobil:** Yatay kaydırma (horizontal scroll) zorunluluğunu kaldıran, tek parmakla yönetilebilir dikey kart yapısı (`TeklifMobilKarti`, `MusteriMobilKarti`), sağdan açılır çekmeceler (`endDrawer`) ve alt sayfalar devreye girer.

## Önemli Paketler ve Görevleri

- **`printing` & `pdf`:** Uygulama içi verileri ham byte'lara dönüştürerek canlı PDF render eder, yazdırma ve cihaz hafızasına indirme yeteneği sunar.
- **`image_picker`:** Kurumsal kimlik ayarlarında cihaz galerisinden veya kameradan şirket logosu seçilmesini sağlar.
- **`google_fonts`:** PDF motorunun dinamik tipografi yapısını desteklemek üzere font yüklemelerini yönetir.

## Modüler Klasör Mimarisi

- `screens/` -> Görsel ekranların ana sayfaları (Teklifler, Müşteriler, Şablon Düzenleyici).
- `widgets/` -> Performans optimizasyonu için parçalanmış, responsive duyarlı reusable (tekrar kullanılabilir) alt bileşenler.
- `services/` -> API servis katmanı; HTTP protokolleri üzerinden sunucuyla asenkron iletişimi sağlar.

## Başlatma Komutları

```bash
flutter pub get
flutter run
```
