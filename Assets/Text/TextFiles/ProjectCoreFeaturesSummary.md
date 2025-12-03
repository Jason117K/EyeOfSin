# Eye of Syn - Core Features & Architecture Summary

## Project Overview
Eye of Syn is a Plants vs Zombies-inspired tower defense game built in Godot 4.4. Players place Demons (equivalent to plants) on a grid-based battlefield to defend against waves of zombies. The game features two unique selling points: **dual-world gameplay** and a **blood buff system**.

## Core Gameplay Mechanics

### 1. Dual-World System
The game operates two parallel game spaces simultaneously, with players switching between them at will:

- **Two Simultaneous Scenes**: One purple world and one green world run concurrently
- **Y Key Toggle**: Pressing Y swaps visibility between worlds
- **Linked Tile Occupation**: Placing a demon in one world blocks the corresponding tile in the alternate world
- **Independent Zombie Waves**: Each world has its own set of zombies marching down lanes

**Technical Implementation** (`game_controller.gd:61-86`):
```gdscript
func swap_scenes():
    - Toggles visibility between current_scenes[0] and current_scenes[1]
    - Uses on_scene_1 boolean to track active world
    - 0.1s cooldown prevents rapid switching
```

### 2. Blood Buff System
Every demon can buff other demons within their "blood buff zone" - a set of adjacent tiles around them:

- **Visual Effects**: Animated blood tiles appear on buffed spaces
- **Gameplay Effects**: Buffed demons gain enhanced abilities
- **Configurable Buffs**: Each demon has a `giveBuffTo` array defining which demon types it can buff
- **Cross-World Prevention**: Purple demons can't buff green demons and vice versa

**Technical Implementation** (`BuffNodes.gd:62-125`):
- BuffNodesComponent has 8-9 Area2D nodes (TileArea1-9) positioned around parent demon
- Each TileArea checks for overlapping plant collision areas
- Matches plant names against `giveBuffTo` list
- Calls `receiveBuff(plant)` on valid targets

### 3. Grid-Based Placement System
Standard tower defense grid mechanics with custom constraints:

- **32-pixel Grid**: Mouse position snapped to grid cells
- **Grid Map Dictionary**: Tracks occupied cells by position Vector2
- **Blood Currency**: Sun points renamed as "Blood" for placing demons
- **Special Size Handling**: Maw demon occupies 2 grid cells

## Project Architecture

### Core System Components

#### GameController (`Scripts/game_controller.gd`)
The top-level controller managing scene lifecycle and world switching.

**Key Responsibilities**:
- Scene loading via `change_dual_scenes(scene1, scene2)`
- Dual-world swap coordination
- Cross-world tile blocking via `place_empty_in_alt_scene(grid_pos)`
- Scene history management for pause/resume

**Key Variables**:
- `current_scenes[]`: Array holding both game world instances
- `on_scene_1`: Boolean tracking which world is visible
- `can_swap`: Cooldown flag preventing rapid world switching

#### PlantManager (`Scripts/Plants/PlantManager.gd`)
Handles all demon placement, cost management, and grid state.

**Key Responsibilities**:
- Mouse input handling for placement (`_input()`)
- Grid position validation and occupation tracking
- Blood point economy management
- Plant removal and movement
- Signal emission for tutorial/progression systems

**Key Variables**:
- `grid_map{}`: Dictionary mapping Vector2 positions to plant instances
- `sun_points`: Current blood currency amount (exported, set per level)
- `grid_size = 32`: Pixel size of grid cells

**Important Methods**:
- `place_plant(grid_pos)`: Core placement logic with validation
- `place_empty_blocker_plant(grid_pos)`: Creates invisible blocker for alternate world
- `generate_unique_name(base_name)`: Sequential numbering for demon instances

#### BuffNodes Component (`Scripts/Plants/BuffNodes.gd`)
Attached to every demon scene to manage blood buff zones.

**Structure**:
- 8-9 Area2D child nodes (TileArea1-9) positioned around parent
- Matching AnimatedSprite2D nodes (BloodTile1-9) for visual feedback
- `@export var giveBuffTo[]`: Configurable array of demon types this can buff

**Process Loop**:
1. Iterate through all TileArea children
2. Check `get_overlapping_areas()` for each
3. Filter by "Plants" group and world color (Green/Purple)
4. Match overlapping plant names against `giveBuffTo` list
5. Call `receiveBuff(parent_plant)` on valid targets

### Level Architecture

Each level consists of paired scenes: a main level and an alternate level.

#### Level Structure (`Scripts/LevelLogic/Level7.gd` & `level_7_alternate.gd`)

**Hierarchy**:
```
Level (Control)
├── Environment (Node2D) - Visual decorations
│   ├── Coral - Sway animations
│   ├── Fish - Animated background
│   └── Props - Static/animated decorations
├── PlantManager (Node2D) - Demon placement system
├── GameLayer (Node2D) - Gameplay entities
│   ├── ZombieSpawner1-7 - Per-lane spawners
│   ├── GridManager - Visual grid overlay
│   └── WaveManager - Wave timing and progression
├── PlantSelectionMenu (Control) - Demon selection UI
├── UILayer (Control) - HUD elements
└── Camera2D - Fixed camera
```

