# CineLog

CineLog, TMDB API üzerinden popüler filmleri listeleyen, film araması yapan,
film detaylarını gösteren ve favori filmleri cihazda saklayan bir Flutter
uygulamasıdır.

## Özellikler

- Popüler filmleri sayfalı olarak listeleme
- Film adına göre arama yapma
- Film detaylarını ve önerilen filmleri görüntüleme
- Favorilere film ekleme ve favorilerden kaldırma
- Favorileri Hive ile yerel olarak saklama
- TMDB API key kontrolü ve eksik key durumunda uyarı ekranı

## Kullanılan Teknolojiler

- Flutter
- Dart
- Flutter Riverpod
- Dio
- Hive / Hive Flutter
- Cached Network Image
- TMDB API

## Kurulum

Önce projeyi klonlayın ve proje klasörüne girin:

```bash
git clone <repo-url>
cd cinelog
```

Bağımlılıkları yükleyin:

```bash
flutter pub get
```

Flutter kurulumunuzu kontrol etmek için:

```bash
flutter doctor
```

## TMDB API Key Alma

Bu proje film verilerini The Movie Database (TMDB) API üzerinden alır. Uygulamayı
çalıştırmak için bir TMDB API key gerekir.

1. https://www.themoviedb.org adresinden hesap oluşturun veya giriş yapın.
2. Profil menüsünden `Settings > API` sayfasına gidin.
3. API başvurusu yaparak bir API key oluşturun.
4. Oluşturulan API key değerini uygulamayı çalıştırırken `TMDB_API_KEY` olarak
   verin.

## API Key Nasıl Eklenir?

Projede API key `lib/core/env/env.dart` içinde şu şekilde okunur:

```dart
static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
```

Bu nedenle API key kod içine yazılmaz. Uygulama çalıştırılırken
`--dart-define` parametresiyle verilir.

Android/iOS/emulator için:

```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

Belirli bir cihaz seçerek çalıştırmak için:

```bash
flutter devices
flutter run -d <device-id> --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

Release build alırken de aynı parametre verilmelidir:

```bash
flutter build apk --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

```bash
flutter build ios --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

API key verilmezse uygulama ana ekrana geçmeden eksik API key uyarısı gösterir.

## Çalıştırma

Bağımlılıklar yüklendikten ve API key hazırlandıktan sonra:

```bash
flutter run --dart-define=TMDB_API_KEY=your_tmdb_api_key
```

Testleri çalıştırmak için:

```bash
flutter test
```

Kod analizini çalıştırmak için:

```bash
flutter analyze
```

## Proje Yapısı

Proje feature-first bir klasörleme ile düzenlenmiştir:

```text
lib/
  core/
    constants/
    env/
    errors/
    network/
  features/
    favorites/
      data/
      domain/
      presentation/
    movies/
      data/
      domain/
      presentation/
  widgets/
```

- `core`: API sabitleri, network istemcisi, ortam değişkenleri ve ortak hata
  yapıları.
- `features/movies`: Film listeleme, arama, detay ve öneri akışları.
- `features/favorites`: Favori filmlerin yerel saklanması ve yönetimi.
- `presentation/providers`: Riverpod provider ve notifier sınıfları.

## State Management Seçimi

Projede state management için `flutter_riverpod` tercih edilmiştir.

Bu seçimin başlıca nedenleri:

- `ProviderScope` ile uygulama genelinde bağımlılıkları yönetmek kolaydır.
- Repository, datasource ve network client gibi katmanlar provider olarak açık
  şekilde tanımlanabilir.
- `NotifierProvider` ile popüler filmler, arama sonuçları ve favoriler gibi
  ekran state'leri tek noktadan yönetilebilir.
- `FutureProvider.family` ile film detayı gibi parametre alan asenkron veriler
  sade ve okunabilir şekilde modellenebilir.
- Widget ağacına `BuildContext` üzerinden bağımlı olmadığı için test edilebilirlik
  ve yeniden kullanılabilirlik artar.
- Küçük ve orta ölçekli Flutter uygulamalarında Bloc'a göre daha az boilerplate
  ile aynı ayrıştırmayı sağlar.

Bu projede Riverpod şu alanlarda kullanılır:

- `popularMoviesProvider`: Popüler filmler, loading/error state'i ve pagination.
- `searchMoviesProvider`: Arama sorgusu, sonuçlar, son aramalar ve loading/error
  state'i.
- `movieDetailProvider`: Film detayını ve önerileri film id'sine göre yükleme.
- `favoriteMoviesProvider`: Favori filmleri Hive üzerinden okuyup güncel tutma.
- Repository ve datasource provider'ları: Data katmanını presentation katmanından
  ayırma.

## Veri Kaynağı ve Yerel Saklama

Uzak veri kaynağı olarak TMDB API kullanılır. HTTP istekleri `DioClient` üzerinden
yapılır ve API key her isteğe query parameter olarak eklenir.

Favori filmler Hive ile cihazda saklanır. Uygulama başlangıcında Hive initialize
edilir ve favoriler için kullanılan box açılır:

```dart
await Hive.initFlutter();
await Hive.openBox<dynamic>(StorageConstants.favoriteMoviesBox);
```

## Notlar

- API key'i doğrudan kaynak koda eklemeyin.
- Gerçek API key'i commit etmeyin.
- Release build alırken `--dart-define=TMDB_API_KEY=...` parametresini tekrar
  vermeyi unutmayın.
