# Mosquito Alert Mobile App - Developer Documentation

Welcome to the Mosquito Alert Mobile App developer documentation. This is a Flutter-based citizen science application that allows participants to report mosquito sightings and breeding sites to help with mosquito surveillance and control efforts.

## 📋 Table of Contents

1. [Project Overview](01-project-overview.md)
2. [Architecture Guide](02-architecture.md)
3. [User Flow & Navigation](03-user-flow.md)
4. [Data Management](04-data-management.md)
5. [API Integration](05-api-integration.md)
6. [State Management](06-state-management.md)
7. [Camera & Media](07-camera-media.md)
8. [Location Services](08-location-services.md)
9. [Notifications & Background Tasks](09-notifications.md)
10. [Testing & Deployment](10-testing-deployment.md)
11. [Contributing Guide](11-contributing.md)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/Mosquito-Alert/Mosquito-Alert-Mobile-App.git

# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
```

## 📱 App Overview

The Mosquito Alert app enables citizen scientists to:
- Report mosquito sightings with photos and location data
- Report mosquito bites with time, setting, and location data
- Report breeding sites where mosquitoes might reproduce
- View mosquito activity maps in their area
- Receive notifications about mosquito-related information
- Track their contributions to the scientific community

## 🏗️ Technology Stack

- **Framework**: Flutter 3.3.0+
- **Language**: Dart
- **State Management**: Provider pattern
- **Backend**: Custom Mosquito Alert API
- **Maps**: Google Maps Flutter
- **Storage**: Shared Preferences, Secure Storage
- **Notifications**: Firebase Messaging
- **Analytics**: Firebase Analytics
- **Background Tasks**: WorkManager

## 🔧 Development Environment

- **Flutter Version**: Managed with FVM (Flutter Version Management)
- **SDK**: Dart >=3.3.0 <4.0.0
- **iOS Deployment**: iOS 12.0+
- **Android Deployment**: API Level 21+

## 📂 Project Structure

```
lib/
├── api/              # API integration and HTTP clients
├── models/           # Data models and DTOs
├── pages/            # App screens and UI components
├── providers/        # State management (Provider pattern)
├── services/         # Business logic and external services
├── utils/            # Utility functions and helpers
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## 🤝 Contributing

Please read our [Contributing Guide](11-contributing.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is part of the Mosquito Alert citizen science initiative. Please refer to the LICENSE file for detailed information.
