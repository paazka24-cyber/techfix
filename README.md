# TechFix: Device Repair & Technician Booking System

A Flutter mobile app where customers request repairs for electronic devices and technicians accept and complete them. Admins manage users, requests and categories. One app, three roles, built with Flutter and Firebase.

## Features

- **Authentication:** register, login, Google sign-in, forgot password, email verification, logout
- **Role-based access:** customer, technician and admin each get their own screens
- **Repair requests (CRUD):** create with photos and a video, track progress, cancel
- **Technicians:** profiles, ratings, accept/reject requests, update repair status
- **Reviews:** 1 to 5 star ratings after a completed repair
- **Real-time chat:** customer and technician, with read receipts
- **Notifications:** in-app notifications and FCM token setup
- **Admin dashboard:** overview, users and roles, requests, categories
- **UI:** Material 3, light and dark mode

## Tech stack

Flutter, Dart, Riverpod, Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging, Cloudinary (media), VS Code, Git, GitHub.

## Architecture

`Screen → Provider → Repository → Service → Firebase`

```
lib/
  core/          theme and constants
  models/        data classes
  services/      direct Firebase/Cloudinary calls
  repositories/  app-level data operations
  providers/     Riverpod providers
  routes/        AuthGate (role-based navigation)
  screens/       auth, customer, technician, admin, chat, notifications
  widgets/       reusable UI pieces
```

## Documentation

See the `docs/` folder: [SRS](docs/SRS.md), [Database design and ERD](docs/database_design.md), [Use cases](docs/use_cases.md), [Test plan](docs/test_plan.md).

## Setup

1. Install Flutter and run `flutter doctor`.
2. Clone the repo and run `flutter pub get`.
3. Create a Firebase project, enable **Email/Password** and **Google** sign-in, and create a **Firestore** database.
4. Install the FlutterFire CLI and run `flutterfire configure` to generate `lib/firebase_options.dart`.
5. Publish the Firestore rules described in `docs/database_design.md`.
6. Create a free Cloudinary account and an **unsigned** upload preset named `techfix_unsigned`. Put your cloud name in `lib/services/storage_service.dart`.
7. Run `flutter run -d chrome` (or pick an Android device).

## Creating technicians and admins

New accounts are always customers. To create an admin, set `role` to `admin` on your user document in the Firestore console. The admin can then promote others from the dashboard.

## Known limitations

- Automatic server-side push delivery needs Cloud Functions (Firebase Blaze plan). The app stores FCM tokens and creates notification documents so it can be added later.
- Cloudinary uploads are unsigned; production should use signed uploads.

## Author

[Amin, Apdirizak, Apthifatah, Huzein], Software Engineering, [Abaarso Tech university]
