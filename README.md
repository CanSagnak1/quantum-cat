# Quantum Cat

A quantum mechanics-inspired puzzle platformer built with SwiftUI and SpriteKit for iOS.

---

## Table of Contents

1. [Overview](#overview)
2. [Technical Architecture](#technical-architecture)
3. [Project Structure](#project-structure)
4. [Core Systems](#core-systems)
5. [Game Mechanics](#game-mechanics)
6. [Build and Run](#build-and-run)
7. [Configuration](#configuration)
8. [Dependencies](#dependencies)
9. [License](#license)

---

## Overview

Quantum Cat is a 2D puzzle platformer that incorporates quantum mechanics concepts into its gameplay. Players control a cat that can enter a "superposition" state, allowing it to interact with quantum platforms and navigate through levels while avoiding detection by observers.

### Key Features

- Quantum superposition mechanic for puzzle solving
- Observer-based detection system inspired by the observer effect
- Five progressively difficult levels
- Stability meter system that drains during superposition
- Collectible quantum orbs for score and stability restoration

---

## Technical Architecture

### Framework Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| UI Framework | SwiftUI | Main menu, HUD, overlays, settings |
| Game Engine | SpriteKit | Physics, rendering, game logic |
| State Management | Combine | Reactive data binding |
| Persistence | UserDefaults + AppStorage | Settings and progress storage |
| Audio | AVFoundation | Sound effects and haptic feedback |

### Architecture Pattern

The application follows a hybrid MVVM architecture optimized for SwiftUI-SpriteKit integration:

```
┌─────────────────────────────────────────────────────────┐
│                      SwiftUI Layer                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │ ContentView │  │ MainMenuView │  │ ControlsOverlay│  │
│  └──────┬──────┘  └──────────────┘  └────────────────┘  │
│         │                                                │
│  ┌──────▼──────────────────────────────────────────┐    │
│  │              GameViewModel                       │    │
│  │  - State management (@Published)                 │    │
│  │  - Timer coordination                            │    │
│  │  - Delegate implementation                       │    │
│  └──────┬──────────────────────────────────────────┘    │
└─────────┼───────────────────────────────────────────────┘
          │ GameSceneDelegate
┌─────────▼───────────────────────────────────────────────┐
│                    SpriteKit Layer                       │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │  GameScene  │  │ LevelLoader  │  │    Entities    │  │
│  └─────────────┘  └──────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
quantum_cat/
├── App/
│   └── QuantumCatApp.swift          # Application entry point
├── Entities/
│   ├── CatNode.swift                # Cat visual representation
│   ├── ExitDoor.swift               # Level exit entity
│   ├── ObserverEntity.swift         # Detection system entity
│   ├── PlayerEntity.swift           # Player physics and controls
│   └── QuantumOrb.swift             # Collectible orb entity
├── Managers/
│   ├── AudioManager.swift           # Sound and haptics singleton
│   └── GameProgressManager.swift    # Level progress persistence
├── Models/
│   ├── GameState.swift              # Game state enumeration
│   └── LevelData.swift              # Level configuration models
├── Resources/
│   └── Levels/
│       ├── level_1.json             # Level definition files
│       ├── level_2.json
│       ├── level_3.json
│       ├── level_4.json
│       └── level_5.json
├── Scene/
│   ├── GameScene.swift              # Main SpriteKit scene
│   ├── GameSceneDelegate.swift      # Scene-ViewModel protocol
│   └── LevelLoader.swift            # JSON level parser
├── ViewModels/
│   └── GameViewModel.swift          # Central state manager
└── Views/
    ├── ContentView.swift            # Root view router
    ├── ControlsOverlay.swift        # Touch control buttons
    ├── GameContainerView.swift      # SpriteKit host container
    ├── GameOverView.swift           # Game over screen
    ├── HUDView.swift                # In-game status display
    ├── LevelCompleteView.swift      # Level completion screen
    ├── LevelSelectView.swift        # Level selection grid
    ├── MainMenuView.swift           # Main menu interface
    ├── PauseMenuView.swift          # Pause overlay
    └── SettingsView.swift           # Settings panel
```

---

## Core Systems

### Physics System

The game utilizes SpriteKit's physics engine with custom category bitmasks:

```swift
struct PhysicsCategory {
    static let player: UInt32   = 0x1 << 0
    static let ground: UInt32   = 0x1 << 1
    static let door: UInt32     = 0x1 << 2
    static let observer: UInt32 = 0x1 << 3
    static let orb: UInt32      = 0x1 << 4
}
```

Physics configuration:
- Gravity: `-12.0` (Y-axis)
- Player mass: `1.0`
- Restitution: `0.0` (no bounce)
- Friction: `0.2`

### State Machine

Game states are managed through a simple enumeration:

```swift
enum GameState {
    case menu
    case playing
    case levelComplete
    case gameOver
}
```

State transitions are handled by `GameViewModel` which acts as the single source of truth for UI updates via `@Published` properties.

### Level Data System

Levels are defined in JSON format and loaded by `LevelLoader`:

```json
{
    "id": 1,
    "name": "First Steps",
    "difficulty": 1,
    "playerStart": {"x": -100, "y": 0},
    "exitPosition": {"x": 600, "y": -130},
    "platforms": [...],
    "quantumPlatforms": [...],
    "observers": [...],
    "orbs": [...],
    "parTime": 60,
    "requiredOrbs": 2
}
```

Level validation is performed via `LevelData.isValid()` which checks:
- Valid ID and difficulty range (1-5)
- Non-negative player and exit positions
- Positive par time
- Required orbs within available orb count

### Observer Detection System

The `ObserverEntity` implements a vision cone detection algorithm:

1. Distance check against `visionRange`
2. Angle calculation to target
3. Comparison against `visionAngle` threshold
4. Warning state management with visual feedback

Detection triggers `GameSceneDelegate.sceneDidDetectObserver()` which forces superposition collapse.

---

## Game Mechanics

### Quantum Superposition

When activated, the player enters superposition state:
- Quantum platforms become solid and collidable
- Quantum stability meter begins draining (0.5% per 100ms)
- Visual feedback shows split state
- Detection by observers forces immediate collapse

### Stability System

```
Initial Stability: 100%
Drain Rate (Split): 0.5% per 100ms
Split Activation Cost: 5%
Orb Restoration: Variable per orb
Minimum for Split: 10%
```

### Scoring Algorithm

```swift
let baseScore = 1000
let timeBonus = max(0, 500 - Int(elapsedTime * 5))
let orbBonus = orbsCollected * 100
let perfectBonus = quantumStability >= 0.5 ? 200 : 0
let finalScore = baseScore + timeBonus + orbBonus + perfectBonus
```

### Star Rating

Stars are calculated based on level-specific thresholds:
- 1 Star: Level completed
- 2 Stars: Completed within `parTime`
- 3 Stars: All orbs collected

---

## Build and Run

### Requirements

| Requirement | Version |
|-------------|---------|
| Xcode | 16.0+ |
| iOS Deployment Target | 18.0 |
| Swift | 5.9+ |
| macOS (development) | 15.0+ |

### Build Commands

```bash
# Clone repository
git clone <repository-url>
cd quantum-cat

# Open in Xcode
open quantum_cat.xcodeproj

# Build via command line
xcodebuild -scheme quantum_cat \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    build

# Run tests
xcodebuild -scheme quantum_cat \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    test
```

### Simulator Installation

```bash
# Boot simulator
xcrun simctl boot <device-uuid>

# Install app
xcrun simctl install <device-uuid> \
    ~/Library/Developer/Xcode/DerivedData/quantum_cat-*/Build/Products/Debug-iphonesimulator/quantum_cat.app

# Launch app
xcrun simctl launch <device-uuid> apps.cansagnak.quantum-cat
```

---

## Configuration

### AppStorage Keys

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `musicEnabled` | Bool | true | Background music toggle |
| `soundEnabled` | Bool | true | Sound effects toggle |
| `hapticEnabled` | Bool | true | Haptic feedback toggle |

### UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `unlockedLevels` | Int | Highest unlocked level (1-5) |
| `level_X_stars` | Int | Star rating for level X |
| `level_X_highScore` | Int | High score for level X |

---

## Dependencies

This project has no external dependencies. All functionality is implemented using Apple's first-party frameworks:

- **SwiftUI** - Declarative UI framework
- **SpriteKit** - 2D game engine
- **Combine** - Reactive programming framework
- **AVFoundation** - Audio playback
- **GameplayKit** - Random number generation

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

Celal Can Sagnak

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-08 | Initial release with 5 levels |