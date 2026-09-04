# Derslik

Öğretmenlerin fotoğraflardan sınav ve ders föyü hazırlamasını sağlayan, offline-first Flutter uygulaması.

## Ürün kapsamı

- Android ve iOS için tek Flutter kod tabanı
- Kamera veya galeriden içerik alma
- Görseli kırpma ve temizleme
- Cihaz üzerinde OCR ve metin düzenleme (iOS'ta Apple Vision, Android'de ML Kit)
- İçeriği metin, görsel veya ikisi olarak kullanma
- Sınav ve ders föyü PDF'i oluşturma, önizleme ve paylaşma
- Taslakları cihazda saklama; internet ve hesap gerektirmeme

## Geliştirme durumu

İlk ürün akışı hazır: ana ekran, belge türü seçimi, belge bilgileri, kamera/galeri üzerinden sayfa ekleme, kırpma, cihaz üzerinde OCR, OCR düzenleme, önizleme ve PDF dışa aktarma.

## Mimari

Kararların ve katman sınırlarının güncel kaydı [docs/architecture.md](docs/architecture.md) dosyasındadır.

```text
Presentation -> Application -> Domain -> Infrastructure
```

Platforma özel kamera, OCR, dosya ve paylaşım kodları Infrastructure katmanında tutulur. Orijinal görsel her zaman korunur; OCR sonucu düzenlenebilir bir yardımcı çıktı olarak ele alınır.

## Yerel geliştirme

Flutter SDK kurulduktan sonra:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Sonraki adımlar

- Yerel taslak kaydı ve son belgeler listesi
- Sayfa sıralama ve sürükle-bırak düzenleme
- Görsel temizleme ve otomatik belge kenarı algılama
- Sınav soru numarası ve puan alanları
