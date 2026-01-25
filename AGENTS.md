# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Rated T for Trash** is a 3D underwater exploration game built with Godot 4.5 for the Godot Wild Jam. The theme is "Repurpose" - players control a robot diving to collect recyclable materials (metal, plastic, wood) while managing inventory and navigating increasing depth with dynamic environmental effects.

## Key Commands

### Running the Game
- Open the project in Godot 4.5+ editor and press F5, or run:
  ```
  godot --path . res://Scenes/Game/game_scene.tscn
  ```

### FMOD Audio
- FMOD banks are located in `Assets/fmod_banks/Desktop/`
- The FMOD project file is `fmod/rated-t-for-trash.fspro`
- Banks path is configured in project.godot: `res://assets/fmod_banks/Desktop`
- FMOD plugin version: 6.1.0

## Architecture

### Scene Structure
The main scene is `Scenes/Game/game_scene.tscn`. The game uses a hierarchical scene structure:

- **Game (game.gd)**: Root scene managing depth-based environmental effects
  - Controls volumetric fog density (0.0001-0.2) based on player depth
  - Adjusts lighting (background energy 0.5-3.0, anisotropy 0.2-0.6)
  - Uses cubic easing for dramatic depth progression
  - Target depth: configurable via `@export`, default 500.0

- **Player (player.gd)**: RigidBody3D with movement and static inventory system
  - Static inventory shared across all instances: metal, plastic, wood (max 10 each)
  - Thrust-based movement with WASD/arrow keys
  - Mesh tilting animation based on movement direction
  - FMOD event emitter for swimming/idle states
  - Static methods: `adjust_resource()`, `try_removing_resource()`, `get_inventory()`

- **Spawner (spawner.gd)**: Procedurally spawns objects from left/right walls
  - Spawns objects at random Y offsets relative to player position
  - Configurable spawn rates, speeds, and rotation behaviors
  - Only spawns below `min_spawn_depth` (default: -10.0)

- **Material (material.gd)**: Clickable recyclable objects with raycast detection
  - Types: METAL, PLASTIC, WOOD
  - Sizes: SMALL (1 resource), BIG (3 resources, requires 5 clicks)
  - Randomly selects variant meshes from exported scene arrays
  - Uses `_input()` with viewport raycasting for click detection
  - Plays FMOD recycling SFX with material-specific parameters

- **HUD (hud.gd)**: Displays depth meter and inventory counts
  - Updates every frame from Player static inventory
  - Format: "current/limit" for inventory items

- **Fish (fish.gd)**: Ambient animated creatures
  - Randomly selects from variant scenes
  - Moves with velocity and angular_velocity set by spawner

### Custom Input Actions
Defined in project.godot `[input]` section:
- `move_up`: W / Up Arrow
- `move_down`: S / Down Arrow
- `move_left`: A / Left Arrow
- `move_right`: D / Right Arrow
- `toggle_debug`: Ctrl+Shift+X
- `open_skill_tree`: F1

### Important Patterns

1. **Deferred Instantiation**: Use `add_child.call_deferred()` for runtime scene instantiation (see material.gd:63, spawner.gd:94)

2. **Static Player Inventory**: The Player class uses static variables for inventory that persist across instances. Always use the static methods to access/modify inventory.

3. **Enum-based Material System**: Materials use enums (MaterialTypes, MaterialSizes) for type safety. FMOD parameters are set using lowercase enum keys via `MaterialTypes.find_key()`.

4. **Collision Shape Reparenting**: Material variants store collision shapes in child nodes that get reparented to the root StaticBody3D (material.gd:65-67)

5. **Depth-based Effects**: The game.gd uses cubic easing (`depth_ratio³`) to make environmental changes more dramatic at greater depths

6. **Wall-based Spawning**: Objects spawn from left/right CSGBox3D walls with direction vectors calculated based on spawn side

### File Organization
- `Scenes/`: All game scenes organized by type (Camera, fish, Game, hud, Material, Player, Spawner, Water)
- `Assets/`: Resources organized by type (fmod_banks, fonts, icons, Materials, models, textures)
- `addons/fmod/`: FMOD GDExtension plugin (v6.1.0) - autoloaded as FmodManager
- `Shaders/Water/`: Custom water shader effects
- `fmod/`: FMOD Studio project files (.fspro, Banks, Metadata)

### Audio System
- FmodManager is autoloaded globally (project.godot:25)
- Events use `FmodEventEmitter2D` or `FmodEventEmitter3D` nodes
- Set parameters with `.set_parameter(param_name, value)`
- Example: `robot_sfx.set_parameter("state", "swimming")`

## Version Control Notes
- `.godot/` directory is gitignored (build cache)
- FMOD `.cache/`, `.unsaved/`, `.user/` directories are gitignored
- `*.import` files are gitignored (Godot auto-generates these)
