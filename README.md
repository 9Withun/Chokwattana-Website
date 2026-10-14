# project

A Flutter application for the ChokWattana Home Center website.

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## API

The app talks to the ChokWeb PHP/MySQL REST API at
`http://localhost/chokweb_database/api.php`
(single endpoint, `resource` query parameter selects the data type).
Override the API folder URL at build time when using another host:

```sh
flutter build web --dart-define=API_BASE_URL=https://<domain>/<folder>
```

| Feature | Request | Token | Code |
|---|---|---|---|
| Products | `GET api.php` | none | `ProductService.fetchProducts` |
| Active banners | `GET api.php?resource=banners&active=1` | none | `BannerService.fetchBanners` |
| Register | `POST api.php?resource=auth&action=register` | none | `AuthService.register` |
| Login | `POST api.php?resource=auth&action=login` | none | `AuthService.login` |
| Current member | `GET api.php?resource=me` | member Bearer token | `AuthService.me` |
| Logout | `POST api.php?resource=auth&action=logout` | member Bearer token | `AuthService.logout` |
| User list (admin) | `GET api.php?resource=users` | `API_READ_TOKEN` | `UserService.fetchUsers` |

Notes:

- Every response is `{"status": "success"|"error", "message": ...}`; the app
  surfaces the server `message` (e.g. `409` duplicate phone/username, `429`
  too many login attempts).
- Login accepts a phone number, member ID or username in one `login` field.
  The member token is kept in `flutter_secure_storage` and restored at start.
- Registration rules mirror the server: username <= 20, password 8-72 bytes,
  phone 1-10 digits, email <= 50.
- `API_READ_TOKEN` (admin user list) is passed with
  `--dart-define=API_READ_TOKEN=...`; do not ship it in a public web build.

The Flutter UI is read-only for products and banners. Do not add write
operations until a server-side authenticated proxy is connected; never embed
`API_WRITE_TOKEN` in a Flutter build.
