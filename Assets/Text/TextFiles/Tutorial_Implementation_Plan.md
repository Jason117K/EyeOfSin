# Level 0-1 Tutorial System - Implementation Plan

## Overview

This document outlines the implementation plan for a forced tutorial system in Level 0-1 that guides new players through the core game mechanics. The tutorial uses a state machine to force specific player actions before allowing progression.

## Tutorial Flow

### Step 1: Select Spyder Demon
**Type:** ForcePlayerToDoActionTutorialPopup
**Text:** "Zombies are approaching. Select a SPYDER DEMON from the Bottom Left Menu."
**Behavior:**
- All plant buttons except Spyder are INVISIBLE
- Spyder button is highlighted
- Only clicking Spyder button advances tutorial

### Step 2: Place Spyder on Path
**Type:** ForcePlayerToDoActionTutorialPopup
**Text:** "Good, now click on a grey path tile to place the demon"
**Behavior:**
- Player can click any valid tile within bounds
- X key (deselect) is blocked
- Successful placement advances tutorial

### Step 3: Explain Blood Cost
**Type:** ForcePlayerClickUnderstandTutorialPopup
**Text:** "Demons cost Blood. You just lost some, so you can't place anymore. Endure the wave."
**Behavior:**
- Game pauses
- "UNDERSTOOD" button appears
- Clicking button unpauses and starts Wave 1

### Step 4: Wave 1 (Purple Dimension Only)
**Type:** Gameplay Phase
**Behavior:**
- Wave 1 zombies spawn ONLY in purple dimension
- Green dimension remains inactive
- Player can place more demons if they have blood
- Y key swapping is BLOCKED
- When all zombies dead, advance to Step 5

### Step 5: Press Y to Swap Dimensions
**Type:** ForcePlayerToDoActionTutorialPopup
**Text:** "Now for the tricky part. Press Y."
**Behavior:**
- Only Y key is accepted
- All other input blocked
- Pressing Y swaps to green dimension and advances tutorial

### Step 6: Explain Green Dimension
**Type:** ForcePlayerClickUnderstandTutorialPopup
**Text:** "You have TWO BATTLES to fight. Press Y anytime to swap. Wave 2 begins NOW!"
**Behavior:**
- Brief 0.5s delay for dimension swap visual
- Game pauses
- "UNDERSTOOD" button appears
- Clicking button starts Wave 2 in BOTH dimensions

### Step 7: Wave 2 (Both Dimensions)
**Type:** Gameplay Phase
**Behavior:**
- Wave 2 zombies spawn in BOTH purple and green dimensions
- Y key swapping now ENABLED
- Tutorial complete, normal gameplay continues

## Architecture

### State Machine
The tutorial uses a 7-state enum to track progress:
1. FORCE_SELECT_SPYDER
2. FORCE_PLACE_PLANT
3. EXPLAIN_BLOOD_COST
4. WAVE_1_ACTIVE
5. FORCE_PRESS_Y
6. EXPLAIN_GREEN_DIMENSION
7. WAVE_2_ACTIVE

### Input Filtering
Level controller intercepts input via `_input()` override and uses `get_viewport().set_input_as_handled()` to block unwanted actions during forced states.

### UI Control
Plant selection buttons are hidden/shown dynamically by setting `visible = false/true` on button nodes.

### Signal Integration
Tutorial connects to existing signals:
- `ToolTips.ToolTipHid` - When player clicks Understand
- `PlantManager.spyder_placed` - When spyder successfully placed
- `Button.pressed` - When Spyder button clicked
- `WaveManager.wave1Started` - When Wave 1 begins

## Files to Create

### Scripts
1. `res://Scripts/LevelLogic/level_0_1.gd` - Main tutorial controller (~300 lines)
2. `res://Scripts/LevelLogic/level_0_1_alternate.gd` - Green dimension controller (~50 lines)

### Text Files
1. `res://Assets/Text/TextFiles/Level0_1_Tutorial_SelectSpyder.txt`
2. `res://Assets/Text/TextFiles/Level0_1_Tutorial_PlaceSpyder.txt`
3. `res://Assets/Text/TextFiles/Level0_1_Tutorial_BloodCost.txt`
4. `res://Assets/Text/TextFiles/Level0_1_Tutorial_PressY.txt`
5. `res://Assets/Text/TextFiles/Level0_1_Tutorial_GreenDimension.txt`

### Scenes to Modify (in Godot Editor)
1. `res://Scenes/LevelScenes/Level0-1.tscn` - Attach level_0_1.gd script
2. `res://Scenes/LevelScenes/Level0-1_Alternate.tscn` - Attach level_0_1_alternate.gd script

## Key Implementation Details

