# Study Guide

A Flutter mobile app that helps high school students choose the right engineering major. Students take a weighted quiz, browse detailed major profiles, and calculate their weighted admission percentage — while an admin panel lets staff manage majors, quiz questions/weights, and view usage statistics.

## ✨ Features

**For students**
- Browse engineering majors with descriptions, requirements, career paths, and a link to the study plan (PDF).
- Take a quiz that scores answers against a per-major weight system to recommend the best-fit major(s).
- Calculate the weighted admission percentage (high school GPA 30% + Qudrat 30% + Tahsili 40%).
- View an About/FAQ screen.
- Simple student sign-in/registration to track quiz history.

**For admins**
- Secure admin login and dashboard with quick stats (majors count, questions count).
- Full CRUD for engineering majors, including uploading a major's image.
- Full CRUD for quiz questions, with weight configuration (0–3) per option and per major.
- Statistics screen: number of unique students and top selected majors.
- Real-time UI updates across screens via a change-notification stream.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart SDK ^3.9.2)
- **Local database**: SQLite via `sqflite`
- **Key packages**: `fl_chart` (statistics charts), `image_picker` + `path_provider` + `permission_handler` (major images), `url_launcher` (opening study plan PDFs), `connectivity_plus`, `font_awesome_flutter`, `auto_size_text`

## 🚀 Getting Started

### Requirements
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (compatible with Dart ^3.9.2)
- Android Studio / Xcode (for Android/iOS builds) or a configured emulator/simulator/device

### Run locally
```bash
# install dependencies
flutter pub get

# run on a connected device/emulator
flutter run

# build a release APK
flutter build apk
```

## 📂 Project Structure

```
lib/
├── main.dart               # App entry point
├── models/                 # Data models (major, question, question weight, student)
├── database/                # SQLite schema & queries (database_helper.dart)
├── services/                 # Business logic layer (database_service.dart, quiz_service.dart, student_session.dart)
├── screens/                   # Student-facing screens (home, majors, quiz, result, calculator, about, login...)
├── widgets/                   # Shared widgets (custom_button, major_card, quiz_option, info_tile)
├── utils/                     # Constants and app colors
├── admin/                     # Admin panel (screens, widgets, utils)
└── docs/                       # Additional project documentation
assets/                          # Images and other static assets
```

## 📌 Usage

1. Launch the app and choose to sign in as a **student** or an **admin**.
2. As a student: enter your info, then from the home screen browse majors, take the recommendation quiz, or use the admission percentage calculator.
3. After completing the quiz, the app shows your top-matching major(s) based on the weighted scoring system, and saves the result for statistics.
4. As an admin: log in to the dashboard to manage majors and quiz questions/weights, and review usage statistics.
