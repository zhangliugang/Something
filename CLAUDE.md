# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Swift Package Manager library** providing animations for iOS 14+ and macOS 14+. Currently includes:
- **Metal-based Grid Dissolve** - GPU-accelerated image dissolve with 11 direction options
- **Digital Clock** - SwiftUI rolling digit animation for displaying current time

## Build & Test Commands

```bash
# Build the library
swift build

# Run tests
swift test

# Build for release
swift build -c release

# Run the example app (opens Xcode project)
open Example/Example.xcodeproj
```

## Architecture

### Shared (`Sources/Shared/`)

- **Shared.h** - C header with `Uniforms` struct shared between Swift and Metal shaders

### Metal Animation (Grid Dissolve)

- **Sources/AwesomeAnimation/MetalGridView.swift** - Main UIView subclass with Metal rendering
- **Sources/AwesomeAnimation/GridDissolve.metal** - Vertex and fragment shaders

### SwiftUI Animation (Digital Clock)

- **Sources/AwesomeAnimation/DigitalClockView.swift** - Rolling digit clock view

### Example App (`Example/`)

- **ExampleApp.swift** - SwiftUI app entry point
- **ContentView.swift** - Demo UI with navigable list of animation examples

## Components

### MetalGridView

```swift
public class MetalGridView: UIView {
    // Cell size in pixels (default: 30)
    public var cellPixelSize: Double = 30

    // Total animation duration in seconds (default: 3)
    public var animationDuration: Double = 3

    // Per-cell animation duration in seconds (default: 0.1)
    public var cellDuration: Double = 0.1

    // Animation direction (default: .leftToRight)
    public var dissolveDirection: GridDissolveDirection = .leftToRight

    // Dismiss animation with completion handler
    public func dismiss(animated: Bool, completion: (() -> Void)? = nil)
}
```

### GridDissolveDirection

| Value | Description |
|-------|-------------|
| `.leftToRight` | Left to right |
| `.rightToLeft` | Right to left |
| `.topToBottom` | Top to bottom |
| `.bottomToTop` | Bottom to top |
| `.topLeftToBottomRight` | Top-left to bottom-right diagonal |
| `.topRightToBottomLeft` | Top-right to bottom-left diagonal |
| `.bottomLeftToTopRight` | Bottom-left to top-right diagonal |
| `.bottomRightToTopLeft` | Bottom-right to top-left diagonal |
| `.centerOut` | From center outward |
| `.edgeIn` | From edges inward |
| `.random` | Random order |

### DigitalClockView

```swift
public struct DigitalClockView: View {
    // Font for displaying time digits (default: .system(size: 60, weight: .bold, design: .monospaced))
    public var font: Font

    // Color of the time digits (default: .primary)
    public var foregroundColor: Color

    // Background color of the clock (default: .clear)
    public var backgroundColor: Color

    // Whether to show background padding (default: false)
    public var showBackground: Bool

    // Separator color between time components (default: .primary.opacity(0.5))
    public var separatorColor: Color

    // Height of each digit column (default: 80)
    public var digitColumnHeight: CGFloat
}
```

### Uniforms Structure (Swift ↔ Metal)

Defined in `Sources/Shared/Shared.h`:
- `time: Float` - Elapsed animation time in seconds
- `gridSize: SIMD2<Float>` - Cell size in pixels (width, height)
- `duration: Float` - Total animation duration in seconds
- `cellDuration: Float` - Per-cell animation duration in seconds
- `direction: Int32` - Animation direction (0-10, see table above)
- `randomSeed: Float` - Seed for random ordering

## Animation Logic

### Grid Dissolve Timing

Each cell animates independently based on its position and direction:

```metal
// Maximum start time ensures last cell finishes at end of duration
float maxStartTime = u.duration - u.cellDuration;

// Start time based on cell position (0 to maxStartTime)
float startTime = calculateStartTime(u.direction, col, row, ...);

// Cell animation progress (0 to 1)
float progress = (u.time - startTime) / u.cellDuration;

// Scale from 1.0 to 0, alpha from 1 to 0
float scale = 1.0 - progress;
float alpha = 1.0 - progress;
```

## Platform Support

- **iOS 14+** (configured in Package.swift)

## Dependencies

None. Uses Metal, MetalKit, SwiftUI, and UIKit/AppKit only.
