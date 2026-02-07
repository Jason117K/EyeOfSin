extends Node2D
## Minimal reproducible example demonstrating the position bug
##
## Expected behavior: Both arms should track the mouse correctly
## Actual behavior (buggy): Only arm at (0,0) works, arm at (300,100) is offset

func _ready() -> void:
	# Create two identical arms at different positions
	var arm_at_origin = create_test_arm(Vector2(0, 0))
	var arm_at_offset = create_test_arm(Vector2(300, 100))

	add_child(arm_at_origin)
	add_child(arm_at_offset)

	#print("=== Position Bug Test ===")
	#print("Arm at (0,0): Should work correctly")
	#print("Arm at (300,100): BROKEN - tentacle offset by (300,100)")
	#print("========================")

func create_test_arm(pos: Vector2) -> Node2D:
	var arm_instance = preload("res://new folder/scenes/arm.tscn").instantiate()
	arm_instance.position = pos
	return arm_instance

## To test:
## 1. Attach this script to a Node2D in a test scene
## 2. Run the scene
## 3. Move mouse - observe the arm at (300,100) is broken
## 4. The tentacle will appear offset from where it should be
