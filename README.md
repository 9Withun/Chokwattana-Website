# project

A Flutter application for the ChokWattana Home Center website.

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Product API

The app reads products from `http://100.119.18.68/chokweb_database/api.php`.
Override the API folder URL at build time when using another host:

```sh
flutter build web --dart-define=API_BASE_URL=http://127.0.0.1/chokweb_database
```

The app is currently read-only and only fetches/displays products. Product
management is not included in the Flutter UI. Do not add write operations until
a server-side authenticated proxy is connected; never embed API write
credentials in a Flutter web build.
