# OversizeKit

[![Swift 6.1](https://img.shields.io/badge/Swift-6.1-orange.svg?style=flat)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/oversizedev/OversizeKit/blob/main/LICENSE)

**OversizeKit** is a set of high-level SwiftUI screens, controls and app services used across Oversize apps. It ships the parts every app repeats — launch flow, onboarding, lockscreen, settings, paywall, notices — so an app only has to provide its own content.

## Modules

The package ships ten independent products. Import only what you need.

| Product | What it gives you |
|---|---|
| `OversizeKit` | Launcher, onboarding/lockscreen flow, settings, paywall, ads, deeplinks, debug menu |
| `OversizeOnboardingKit` | `OnboardView` — onboarding page scaffold |
| `OversizeNoticeKit` | `NoticeListView` — offers, rate prompt, first-day notices |
| `OversizeMediaKit` | Photo/emoji/icon/background pickers, image gallery and slider, camera |
| `OversizeEditorKit` | Note and rich-text editors, font and text-style pickers |
| `OversizeNotificationKit` | Local notification scheduling UI |
| `OversizeCalendarKit` | Event creation screen, calendar/alarm/repeat pickers |
| `OversizeContactsKit` | Contact lists, attendees, email picker |
| `OversizeLocationKit` | Address field/picker, map coordinate view |
| `OversizeCloudKit` | CloudKit sharing and participant management |

In practice apps take three or four of these — typically `OversizeKit`, `OversizeOnboardingKit`, `OversizeMediaKit` and `OversizeNoticeKit`.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/oversizedev/OversizeKit.git", .upToNextMajor(from: "3.0.0"))
]
```

Then pick the products your target needs:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "OversizeKit", package: "OversizeKit"),
        .product(name: "OversizeOnboardingKit", package: "OversizeKit"),
        .product(name: "OversizeMediaKit", package: "OversizeKit"),
        .product(name: "OversizeNoticeKit", package: "OversizeKit"),
    ]
)
```

### Xcode

**File → Add Package Dependencies…**, enter `https://github.com/oversizedev/OversizeKit.git`, then select the products to link.

## Quick start

`Launcher` is the entry point. Wrap your root view in it and it takes over everything that happens before your content is reachable: onboarding, lockscreen (PIN + biometrics), paywall, rate prompt and what's-new screens. It applies `.coreServices()` internally, so you don't repeat it there.

```swift
import NavigatorUI
import OversizeKit
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Launcher {
                RootView()
            }
            .onboarding {
                OnboardingNavigationStack()
            }
        }
    }
}

struct RootView: View {
    @State private var navigator: Navigator = .init(configuration: .init())

    var body: some View {
        RootTabView()
            .navigationRoot(navigator)
    }
}
```

For a simple app that doesn't need its own navigation root, `.appLaunch(onboarding:)` is the short form:

```swift
ContentView()
    .appLaunch {
        OnboardingView()
    }
```

`coreServices()` injects screen size, theme, appearance, accent tint and premium status into the environment. The older `systemServices()` spelling is deprecated.

## Configuration

Most behaviour is driven by `Info.plist`, not by code. Add `Developer`, `Company` and `FeatureFlags` dictionaries:

```xml
<key>AppStoreId</key>
<string>1459928735</string>
<key>Developer</key>
<dict>
    <key>Name</key><string>Alexander Romanov</string>
    <key>Email</key><string>alexander@oversize.app</string>
    <key>WebsiteUrl</key><string>romanov.cc</string>
</dict>
<key>Company</key>
<dict>
    <key>Name</key><string>Oversize</string>
    <key>Email</key><string>support@oversize.app</string>
    <key>WebsiteUrl</key><string>https://oversize.app</string>
    <key>CdnUrl</key><string>https://cdn.oversize.design</string>
</dict>
<key>FeatureFlags</key>
<dict>
    <key>Onboarding</key><true/>
    <key>Apperance</key><true/>
    <key>StoreKit</key><true/>
    <key>CloudKit</key><true/>
    <key>FaceID</key><false/>
    <key>Notifications</key><false/>
    <key>Lookscreen</key><false/>
    <key>Vibration</key><false/>
    <key>Sounds</key><false/>
    <key>BlurMinimize</key><false/>
</dict>
```

These are read back through `Info.App.*` and `FeatureFlags.app.*` / `FeatureFlags.secure.*` from `OversizeServices`.

**The premium banner in settings is enabled by configuration, not code**: with `StoreKit` set to `true`, `SettingsView` renders `PremiumBannerRow`. Link `StoreKit.framework` in the target as well.

Note that `Launcher`'s own paywall, special-offer and rate covers are gated on the persisted premium state, not on this flag — clearing `StoreKit` hides the settings banner but does not stop those screens.

## Settings

`SettingsNavigationStack` is the recommended entry point — it sets up the `ManagedNavigationStack` and the destination routing that the built-in settings sub-screens rely on:

```swift
import NavigatorUI
import OversizeKit
import OversizeUI
import SwiftUI

struct AppSettingsNavigationStack: View {
    var body: some View {
        ManagedNavigationStack(scene: RootTab.settings.id) { navigator in
            SettingsView {
                Row("App settings") {
                    navigator.navigate(to: AppSettingsDestinations.appSettings)
                } leading: {
                    Image(systemName: "gearshape")
                }
                .rowArrow()
                .buttonStyle(.row)
            }
            .navigationDestination(AppSettingsDestinations.self)
            .navigationAutoReceive(AppSettingsDestinations.self)
            .navigationDestination(SettingsDestinations.self)
            .navigationAutoReceive(SettingsDestinations.self)
        }
    }
}
```

Registering `SettingsDestinations` is what lets the kit's own screens — appearance, security, about, premium — open from the rows `SettingsView` renders. Registering your own destination type does the same for your section.

The closure you pass to `SettingsView` becomes your app's own section; everything else — appearance, security, notifications, sync, about, feedback, support, premium — comes from the kit and routes through `SettingsDestinations`.

> `SettingsView` reads `@Environment(\.navigator)`. Hosting it in a plain `NavigationStack(path:)` will render the screen but its sub-screens will not navigate.

## Onboarding

`OnboardView` provides the page scaffold — content area plus a bottom action bar, with optional back, skip and help buttons:

```swift
import FactoryKit
import OversizeOnboardingKit
import OversizeServices
import OversizeUI
import SwiftUI

struct OnboardingView: View {
    @Injected(\.appStateService) private var appStateService: AppStateService

    var body: some View {
        OnboardView {
            VStack(spacing: .small) {
                Text("Welcome")
                    .largeTitle()
                Text("All your information in one app")
                    .title2(.semibold)
                    .foregroundStyle(.secondary)
            }
        } actions: {
            Button("Get Started") {
                appStateService.completedOnboarding()
            }
            .buttonStyle(.primary)
            .accent()
        }
    }
}
```

`Launcher` observes `appStateService.isCompletedOnboarding` and swaps to your content when onboarding completes.

## Notices and ads

Both are zero-configuration and hide themselves for premium users:

```swift
import OversizeKit
import OversizeNoticeKit

VStack(spacing: .small) {
    NoticeListView()
    AdView()
}
```

## Media and editors

```swift
import OversizeMediaKit

PhotoField($image)

EmojiField("Icon", emojis: emojis, selection: $emoji)
    .iconPickerStyle(.circle)

PhotoLibraryPicker(selection: $selectedImage)
    .hideCamera()
```

```swift
import OversizeEditorKit
import OversizeKit // URLEditor lives here

NoteEditor("Note", text: $text)

URLEditor("Link", url: $url) {
    Button("Save") { save() }
}
```

`RichTextEditor` is available on the 26.0 SDKs and newer.

## Dependency injection

The package uses [Factory](https://github.com/hmlongco/Factory) — import it as `FactoryKit`:

```swift
import FactoryKit
import OversizeServices

@Injected(\.appStateService) private var appStateService: AppStateService
```

You do not need to register anything: default implementations come from `OversizeServices`. Override a keypath only for tests or a custom implementation.

One exception: `LauncherViewModel.init` always re-registers `\.networkService` with its own `NetworkService`, so a custom registration made before `Launcher` is built will be replaced.

| Keypath | Used for |
|---|---|
| `\.appStateService` | Onboarding state, app lifecycle |
| `\.settingsService` | User settings, appearance |
| `\.biometricService` | Face ID / Touch ID on the lockscreen |
| `\.appStoreReviewService` | Rate prompt |
| `\.storeKitService` | Purchases, premium status |
| `\.networkService` | Remote config, offers, app updates |
| `\.localNotificationService` | Local notifications |
| `\.calendarService` / `\.contactsService` / `\.locationService` | Calendar, Contacts, Location kits |
| `\.intelligenceService` | AI writing in `OversizeEditorKit` |

## Example app

[`AppExample`](./AppExample) is a working integration: `Launcher` + onboarding, a Navigator-based tab root, the settings stack, and demo screens for the media and editor kits. It also carries the `ExampleUITests` target showing how to drive an OversizeKit app from XCUITest.

## Testing an app built on OversizeKit

`Launcher` decides what to show from persisted state, so UI tests need to control it: reset onboarding, and suppress the interstitials (paywall, rate prompt) it presents over your content. Pass launch arguments and act on them before the scene is built:

```swift
// Shared between the app and the UI test target
enum UITestLaunchArguments {
    static let resetOnboarding = "-UITestResetOnboarding"
    static let suppressInterstitials = "-UITestSuppressInterstitials"
}

#if DEBUG
    enum UITestingSupport {
        static func applyLaunchArgumentsIfNeeded() {
            let arguments = ProcessInfo.processInfo.arguments

            if arguments.contains(UITestLaunchArguments.resetOnboarding) {
                AppStateService().resetOnboarding()
            }

            // Launcher presents the paywall and the rate prompt over the content
            // for non-premium users, which would cover the screen under test.
            if arguments.contains(UITestLaunchArguments.suppressInterstitials) {
                UserDefaults.standard.set(true, forKey: "AppState.PremiumState")
            }
        }
    }
#endif
```

```swift
@main
struct MyApp: App {
    init() {
        #if DEBUG
            UITestingSupport.applyLaunchArgumentsIfNeeded()
        #endif
    }
    ...
}
```

```swift
let app = XCUIApplication()
app.launchArguments += [
    UITestLaunchArguments.resetOnboarding,
    UITestLaunchArguments.suppressInterstitials,
]
app.launch()
```

Seeding the premium flag is enough only while `Info.App.appStoreId` is absent. Once your app provides an App Store ID, `LauncherViewModel.onAppear()` runs `checkPremium()` and writes the fetched status back over the same key, so a paywall or rate cover can still appear mid-test.

## Requirements

- **iOS** 17.0+, **macOS** 14.0+, **tvOS** 17.0+, **watchOS** 10.0+
- **Swift** 6.1+ (`swift-tools-version: 6.1`)
- `OversizeEditorKit`'s `RichTextEditor` additionally requires the 26.0 SDKs

## Dependencies

- [Factory](https://github.com/hmlongco/Factory) — dependency injection (`FactoryKit`)
- [Navigator](https://github.com/hmlongco/Navigator) — navigation (`NavigatorUI`)
- Oversize ecosystem: `OversizeUI`, `OversizeCore`, `OversizeServices`, `OversizeLocalizable`, `OversizeComponents`, `OversizeResources`, `OversizeNetwork`, `OversizeNavigation`, `OversizeArchitecture`, `OversizeIntelligenceService`

## Local development

`Package.swift` switches its dependency graph automatically:

```swift
let isLocalDev = FileManager.default.fileExists(atPath: "\(NSHomeDirectory())/Developer/Packages/OversizeCore")
```

When `~/Developer/Packages/OversizeCore` exists, every Oversize dependency resolves to a sibling checkout in `~/Developer/Packages/` instead of GitHub. Clone the ecosystem packages next to each other and changes are picked up without tagging a release. On any other machine — CI included — the remote pins are used.

## License

OversizeKit is released under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Made with ❤️ by the Oversize**

</div>
