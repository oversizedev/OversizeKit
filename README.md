# OversizeKit

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/oversizedev/OversizeKit/blob/main/LICENSE)

**OversizeKit** is a comprehensive Swift package that provides a collection of high-level UI components, services, and utilities for building modern SwiftUI applications. It's designed to accelerate iOS, macOS, tvOS, and watchOS app development with pre-built, customizable components and powerful functionality.

## Features

- **Rich UI Components** - Pre-built SwiftUI components for rapid development
- **Modular Architecture** - Use only what you need with granular module imports  
- **Multi-Platform Support** - iOS, macOS, tvOS, and watchOS compatibility
- **Powerful Services** - Network, storage, location, and notification services
- **Ready-to-Use Kits** - Calendar, contacts, photo, and onboarding functionality
- **Modern Swift** - Built with Swift 6.0 and latest SwiftUI features

## 🚀 Installation

### Swift Package Manager

Add OversizeKit to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/oversizedev/OversizeKit.git", .upToNextMajor(from: "2.4.2"))
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
                .appLaunch(onboarding: {
                    VStack {
                        Text("Welcome")
                        Button("Complete") {
                            appStateService.completedOnbarding()
                        }
                    }
                })
        }
    }
}
```

## 🎯 Examples

### Example Application

Check out the complete example application in the [`AppExample`](./AppExample) directory. It demonstrates:

- Integration of multiple OversizeKit modules
- Best practices for app architecture
- Real-world usage scenarios
- Platform-specific implementations

## 📋 Requirements

### System Requirements

- **iOS**: 17.0+
- **macOS**: 14.0+
- **tvOS**: 17.0+  
- **watchOS**: 10.0+

### Development Requirements

- **Xcode**: 16.4+
- **Swift**: 6.0+

### Dependencies

OversizeKit uses the following external dependencies:

- [Factory](https://github.com/hmlongco/Factory) - Dependency injection
- [Navigator](https://github.com/hmlongco/Navigator) - Advanced navigation
- [CachedAsyncImage](https://github.com/lorenzofiamingo/swiftui-cached-async-image) - Async image loading

## License

OversizeUI is released under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Made with ❤️ by the Oversize**

</div>
