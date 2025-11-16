# HostageEscaper

A first-person shooter game built with HaxeFlixel featuring 3D raycasting and enemy AI.

# Features

- 3D raycasting engine with wall collision detection
- Enemy AI with smart targeting and line-of-sight
- Weapon system with ammo management
- Health system with damage visual effects
- Crosshair color changes when aiming at enemies
- Mini-map for tactical overview

# Installation
# Required Software

1. **Haxe 4.3.0+** - Download from: https://haxe.org/download/
2. **OpenFL 9.4.2** - `haxelib install openfl`
3. **Lime 8.2.3** - `haxelib install lime`
4. **HaxeFlixel 6.1.0** - `haxelib install flixel`
5. **HScript 2.6.0** - `haxelib install hscript`

# Setup Commands

```bash
haxelib install openfl
haxelib run openfl setup
haxelib install lime
haxelib run lime setup
haxelib install flixel
haxelib run flixel setup
haxelib install hscript
```

# Verify Installation
```bash
haxelib list
```

Should show: flixel: 6.1.0, openfl: 9.4.2, lime: 8.2.3, hscript: 2.6.0

# Running the Game

# HTML5 (Web Browser)
```bash
# Debug build
lime test html5 -debug

# Release build  
lime test html5
```

# Project Structure

```
source/
├── core/          # Game systems (raycasting, config, etc.)
├── entities/      # Enemy, Player, Weapons
├── states/        # Game states (Menu, Play, etc.)
├── ui/           # HUD, Mini-map, Overlays
└── managers/     # Enemy management

assets/
├── images/       # Sprites and textures
├── music/        # Background music
└── sounds/       # Sound effects
```

# Controls

- **WASD**: Move player
- **Mouse**: Look around  
- **Left Click**: Shoot weapon
- **R**: Reload weapon
- **Shift**: Sprint
- **M**: Main menu (when game over)

# Troubleshooting

- Ensure Haxe is in your system PATH
- Use exact library versions listed above
- Try `lime clean` then `lime test html5` if build fails

---

**Note**: This project is optimized for HTML5 and works best in web browsers.
