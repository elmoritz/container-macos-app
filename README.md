# MyMacOSApp - macOS App

A modern macOS application using a **workspace + SPM package** architecture for clean separation between app shell and feature code.

## Project Architecture

```
MyMacOSApp/
├── MyMacOSApp.xcworkspace/              # Open this file in Xcode
├── MyMacOSApp.xcodeproj/                # App shell project
├── MyMacOSApp/                          # App target (minimal)
│   ├── Assets.xcassets/                # App-level assets (icons, colors)
│   ├── MyMacOSAppApp.swift              # App entry point
│   ├── MyMacOSApp.entitlements          # App sandbox settings
│   └── MyMacOSApp.xctestplan            # Test configuration
├── MyMacOSAppPackage/                   # 🚀 Primary development area
│   ├── Package.swift                   # Package configuration
│   ├── Sources/MyMacOSAppFeature/       # Your feature code
│   └── Tests/MyMacOSAppFeatureTests/    # Unit tests
└── MyMacOSAppUITests/                   # UI automation tests
```

## Key Architecture Points

### Workspace + SPM Structure
- **App Shell**: `MyMacOSApp/` contains minimal app lifecycle code
- **Feature Code**: `MyMacOSAppPackage/Sources/MyMacOSAppFeature/` is where most development happens
- **Separation**: Business logic lives in the SPM package, app target just imports and displays it

### Buildable Folders (Xcode 16)
- Files added to the filesystem automatically appear in Xcode
- No need to manually add files to project targets
- Reduces project file conflicts in teams

### App Sandbox
The app is sandboxed by default with basic file access permissions. Modify `MyMacOSApp.entitlements` to add capabilities as needed.

## Development Notes

### Code Organization
Most development happens in `MyMacOSAppPackage/Sources/MyMacOSAppFeature/` - organize your code as you prefer.

### Public API Requirements
Types exposed to the app target need `public` access:
```swift
public struct SettingsView: View {
    public init() {}
    
    public var body: some View {
        // Your view code
    }
}
```

### Adding Dependencies
Edit `MyMacOSAppPackage/Package.swift` to add SPM dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/example/SomePackage", from: "1.0.0")
],
targets: [
    .target(
        name: "MyMacOSAppFeature",
        dependencies: ["SomePackage"]
    ),
]
```

### Test Structure
- **Unit Tests**: `MyMacOSAppPackage/Tests/MyMacOSAppFeatureTests/` (Swift Testing framework)
- **UI Tests**: `MyMacOSAppUITests/` (XCUITest framework)
- **Test Plan**: `MyMacOSApp.xctestplan` coordinates all tests

## Configuration

### XCConfig Build Settings
Build settings are managed through **XCConfig files** in `Config/`:
- `Config/Shared.xcconfig` - Common settings (bundle ID, versions, deployment target)
- `Config/Debug.xcconfig` - Debug-specific settings  
- `Config/Release.xcconfig` - Release-specific settings
- `Config/Tests.xcconfig` - Test-specific settings

### App Sandbox & Entitlements
The app is sandboxed by default with basic file access. Edit `MyMacOSApp/MyMacOSApp.entitlements` to add capabilities:
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
<!-- Add other entitlements as needed -->
```

## macOS-Specific Features

### Window Management
Add multiple windows and settings panels:
```swift
@main
struct MyMacOSAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        Settings {
            SettingsView()
        }
    }
}
```

### Asset Management
- **App-Level Assets**: `MyMacOSApp/Assets.xcassets/` (app icon with multiple sizes, accent color)
- **Feature Assets**: Add `Resources/` folder to SPM package if needed

### SPM Package Resources
To include assets in your feature package:
```swift
.target(
    name: "MyMacOSAppFeature",
    dependencies: [],
    resources: [.process("Resources")]
)
```

## Notes

### Generated with XcodeBuildMCP
This project was scaffolded using [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP), which provides tools for AI-assisted macOS development workflows.