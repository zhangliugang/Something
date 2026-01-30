# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A **Swift Package Manager library** providing Metal-based grid dissolve animations for iOS. The view captures its content as a texture, divides it into a configurable grid, and animates cells with scaling and fade effects.

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
- Defines data types for GPU uniform buffer

### Core Library (`Sources/AwesomeAnimation/`) - Depends on `Shared`

- **MetalGridView.swift** - Main UIKit `UIView` subclass that:
  - Sets up Metal device, command queue, and render pipeline
  - Captures view content as a Metal texture using `UIGraphicsImageRenderer`
  - Manages animation state via `CADisplayLink`
  - Passes uniforms (time, grid size, direction, tint) to the shader

- **GridDissolve.metal** - GPU shaders:
  - `vertexShader` - Renders a full-screen triangle strip quad
  - `fragmentShader` - Samples texture, applies per-cell scaling centered on each cell, and alpha fade based on animation progress

- **Resources/img.avif** - Test image resource bundled with the library

### Example App (`Example/`)

- **ExampleApp.swift** - SwiftUI app entry point
- **ContentView.swift** - Demo UI with `MetalGridViewRepresentable` (UIViewRepresentable wrapper) for SwiftUI integration, plus configuration controls

## Key Components

### `MetalGridView` Public API

```swift
// Cell size in pixels
var cellPixelSize: Double = 80.0

// Animation direction
var dissolveDirection: GridDissolveDirection = .leftToRight

// Animation settings
var animationDuration: TimeInterval = 3.0
var cellDuration: TimeInterval = 0.5

// Control
func dismiss(animated: Bool, completion: (() -> Void)?)
```

### Animation Directions

| Case | Description |
|------|-------------|
| `.leftToRight` | Left to right |
| `.rightToLeft` | Right to left |
| `.topToBottom` | Top to bottom |
| `.bottomToTop` | Bottom to top |
| `.topLeftToBottomRight` | Diagonal: top-left to bottom-right |
| `.topRightToBottomLeft` | Diagonal: top-right to bottom-left |
| `.bottomLeftToTopRight` | Diagonal: bottom-left to top-right |
| `.bottomRightToTopLeft` | Diagonal: bottom-right to top-left |
| `.centerOut` | Center to edges |
| `.edgeIn` | Edges to center |
| `.random` | Random order |

### Uniforms Structure (Swift ↔ Metal)

Defined in `Sources/Shared/Shared.h`, must stay in sync between Swift and Metal:
- `time: Float` - Elapsed animation time in **seconds**
- `gridSize: SIMD2<Float>` - Cell size in pixels (width, height)
- `duration: Float` - Total animation duration in seconds
- `cellDuration: Float` - Per-cell animation duration in seconds
- `direction: Int32` - Animation direction (0-10, see table above)
- `randomSeed: Float` - Seed for random ordering

### Animation Logic

- **Cell start time** = calculated based on direction within `[0, duration - cellDuration]`
- **Cell end time** = `startTime + cellDuration`
- **Cell progress** = `(time - startTime) / cellDuration` (0.0 to 1.0)
- Cells scale down from center and become transparent when animation completes
- Direction affects the order in which cells start animating

## Platform Support

- **iOS 14+** (configured in Package.swift)
- **macOS** is not currently configured in Package.swift despite mentions elsewhere

## Dependencies

None. Uses Metal, MetalKit, UIKit, and SwiftUI only.
