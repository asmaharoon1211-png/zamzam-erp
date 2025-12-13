# Zamzam ERP Solution

A comprehensive Mobile ERP solution for Inventory, Sales (POS), Purchases, and Logistics. Built with Flutter and Firebase.

## Features
- **Inventory Management**: Track products, variants, stock levels, and images.
- **Point of Sale (POS)**: Quick checkout, barcode ready, cart management.
- **Purchases**: manage suppliers and stock-in transactions.
- **Couriers & COD**: Assign couriers to orders for logistics tracking.
- **Reports**: Dashboard analytics (Sales, Stock Value) and PDF Invoices.
- **Multi-User**: Admin (Full Access) and Staff (POS Only).
- **Localization**: Urdu (Default) and English.
- **Notifications**: Push support and WhatsApp integration.

## Getting Started

### Prerequisites
- Flutter SDK (3.16+)
- Firebase Project configured (GoogleService-Info.plist / google-services.json)

### Installation
1.  Clone the repository.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Generate translations:
    ```bash
    flutter gen-l10n
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

## Building for Release (Android)
To build a release APK manually:
```bash
flutter build apk --release
```

## CI/CD
This project uses GitHub Actions to automatically build the APK on every push to `main`.
1.  Push your code to GitHub.
2.  Go to the **Actions** tab.
3.  Wait for the `Flutter Build` workflow to complete.
4.  Download the `release-apk` artifact.

## User Roles
- **Staff**: Default role for new signups. Limited access.
- **Admin**: Full access. To promote a user, manually edit their document in the `users` Firestore collection and set `role: 'admin'`.
