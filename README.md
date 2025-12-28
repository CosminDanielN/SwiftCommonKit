# SwiftCommonKit

A local Swift package providing shared utilities, architectural components, and foundation extensions for the Lens application.

## Overview

This package serves as the "core" library, containing code that is agnostic to specific product features but essential for the app's infrastructure.

## Contents

### Architecture
- **Coordinator Pattern**: Base protocols and classes for navigation management.
- **Clean Architecture Types**: Protocols for UseCases, Repositories, etc.
- **Dependency Injection**: Extensions or helpers for DI (if applicable).

### Utilities
- **Extensions**: Helpers for `Date`, `String`, `Array`, etc.
- **Logging**: Common logging wrappers.
- **Storage**: Persistence interfaces (e.g., `UserDefaults` wrappers, Keychain helpers).

## Usage

Import the module where needed:

```swift
import SwiftCommonKit

class MyCoordinator: Coordinator {
    // ...
}
```

## Testing

Run unit tests directly for this package:

```bash
xcodebuild test -scheme SwiftCommonKit -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
