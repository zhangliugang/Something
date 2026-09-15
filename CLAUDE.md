# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift animation library called "Something" providing visual effects for iOS 17+. It uses Swift Package Manager and includes Metal shaders for GPU-accelerated animations.

## Common Commands

```bash
# Run library tests
swift test

# Build the library
swift build

# Run the Example app (requires Xcode)
# Open Example/Example.xcodeproj in Xcode and run on simulator
```

## Architecture

The library exposes four main animation components:

- **DigitalClock** (`Sources/Something/DigitalClock/`) - Pure SwiftUI digital clock with rolling/flip animations
- **GridDissolve** (`Sources/Something/GridDissolve/`) - Metal-based grid dissolve effect with 11 direction options
- **LetterFlow** (`Sources/Something/LetterFlow/`) - SwiftUI draggable letter reordering using iOS 26+ Liquid Glass API
- **Ripple** (`Sources/Something/Ripple/`) - SwiftUI view modifier with Metal shader ripple effect

A **Shared** module (`Sources/Shared/`) provides the C struct for Metal shader uniforms.

## Dependencies

- iOS 17.0+ (iOS 26+ required for LetterFlow Liquid Glass features)
- Swift 6.0+
- Metal (for GridDissolve and Ripple effects)

The Example app demonstrates all components in `Example/Example/examples/`.
