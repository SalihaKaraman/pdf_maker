# Mimari Kararlar

Bu belge, Sınav ve Ders Föyü PDF Maker uygulamasının ürün ve teknik mimarisini tanımlar.

## Ürün kapsamı

Uygulama, öğretmenin fotoğrafladığı veya galeriden seçtiği eğitim içeriklerini düzenleyip iki çıktı türünden birine dönüştürür:

- **Sınav:** soru listesi, puan, öğrenci bilgileri ve cevap alanları.
- **Ders föyü:** konu anlatımı, başlıklar, metinler, görseller, tablolar ve şekiller.

İlk sürüm Android ve iOS için Flutter ile geliştirilecek ve temel akışlar tamamen offline çalışacaktır.

## Offline-first ilkesi

- Görsel alma ve işleme cihazda yapılır.
- OCR cihaz üzerinde çalışır.
- Taslaklar ve belgeler yerel veritabanında saklanır.
- PDF cihazda oluşturulur.
- Paylaşım işletim sisteminin yerel paylaşım ekranı üzerinden yapılır.

Bulut senkronizasyonu ilk sürümün zorunlu parçası değildir.

## Katmanlar

```text
Presentation
  Ekranlar, formlar, sürükle-bırak sıralama, önizleme

Application
  Belge oluşturma, içerik seçimi, OCR iş akışı, PDF hazırlama

Domain
  Document, ContentItem, Exam, Handout ve çıktı kuralları

Infrastructure
  Kamera/galeri, görsel işleme, OCR, yerel veritabanı, PDF ve paylaşım
```

Platforma özgü kod yalnızca Infrastructure katmanında tutulmalıdır.

## İçerik modeli

Her içerik parçası OCR metni, orijinal görsel yolu, kırpılmış/temizlenmiş görsel yolu, içerik türü, sıra, puan, düzenlenmiş metin ve PDF'e eklenme terciğini taşıyabilir.

Orijinal görsel silinmeden saklanır. OCR matematik formülleri, semboller, tablolar ve şekillerde hatalı olabileceği için kullanıcı metni düzeltebilir veya parçayı görsel olarak ekleyebilir.

## Önerilen proje yapısı

```text
lib/
  app/
  core/
  features/
    documents/
    scanner/
    ocr/
    pdf_export/
```

Özellikler kendi domain, data ve presentation kodlarını mümkün olduğunca birlikte taşır. Paylaşılan kod `core` altında kalır.

## İlk geliştirme sırası

1. Ana sayfa, belge türü seçimi ve belge bilgileri
2. Kamera/galeri akışı ve sayfa önizleme
3. Kırpma ve görsel temizleme
4. OCR ve metin düzenleme
5. Yerel belge modeli ve taslak kaydı
6. İçerik havuzu ve sıralama
7. Sınav/föy PDF renderer'ları
8. Önizleme, kaydetme ve paylaşma
9. Android ve iOS cihaz testleri

## Doğrulama kriterleri

- İnternet kapalıyken yeni belge oluşturulabilmeli.
- Aynı akış Android ve iOS'ta çalışmalı.
- OCR hatalı içerik orijinal görsel olarak PDF'e eklenebilmeli.
- Uygulama kapanıp açıldığında taslak kaybolmamalı.
- Metin ve görsel ağırlıklı PDF'ler önizlenebilmeli ve paylaşılabilmeli.