### Reusing Existing Systems
- **ToolTips.gd** - Use `set_text()`, `set_text_pause()`, `showButton()`, `noButtonShow()` methods
- **PlantManager** - Connect to existing placement signals, no modifications needed
- **WaveManager** - Control via `canStartGame` flag, no modifications needed
- **PlantSelectionMenu** - Access button nodes directly, use `add_button_highlight()` / `remove_button_highlight()` methods

### Button Visibility Pattern
```gdscript
# Hide all except Spyder
plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunflowerButton").visible = false
plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Sunflower/SunFlowerLabel").visible = false
# ... repeat for all other plants

# Keep Spyder visible
plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterButton2").visible = true
plantSelectionMenu.get_node("PanelContainer/VBoxContainer/HBoxContainer/Peashooter/PeashooterLabel").visible = true
```

### Input Blocking Pattern
```gdscript
func _input(event):
	match tutorial_state:
		TutorialState.FORCE_SELECT_SPYDER:
			# Block all keyboard input
			if event is InputEventKey:
				get_viewport().set_input_as_handled()

		TutorialState.FORCE_PLACE_PLANT:
			# Block X key (deselect) and Y key (swap)
			if event is InputEventKey and event.pressed:
				if event.keycode == KEY_X or event.keycode == KEY_Y:
					get_viewport().set_input_as_handled()

		TutorialState.FORCE_PRESS_Y:
			# Only allow Y key
			if event is InputEventKey and event.pressed:
				if event.keycode != KEY_Y:
					get_viewport().set_input_as_handled()
			elif event is InputEventMouseButton:
				get_viewport().set_input_as_handled()
```

### Wave Control
```gdscript
# Wave 1: Purple dimension only
func _start_wave_1_purple_only():
	waveManager.canStartGame = true
	# Green dimension stays inactive (canStartGame = false)

# Wave 2: Both dimensions
func _start_wave_2_both_dimensions():
	var green_dimension = get_parent().get_node("Level0-1_Alternate")
	if green_dimension:
		green_dimension.start_wave_2()  # Activate green dimension

	waveManager.startSecondWave()  # Purple dimension Wave 2
	plantSelectionMenu.canSwapScenes = true  # Enable Y key swapping
```

## Testing Strategy

### Per-State Testing
1. **FORCE_SELECT_SPYDER**: Verify only Spyder button clickable, others invisible
2. **FORCE_PLACE_PLANT**: Verify any valid tile works, X key blocked
3. **EXPLAIN_BLOOD_COST**: Verify pause, Understand button, unpause on click
4. **WAVE_1_ACTIVE**: Verify only purple zombies spawn, green dimension inactive
5. **FORCE_PRESS_Y**: Verify only Y key works, mouse/other keys blocked
6. **EXPLAIN_GREEN_DIMENSION**: Verify 0.5s delay, pause, Understand button
7. **WAVE_2_ACTIVE**: Verify both dimensions spawn zombies, Y swap enabled

### Integration Testing
- Full tutorial playthrough from start to Wave 2
- Rapid input mashing during forced states (should be blocked)
- Dimension swap timing and synchronization
- Edge case: What if player exits during tutorial? (State machine resets on _ready)

## Implementation Checklist

- [ ] Create 5 tutorial text files
- [ ] Create level_0_1.gd with state machine
- [ ] Create level_0_1_alternate.gd
- [ ] Attach scripts to scenes in Godot editor
- [ ] Implement state transition logic
- [ ] Implement input filtering for each forced state
- [ ] Implement UI button hiding/showing
- [ ] Connect all signals (ToolTipHid, spyder_placed, button.pressed)
- [ ] Implement Wave 1 detection (all zombies dead)
- [ ] Implement Wave 2 activation in both dimensions
- [ ] Test each state individually
- [ ] Test full tutorial flow
- [ ] Playtest and adjust text/timing

## Estimated Time
**Total Implementation:** 4-5 hours
- File creation & structure: 30 minutes
- State machine core: 45 minutes
- Input filtering: 30 minutes
- Signal connections: 30 minutes
- UI control: 20 minutes
- Wave control: 30 minutes
- Dimension management: 20 minutes
- Testing & polish: 60 minutes

## Design Principles

1. **Reuse Existing Systems:** No modifications to ToolTips, PlantManager, WaveManager
2. **Clear State Machine:** Explicit states prevent tutorial bugs
3. **Input Interception:** Level controller gates input before other systems
4. **Signal-Driven:** Existing signals drive tutorial progression naturally
5. **Minimal Code:** ~350 lines total, all in level controller scripts

## Success Criteria

✓ Player CANNOT skip any tutorial step
✓ Player CANNOT perform blocked actions during forced states
✓ Tutorial clearly guides player through all core mechanics
✓ System is easy to debug with state transition logging
✓ Implementation adds no complexity to existing game systems
