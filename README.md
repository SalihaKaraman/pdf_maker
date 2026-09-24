# Maker

Öğretmenlerin fotoğraflardan sınav ve ders föyü hazırlamasını sağlayan, offline-first Flutter uygulaması.

## Ürün kapsamı

- Android ve iOS için tek Flutter kod tabanı
- Kamera veya galeriden içerik alma
- Soruyu ve soruya ait şekli ayrı ayrı kırpma
- Cihaz üzerinde OCR ve metin düzenleme (iOS'ta Apple Vision, Android'de ML Kit)
- OCR metnini PDF oluşturmadan önce tekrar düzenleme
- Üs, logaritma, kök, kesir ve pi için matematik şablonları
- Birden fazla soruyu aynı PDF sayfasında birleştirme
- Soru veya konu türünü öğe eklerken seçme
- Görsel konumunu üst, sol veya sağ olarak seçme
- Sınavlarda boş cevap alanı ekleme
- Sınav / kitap formatı, 1-2 sütun ve öğrenci bilgi alanları
- Öğeden önce yeni PDF sayfası başlatma
- Sorunun metnini ve seçilen şeklini PDF'e aktarma
- Türkçe karakter destekli PDF fontları
- PDF önizleme ve işletim sisteminin paylaşım/çıktı ekranı
- Yerel taslak kaydı ve son taslakların ana ekranda listelenmesi

## Geliştirme durumu

Çalışan MVP akışı: ana ekran, belge türü seçimi, sayfa düzeni ayarları, kamera/galeri üzerinden soru veya konu ekleme, soru ve şekil kırpma, cihaz üzerinde OCR, metin düzenleme, matematik ifadeleri ekleme, öğe bazlı görsel konumu ve cevap alanı, manuel sayfa kırımı, yerel taslak kaydı, önizleme ve PDF dışa aktarma.

## Mevcut kullanım akışı

1. `Belge oluştur` ile sınav veya ders föyü seçilir.
2. Galeriden ya da kameradan ilk soru eklenir.
3. `Metni çıkar` ile OCR çalıştırılır ve sonuç düzenlenir.
4. Matematik ifadeleri için üs, logaritma, kök, kesir veya pi şablonu eklenebilir.
5. `Şekli seç` ile sorudaki şekil ayrı olarak kırpılır.
6. `Başka soru ekle` ile sorular tek tek aynı belgeye eklenir.
7. Önizleme ekranında her soru tekrar düzenlenebilir ve şekil sürüklenebilir.
8. PDF oluşturulduğunda sorular aynı sayfada metin ve seçilen şekilleriyle yer alır.
9. Önizleme açıldığında belge başlığı, türü ve soru metinleri yerel taslak olarak kaydedilir.

Sayfa düzeni seçenekleri belge başlangıcında belirlenir; yeni her öğe eklenirken kendi türü, görsel konumu, cevap alanı ve sayfa kırımı ayrıca seçilebilir.

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

## Henüz tamamlanmayanlar

- Taslaklara ait görsel dosyalarının kalıcı belge modeline taşınması
- Görsel temizleme ve otomatik belge kenarı algılama
- Sınav soru puanı, öğrenci bilgileri ve cevap alanları
- Daha gelişmiş matematik formülü düzenleme ve gerçek matematik dizgisi

## Platform notları

- iOS OCR, simulator uyumluluğu için Apple Vision üzerinden çalışır.
- Android OCR, `platform_text_recognition` aracılığıyla Google ML Kit kullanır.
- PDF metni için `assets/fonts/ArialUnicode.ttf` ve `assets/fonts/ArialBold.ttf` kullanılır; bu fontlar Türkçe karakterlerin korunması için projeye dahil edilmiştir.
- Kamera izinleri gerçek cihazda verilmelidir. iOS simulator üzerinde galeri akışı daha güvenilir test edilir.
