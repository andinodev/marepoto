extends Control
## GameSelectionUI.gd — Handles SafeZone management for the game selection screen.

func _ready() -> void:
	# Apply Safe Zone
	_on_safe_area_changed(0, 0, 0, 0) # Initial apply
	SafeZoneManager.safe_area_changed.connect(_on_safe_area_changed)


func _on_safe_area_changed(_t: int, _b: int, _l: int, _r: int) -> void:
	# If we have a top-level MarginContainer, we apply it there.
	# Currently GameSelectionUI has a MarginContainer at $VBoxContainer/MarginContainer.
	# For better coverage, we'll ensure the whole VBoxContainer is protected if we update the scene.
	if has_node("VBoxContainer/MarginContainer"):
		SafeZoneManager.apply_to_margin($VBoxContainer/MarginContainer)
	
	# If the scene is updated to have a root SafeMargin:
	if has_node("SafeMargin"):
		SafeZoneManager.apply_to_margin($SafeMargin)
