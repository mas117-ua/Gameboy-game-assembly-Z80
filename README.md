# Gameboy-game-assembly-Z80

# 🎮 Game Boy Space Shooter

<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-completed-success.svg)
![Platform](https://img.shields.io/badge/platform-Game%20Boy-green.svg)
![Language](https://img.shields.io/badge/language-Assembly%20Z80-orange.svg)


*A classic space shooter game for the Nintendo Game Boy*
</div>

## 📝 Description
This is a classic space shooter game developed for the Nintendo Game Boy, written entirely in Assembly Z80. The game features six progressively challenging levels, different enemy types, and a scoring system.

## 🌟 Features
- 🎯 6 unique levels with increasing difficulty
- 👾 Different enemy patterns and behaviors
- 🚀 Player-controlled spaceship
- 💥 Shooting mechanics
- 📊 Score tracking system
- 💫 Multiple enemy movement patterns
- 🏆 Win condition and game completion screen

## 🎮 Game Structure
```
├── Core Components
│   ├── main.asm          # Main game loop and initialization
│   ├── nave.asm          # Player ship controls and logic
│   ├── bullets.asm       # Projectile system
│   ├── enemies.asm       # Enemy behavior and patterns
│   └── levels.asm        # Level management system
```

## 🔧 Technical Details
### Memory Map
- ROM Bank 0: Main game code
- WRAM0: Game variables
  - Player position
  - Enemy states
  - Bullet data
  - Game state

### Hardware Usage
- Uses Game Boy hardware interrupts
- Implements sprite management
- Utilizes OAM for sprite rendering
- Handles Game Boy-specific memory constraints

## 🎯 Game Mechanics
1. **Player Control**
   - Move left/right with D-pad
   - Press A to shoot
   - Avoid enemy ships

2. **Level Progression**
   - 6 levels with unique enemy patterns
   - Increasing difficulty
   - Score tracking
   - Lives system

3. **Enemy Types**
   - Different movement patterns
   - Various shooting behaviors
   - Level-specific formations

## 🛠️ Building the Game
1. Requirements:
   - RGBDS (Rednex Game Boy Development System)
   - Make (optional but recommended)

2. Build Commands:
```
rgbasm -o main.o main.asm
rgblink -o game.gb main.o
rgbfix -v -p 0 game.gb
```

## 🎮 Controls
- **D-Pad Left/Right**: Move ship
- **A Button**: Shoot
- **B Button**: Start game/Continue
- **Start**: Pause (WIP)

## 📦 Implementation Details

### Core Systems
1. **Sprite Management**
   - OAM handling for player, enemies, and bullets
   - Sprite attribute management
   - Hardware sprite limitations handling

2. **Collision Detection**
   - Bullet-enemy collisions
   - Player-enemy collisions
   - Screen boundary checks

3. **Game States**
   - Title screen
   - Playing state
   - Game over state
   - Win screen

### Memory Management
- Efficient use of available RAM
- Strategic ROM banking
- Optimized sprite usage

## 🚀 Getting Started
1. Clone the repository
2. Install RGBDS
3. Build using the commands above
4. Run in your favorite Game Boy emulator

## 🧪 Testing
Tested on:
- BGB Emulator
- Analogue Pocket
- Real Game Boy hardware

## 📚 Documentation
- Code is extensively commented
- Memory map documentation included
- Hardware register usage documented


## 📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

