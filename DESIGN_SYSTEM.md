# Lector Tasarım Sistemi

Bu döküman, Lector uygulamasının görsel tutarlılığını sağlamak için kullanılan temel tasarım kurallarını ve sabitlerini içerir.

## 1. Renk Paleti

| Renk | Kullanım Alanı | Hex Kodu | Önizleme |
| :--- | :--- | :--- | :--- |
| **Primary** | Ana marka rengi, butonlar, başlıklar | `#4A2C2A` | ![#4A2C2A](https://placehold.co/30x30/4A2C2A/4A2C2A.png) |
| **Accent** | Vurgu rengi, yıldızlar, ikonlar | `#D4AF37` | ![#D4AF37](https://placehold.co/30x30/D4AF37/D4AF37.png) |
| **Background** | Ana ekran arka planı | `#F5F5DC` | ![#F5F5DC](https://placehold.co/30x30/F5F5DC/F5F5DC.png) |
| **Surface** | Kartlar ve panellerin arka planı | `#FFFFFF` | ![#FFFFFF](https://placehold.co/30x30/FFFFFF/FFFFFF.png) |
| **Text Primary** | Ana metinler | `#333333` | ![#333333](https://placehold.co/30x30/333333/333333.png) |
| **Text Secondary**| İkincil metinler, ipuçları | `#757575` | ![#757575](https://placehold.co/30x30/757575/757575.png) |

## 2. Tipografi

- **Başlık Fontu:** Lora (Google Fonts)
- **Gövde Fontu:** Inter (Google Fonts)

| Stil Adı | Font | Boyut | Ağırlık | Kullanım |
| :--- | :--- | :--- | :--- | :--- |
| `headline1` | Lora | 28 | Bold | Ana ekran başlıkları |
| `headline2` | Lora | 22 | Bold | Sayfa başlıkları (AppBar) |
| `headline3` | Lora | 18 | Bold | Kart içi başlıklar |
| `bodyLarge` | Inter | 16 | Normal | Uzun metinler, özetler |
| `bodyMedium`| Inter | 14 | Normal | Liste elemanları, standart metin |
| `bodySmall` | Inter | 12 | Normal | Alt yazılar, yazar adları |
| `button` | Inter | 14 | Bold | Buton metinleri |

## 3. Boyutlar ve Boşluklar

Uygulama genelinde 8.0 tabanlı bir boşluk sistemi kullanılır.

| Sabit Adı | Değer | Kullanım |
| :--- | :--- | :--- |
| `paddingSmall` | `8.0` | İkon ve metin arası gibi küçük boşluklar |
| `paddingMedium` | `16.0` | Genel container iç boşlukları, liste item araları |
| `paddingLarge` | `24.0` | Sayfa kenar boşlukları, büyük bölüm araları |
| `borderRadiusMedium` | `8.0` | Standart köşe yuvarlaklığı (kartlar, inputlar) |

## 4. Responsive tasarımlar 

Tasarımı responsive istediğim için iyileştirmeler yapabilirsin.