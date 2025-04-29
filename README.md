# 📱 QR Code Scanner & Generator App (Flutter)

A lightweight and versatile **QR Code utility app** built with **Flutter**.  
This app allows users to easily **scan** QR codes using their device’s camera and **generate** QR codes from text, links, and other types of data. It also maintains a history of scans and generated codes for quick access and reuse.

---

**@uthor Muhammad Abu-Bakr**

---

## 🚀 Overview

This project focuses on providing a simple and efficient user experience for both **scanning** and **generating** QR codes.  
It demonstrates working with the device camera, dynamic QR generation, local storage, and sharing features in Flutter.

---

## ✨ Core Features

### 📷 QR Code Scanner
- Scan QR codes using the device’s camera
- Display scanned content (text, URLs, contact info, etc.)
- Options to:
  - Copy to clipboard
  - Share scanned content
  - Open links directly in browser

### 🛠️ QR Code Generator
- Input any text, links, or data
- Generate QR codes dynamically in real-time
- Download or share the generated QR code image

### 🕓 Scan & Generation History
- View a list of previous scans and generated QR codes
- Tap to view, copy, or reuse items
- Option to delete individual or all history records

---

## 🛠️ Tools & Packages Used

- **Camera Scanning**:  
  [`qr_code_scanner`](https://pub.dev/packages/qr_code_scanner) or [`mobile_scanner`](https://pub.dev/packages/mobile_scanner)
- **QR Code Generation**:  
  [`qr_flutter`](https://pub.dev/packages/qr_flutter)
- **Local Storage** (for history):  
  [`Hive`](https://pub.dev/packages/hive) or [`SharedPreferences`](https://pub.dev/packages/shared_preferences)
- **Image Saving**:  
  [`path_provider`](https://pub.dev/packages/path_provider) + [`screenshot`](https://pub.dev/packages/screenshot) or [`image_gallery_saver`](https://pub.dev/packages/image_gallery_saver)

---

## 🎯 Bonus Features (Optional / Future Plans)

- 📷 Scan QR codes from saved images (gallery support)
- 🌙 Dark mode for better usability
- 🗂️ Categorize QR codes (e.g., WiFi, URL, text, contact, location)
- 🚀 Auto-detect QR code type and suggest actions (e.g., open browser for URLs, add contacts for vCards)

---

## 🖌️ UI Suggestions

- **Home Screen**:  
  Tabs or Bottom Navigation Bar with "Scan", "Generate", and "History" sections.
  
- **Scan Screen**:  
  Live camera feed with a square/rounded overlay for scanning.

- **Generate Screen**:  
  Text input field + real-time QR preview with download/share options.

- **History Screen**:  
  Scrollable `ListView` of previously scanned or created QR codes.

---

## 📦 Project Status

`🚧 Work in Progress – Core scanning and generation features implemented. Bonus features in planning.`

This project is part of my Flutter development journey, focusing on practical mobile app functionalities involving device hardware and data management.

---

## 🏁 How to Run

```bash
git clone https://github.com/MuhammadAbu-Bakr/qr-code-scanner-generator.git
cd qr-code-scanner-generator
flutter pub get
flutter run
