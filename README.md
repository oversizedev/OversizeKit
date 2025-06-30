# 🎛️ OversizeKit

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20|%20macOS%2014%20|%20tvOS%2017%20|%20watchOS%2010-blue.svg?style=flat)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/oversizedev/OversizeKit/blob/main/LICENSE)

**OversizeKit** is a comprehensive Swift package that provides a collection of high-level UI components, services, and utilities for building modern SwiftUI applications. It's designed to accelerate iOS, macOS, tvOS, and watchOS app development with pre-built, customizable components and powerful functionality.

## ✨ Features

- 🎨 **Rich UI Components** - Pre-built SwiftUI components for rapid development
- 🏗️ **Modular Architecture** - Use only what you need with granular module imports  
- 🌐 **Multi-Platform Support** - iOS, macOS, tvOS, and watchOS compatibility
- 🔧 **Powerful Services** - Network, storage, location, and notification services
- 📱 **Ready-to-Use Kits** - Calendar, contacts, photo, and onboarding functionality
- 🎯 **Modern Swift** - Built with Swift 6.0 and latest SwiftUI features
- ⚡ **Performance Optimized** - Efficient and lightweight implementations

## 📦 Included Modules

OversizeKit consists of several specialized modules that can be used independently or together:

### Core Modules

| Module | Description |
|--------|-------------|
| **OversizeKit** | Main module containing core functionality and system services |
| **OversizeOnboardingKit** | Complete onboarding flow components and screens |
| **OversizeNoticeKit** | Notification and alert management system |

### Feature Kits  

| Module | Description |
|--------|-------------|
| **OversizeCalendarKit** | Calendar components, event management, and scheduling |
| **OversizeContactsKit** | Contact management and integration utilities |
| **OversizeLocationKit** | Location services and mapping components |
| **OversizeNotificationKit** | Push notifications and local notification handling |
| **OversizePhotoKit** | Photo picker, camera, and image processing utilities |

### Underlying Dependencies

- **OversizeUI** - Core UI components and design system
- **OversizeCore** - Fundamental utilities and extensions  
- **OversizeServices** - Backend services and API integrations
- **OversizeComponents** - Reusable SwiftUI components
- **OversizeLocalizable** - Localization and internationalization
- **OversizeResources** - Assets, colors, and resource management
- **OversizeNetwork** - Networking layer and HTTP utilities
- **OversizeModels** - Shared data models and entities
- **OversizeRouter** - Navigation and routing system

## 🚀 Installation

### Swift Package Manager

Add OversizeKit to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/oversizedev/OversizeKit.git", .upToNextMajor(from: "1.0.0"))
]
```

Then add the specific modules you need to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "OversizeKit", package: "OversizeKit"),
        .product(name: "OversizeCalendarKit", package: "OversizeKit"),
        .product(name: "OversizeLocationKit", package: "OversizeKit"),
        // Add other modules as needed
    ]
)
```

### Xcode Integration

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies**
3. Enter the repository URL: `https://github.com/oversizedev/OversizeKit.git`
4. Select the modules you want to use
5. Click **Add Package**

## 🏃‍♂️ Quick Start

### Basic Setup

```swift
import SwiftUI
import OversizeKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .systemServices() // Enable system services
        }
    }
}
```

### Using Calendar Kit

```swift
import SwiftUI
import OversizeCalendarKit

struct CalendarView: View {
    var body: some View {
        CalendarComponent()
            .padding()
    }
}
```

### Location Services

```swift
import SwiftUI
import OversizeLocationKit

struct LocationView: View {
    var body: some View {
        LocationPickerView()
    }
}
```

### Onboarding Flow

```swift
import SwiftUI
import OversizeOnboardingKit

struct OnboardingView: View {
    var body: some View {
        OnboardingPageView(
            title: "Welcome",
            subtitle: "Get started with our app",
            content: {
                // Your onboarding content
            }
        )
    }
}
```

## 📚 Documentation

Detailed documentation for each module is available:

- [API Documentation](https://oversizedev.github.io/OversizeKit/documentation/oversizekit/)
- [UI Components Guide](https://oversizedev.github.io/OversizeKit/documentation/oversizekit/ui-components)
- [Services Documentation](https://oversizedev.github.io/OversizeKit/documentation/oversizekit/services)
- [Integration Examples](https://oversizedev.github.io/OversizeKit/documentation/oversizekit/examples)

## 🎯 Examples

### Example Application

Check out the complete example application in the [`AppExample`](./AppExample) directory. It demonstrates:

- Integration of multiple OversizeKit modules
- Best practices for app architecture
- Real-world usage scenarios
- Platform-specific implementations

### Code Examples

```swift
// System services integration
ContentView()
    .systemServices()
    .premiumFeatures()
    .notifications()

// Settings and preferences
SettingsView()
    .settingsKit()
    .storeKit()

// Photo picker integration
PhotoPickerView()
    .photoKit()
```

## 📋 Requirements

### System Requirements

- **iOS**: 17.0+
- **macOS**: 14.0+
- **tvOS**: 17.0+  
- **watchOS**: 10.0+

### Development Requirements

- **Xcode**: 15.0+
- **Swift**: 6.0+
- **SwiftUI**: Latest version

### Dependencies

OversizeKit uses the following external dependencies:

- [Factory](https://github.com/hmlongco/Factory) - Dependency injection
- [CachedAsyncImage](https://github.com/lorenzofiamingo/swiftui-cached-async-image) - Async image loading
- [Navigator](https://github.com/hmlongco/Navigator) - Advanced navigation

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Add tests if applicable
6. Submit a pull request

### Reporting Issues

If you encounter any issues or have feature requests, please [create an issue](https://github.com/oversizedev/OversizeKit/issues) on GitHub.

## 🗺️ Roadmap

### Upcoming Features

- [ ] **Enhanced Animation System** - Advanced transition and animation utilities
- [ ] **AI Integration Kit** - Machine learning and AI-powered components  
- [ ] **Advanced Data Visualization** - Charts and graphs components
- [ ] **AR/VR Components** - Augmented and virtual reality support
- [ ] **Accessibility Enhancements** - Improved accessibility features
- [ ] **Performance Analytics** - Built-in performance monitoring tools

### Platform Expansion

- [ ] **visionOS Support** - Apple Vision Pro compatibility
- [ ] **Linux Support** - Server-side Swift compatibility
- [ ] **Web Components** - SwiftUI for Web integration

## 📄 License

OversizeKit is released under the MIT License. See [LICENSE](LICENSE) for details.

```
MIT License

Copyright (c) 2023 Alexander Romanov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

## 👨‍💻 Author

**Alexander Romanov**

- GitHub: [@oversizedev](https://github.com/oversizedev)
- Figma Community: [Oversize Design](https://www.figma.com/@oversizedesign)

## 🙏 Acknowledgments

Special thanks to all contributors and the Swift community for making this project possible.

---

<div align="center">
  <p>Made with ❤️ by the Oversize team</p>
  <p>
    <a href="https://github.com/oversizedev">GitHub</a> •
    <a href="https://www.figma.com/@oversizedesign">Figma</a> •
    <a href="https://github.com/oversizedev/OversizeKit/issues">Issues</a> •
    <a href="https://github.com/oversizedev/OversizeKit/discussions">Discussions</a>
  </p>
</div>
