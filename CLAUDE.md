# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Chess3D is a native macOS 3D chess game built with Swift, AppKit, SceneKit, and SwiftChess.

## Build Commands

```bash
# Generate Xcode project
xcodegen generate

# Build the project
xcodebuild -project Chess3D.xcodeproj -scheme Chess3D -configuration Debug build

# Run the app
open ~/Library/Developer/Xcode/DerivedData/Chess3D-*/Build/Products/Debug/Chess3D.app
```

## Architecture

The app follows an MVC pattern with these main components:

- **App layer**: `AppDelegate.swift`, `main.swift` - App lifecycle and window management
- **Views layer**: `MainWindow.swift`, `ChessGameView.swift`, `GameInfoView.swift` - UI components
- **GameLogic layer**: `GameManager.swift`, `ChessBoard.swift` - Game state and rules

### Key Dependencies

- **SwiftChess**: External package for chess rules (https://github.com/SteveBarnegren/SwiftChess)
- **SceneKit**: Apple's 3D rendering framework
- **SwiftUI**: Used for the game info sidebar panel

### Important Implementation Details

- `GameManager` is the central controller managing game state, communicating between the 3D view and chess logic
- `ChessGameView` contains all SceneKit 3D rendering and mouse interaction handling
- `ChessSquare` is a local struct (different from SwiftChess's `Square`) used for coordinate mapping
- The coordinate system uses row 0-7 (bottom to top) and col 0-7 (left to right)
- BoardLocation conversion: `(x: col, y: 7 - row)` when interfacing with SwiftChess

### Communication Flow

1. `MainWindow` hosts both `ChessGameView` (3D) and `GameInfoView` (sidebar)
2. `ChessGameView` handles mouse interactions and calls `GameManager.movePiece()`
3. `GameManager` uses SwiftChess for rules and notifies views via `onGameStateChanged` callback
4. `GameInfoView` observes `GameManager` via SwiftUI's `@ObservedObject`

## User Interactions

- **Click piece**: Select a piece
- **Click green highlight**: Move piece
- **Mouse drag**: Rotate camera
- **Scroll wheel**: Zoom
- **Right-click drag**: Pan camera
- **Menu → Game → New Game**: Restart
- **Menu → View → Reset Camera**: Reset view

## Configuration

- Target: macOS 12.0+
- Swift version: 5.9
- Bundle ID: com.chess3d.app
