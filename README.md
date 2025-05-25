# 🧾 Restaurant Management System

Bu proje, Flutter ile geliştirilen modern ve kullanıcı dostu bir **Restoran Yönetim Sistemi** uygulamasıdır. Kullanıcılar yemekleri görüntüleyebilir, sepete ürün ekleyebilir, masa seçimi yapabilir ve farklı ödeme yöntemleriyle sipariş oluşturabilir.

---
![Anasayfa](restaurant_management.jpg)
## 🚀 Özellikler
- 🔐 Kullanıcı girişi (kullanıcı adı & şifre)
- 🍽️ Kategorilere göre yemek ve içecek listeleme
- 🖼️ Görsel destekli ürün kartları
- 🛒 Sepete ürün ekleme, çıkarma ve adet değiştirme
- 💳 Ödeme tipi seçimi: Kredi Kartı, Nakit, Veresiye
- 📦 Sipariş türü seçimi: Yerinde Yemek (Dine In), Paket Servis (To Go)
- 🧾 Otomatik KDV hesaplama (%10, ayarlanabilir)
- 🧹 Sipariş tamamlandığında sepeti ve masa seçimini sıfırlama
- 🪑 Masa yönetimi (dolu/boş durumu)
- 🕑 Sipariş geçmişi ve detayları
- 🌙 Modern, sade ve responsive kullanıcı arayüzü

---

## 🧱 Kullanılan Teknolojiler
- **Flutter** – UI geliştirme
- **Dart** – Programlama dili
- **Provider** – Durum yönetimi
- **Material Design** – UI bileşenleri
- **Local Database (sqflite)** – Sipariş ve ürün verileri için
- **Asset Management** – Görsel kullanımı

---

## ⚙️ Kurulum ve Çalıştırma

1. **Bağımlılıkları yükleyin:**
   ```sh
   flutter pub get
   ```
2. **Projeyi başlatın:**
   ```sh
   flutter run
   ```
   veya belirli bir platformda çalıştırmak için:
   ```sh
   flutter run -d chrome   # Web
   flutter run -d windows  # Windows
   flutter run -d macos    # MacOS
   flutter run -d linux    # Linux
   flutter run -d android  # Android
   flutter run -d ios      # iOS
   ```

> **Not:** Web platformunda veritabanı işlemleri için tarayıcıda IndexedDB kullanılır. Mobil ve masaüstü platformlarda ise SQLite kullanılır.

---

## 📁 Proje Yapısı

- `lib/` – Uygulama ana kodları
  - `models/` – Veri modelleri (Ürün, Sepet, Sipariş vb.)
  - `providers/` – Durum yönetimi sağlayıcıları
  - `screens/` – Ekranlar (Giriş, Sepet, Ödeme, Geçmiş vb.)
  - `services/` – Veritabanı ve iş mantığı servisleri
  - `helpers/` – Yardımcı fonksiyonlar ve veritabanı işlemleri
  - `widgets/` – Tekrar kullanılabilir widgetlar
- `assets/` – Ürün görselleri ve diğer medya dosyaları

---

## 💡 Katkı ve Geliştirme

Katkıda bulunmak için lütfen bir fork oluşturun ve pull request gönderin. Hataları veya önerileri [issue](https://github.com/) olarak bildirebilirsiniz.

---