**Key Differences Between Main/Alternate**:
- `@export var make_green = false/true`: Determines world color
- Different environment prop textures (coral vs pustules)
- Zombie composition varies per world
- `finish_setup_and_start()`: Alternate waits for main level signal

**Initialization Flow**:
1. Main level calls `change_dual_scenes(level7, level7_alternate)`
2. Both scenes instantiated, alternate hidden
3. Main level shows tutorial tooltip
4. On tooltip dismiss: main enables wave manager, alternate calls `finish_setup_and_start()`
5. Both worlds begin spawning zombies independently

### Scene File Structure

**game_controller.tscn**:
- Root GameController node with script
- CurrentScene Control node as container
- StartScreen initially loaded as child

**PlantManager.tscn**:
- Root Node2D with PlantManager script
- AudioStreamPlayer2D for sound effects
- SetSun Timer for initial blood amount

**BuffNodesComponent.tscn**:
- Root Node2D with BuffNodes script
- 10 TileArea (Area2D) + CollisionShape2D pairs
- 10 BloodTile (AnimatedSprite2D) for visuals
- Positioned at offsets: ±32/±64 x/y from parent

**Level7.tscn / Level7_Alternate.tscn**:
- Control root with level script
- Extensive environment decoration hierarchy
- 7 ZombieSpawner instances with custom wave configurations
- PlantManager instance with exported sun_points (1200)
- WaveManager with timing parameters
- UI elements (selection menu, tooltips, pause)

## Key Design Patterns

### 1. Signal-Based Communication
- PlantManager emits signals on plant placement: `plant_placed`, `spyder_placed`, `walnut_placed`, etc.
- Used for tutorial progression and achievement tracking
- WaveManager emits `wave2AlmostStart` for level coordination

### 2. Group-Based Entity Management
- Demons added to "Plants" group for collision detection
- Further categorized as "Green" or "Purple" for world separation
- Buff system filters by group membership to prevent cross-world buffing

### 3. Node Path Dependencies
- Components reference siblings via `get_parent().get_node("NodePath")`
- Examples: PlantManager accesses PlantSelectionMenu, GameLayer
- Enables modular scene structure but creates implicit dependencies

### 4. Preloaded Scenes
- Common scenes preloaded as constants: `preload("res://Scenes/...")`
- Reduces runtime loading overhead
- Examples: `sunflower_scene`, `empty_demon_scene`

## Data Flow Examples

### Placing a Demon
1. User clicks on game field with demon selected
2. `PlantManager._input()` captures mouse click
3. Convert mouse position to grid coordinates via `mouse_pos_to_grid()`
4. Validate sufficient blood points and unoccupied cell
5. Instantiate selected plant scene
6. Add to grid_map dictionary at position
7. Call `Global.game_controller.place_empty_in_alt_scene(grid_pos)`
8. GameController places invisible EmptyDemon blocker in alternate world
9. Emit type-specific signal for progression tracking

### Cross-World Tile Blocking
1. Demon placed in Purple world at position (128, 96)
2. PlantManager calls `Global.game_controller.place_empty_in_alt_scene(Vector2(128, 96))`
3. GameController checks which scene is hidden (Green world)
4. Calls `hidden_scene.place_empty_blocker_plant(Vector2(128, 96))`
5. Green world's PlantManager instantiates EmptyDemon scene at that position
6. EmptyDemon added to grid_map, blocking placement
7. Player cannot place demon at (128, 96) in Green world

### Blood Buff Application
1. Demon A placed at position (160, 128)
2. BuffNodesComponent's TileArea1 positioned at (192, 128) - one cell to the right
3. Demon B placed at (192, 128) - enters TileArea1
4. Next frame: BuffNodes `_process()` runs
5. TileArea1.get_overlapping_areas() returns Demon B's collision area
6. Check: Is Demon B in "Plants" group? Yes
7. Check: Same world color (both Purple)? Yes
8. Check: Is "Sunflower" (Demon B's type) in `giveBuffTo` array? Yes
9. Call `demon_b.receiveBuff(demon_a)`
10. Demon B applies buff effects from Demon A
11. BloodTile1 visual appears on grid (if enabled)

## Critical Global References

- `Global.game_controller`: Singleton reference to GameController instance
- `Global.incrementSunflowerCount()`: Tracks sunflower placements for progression
- `AudioManager.create_2d_audio_at_location()`: Centralized audio system

## File Naming Conventions

- **Scripts**: PascalCase (`PlantManager.gd`, `BuffNodes.gd`)
- **Scenes**: PascalCase with underscores for levels (`Level7.tscn`, `Level7_Alternate.tscn`)
- **Instance Names**: PascalCase in editor, sequential numbers added at runtime
- **Groups**: PascalCase ("Plants", "Green", "Purple")

## Common Gotchas for New Developers

1. **Demon placement requires world sync**: Always call `place_empty_in_alt_scene()` after placing
2. **Grid positions offset by +16**: Cell centers are at 16, 48, 80, etc. (grid_size/2 offset)
3. **Maw occupies two cells**: Special handling required in placement logic
4. **BuffNodes script must call parent methods**: Demons need `receiveBuff()` and `debuff()` methods
5. **World color groups critical**: Forgetting to add "Green"/"Purple" breaks buff system isolation
6. **Scene visibility vs process_mode**: Hidden alternate scene still processes unless explicitly disabled
7. **Grid_map uses global positions**: Ensure consistent coordinate space for all grid operations
