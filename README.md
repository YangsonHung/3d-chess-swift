[English](README.md) | [中文](README.zh-CN.md)

# Chess3D - 3D Chess

A native macOS 3D chess game

## Screenshot

![Chess3D Screenshot](chess3d.jpg)

## Features

- 🎮 3D board rendering (SceneKit)
- ♟️ 6 types of chess piece 3D models
- 📐 Complete chess rules
- 👆 Click to select/move pieces
- ✨ Valid move highlighting
- 🖱️ Camera controls (rotate/zoom/pan)
- 📊 Game state display

## How to Run

### Run in Xcode

```bash
open Chess3D.xcodeproj
```

Then press `Cmd + R` to run

### Run the compiled app directly

```bash
open ~/Library/Developer/Xcode/DerivedData/Chess3D-*/Build/Products/Debug/Chess3D.app
```

### Run from terminal

```bash
~/Library/Developer/Xcode/DerivedData/Chess3D-cmmpwuyvbkioryasqvebedqornda/Build/Products/Debug/Chess3D.app/Contents/MacOS/Chess3D
```

## Controls

- **Click piece**: Select a piece
- **Click green highlight**: Move piece
- **Mouse drag**: Rotate camera
- **Scroll wheel**: Zoom
- **Right-click drag**: Pan camera
- **Menu → Game → New Game**: Restart
- **Menu → View → Reset Camera**: Reset view

## Project Structure

```
Chess3D/
├── App/
│   ├── AppDelegate.swift      # App lifecycle
│   └── main.swift             # Entry point
├── Views/
│   ├── MainWindow.swift       # Main window
│   ├── ChessGameView.swift    # SceneKit 3D view
│   └── GameInfoView.swift     # Game info panel
├── GameLogic/
│   ├── GameManager.swift      # Game state management
│   └── ChessBoard.swift       # Board model
└── Resources/
    └── Assets.xcassets        # Assets
```

## Tech Stack

- Swift
- AppKit
- SceneKit (3D rendering)
- SwiftChess (Chess rules)
- SwiftUI (Info panel)
- XcodeGen (Project build)

## Requirements

- macOS 12.0+
- Xcode 15.0+

## Build

```bash
xcodegen generate
xcodebuild -project Chess3D.xcodeproj -scheme Chess3D -configuration Debug build
```

Happy Chess! ♟️
