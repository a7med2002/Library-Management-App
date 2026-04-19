# 📚 Library Management System

A cross-platform **Flutter application** designed to manage library operations efficiently.  
Built with modern technologies like **Firebase**, **ObjectBox**, and **GetX**, this project combines cloud-based authentication, local persistence, and a clean architecture to deliver a robust solution for library and printing services.

---

## 🚀 Project Overview
The **Library Management System** is a mobile-first application tailored for **Dar Al-Meqdad Library & Printing House**.  
It provides tools for managing users, books, and transactions with support for **Arabic localization** and **right-to-left (RTL)** UI design.

---

## 🛠 Tech Stack
- **Frontend:** Flutter, Dart  
- **State Management:** GetX  
- **Backend Services:** Firebase (Auth, Firestore, Storage)  
- **Local Database:** ObjectBox  
- **Utilities:** PDF generation, Printing, Excel export, File picker  
- **UI/UX:** Custom fonts (Tajawal), SVG support, RTL layout  

---

## 🏗 Architecture
- **Core Layer:** Routes, Services, Models  
- **Data Layer:** Firebase integration + ObjectBox persistence  
- **Presentation Layer:** Flutter UI with GetX controllers  
- **Localization:** Arabic-first with RTL support  
- **Configuration:** Firebase options auto-generated via FlutterFire CLI  

---

## ✨ Features
- 🔐 **Authentication**: Firebase Auth + Google Sign-In  
- 📦 **Local Persistence**: ObjectBox for offline-first storage  
- 🌍 **Localization**: Arabic language support with RTL layout  
- 📄 **Document Handling**: PDF generation, printing, and Excel export  
- 🔎 **Search & Query**: Firestore integration for scalable queries  
- 🎨 **Custom UI**: Tajawal font, splash screen, and app icons  

---

## 🧪 Testing
- Unit tests with **flutter_test**  
- Linting enforced via **flutter_lints**  
- ObjectBox schema validation with **build_runner**  

---

## 📂 Folder Structure
    library_managment/
    │
    ├── android/              # Android-specific configuration
    ├── ios/                  # iOS-specific configuration
    ├── lib/
    │   ├── Core/             # Routes, Services, Models
    │   ├── firebase_options.dart
    │   ├── main.dart         # Entry point
    │   ├── objectbox-model.json
    │   └── objectbox.g.dart
    ├── assets/
    │   ├── fonts/            # Custom fonts (Tajawal)
    │   └── images/           # App images/icons
    ├── pubspec.yaml          # Dependencies
    └── analysis_options.yaml # Linting rules

---

## 🚀 How to Run the Project

1. **Clone the repository**  
- git clone https://github.com/a7med2002/betweener_app.git

2. **Install dependencies** 
- flutter pub get

3. **Run the app**
- flutter run

---

## 🌐 Social Links
- 👨‍💻 Developer: [ِAhmed Meqdad]
- 📧 Email: [ahmd2002mqdad@gamil.com]
- 💼 LinkedIn: [linkedin.com/in/ahmed-meqdad](https://www.linkedin.com/in/ahmedmeqdad0)
