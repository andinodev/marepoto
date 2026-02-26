extends Node
## SafeZoneManager — Provides safe-area insets for devices with notches,
## punch-holes, or rounded screen corners.
##
## Uses DisplayServer.get_display_safe_area() which returns Rect2i of the
## safe region. On desktop this equals the full window → all insets are 0.

signal safe_area_changed(top: int, bottom: int, left: int, right: int)

## Current insets (in viewport-space pixels)
var top_inset: int = 0
var bottom_inset: int = 0
var left_inset: int = 0
var right_inset: int = 0


func _ready() -> void:
	_recalculate()
	get_viewport().size_changed.connect(_recalculate)


func _recalculate() -> void:
	var screen_size := DisplayServer.screen_get_size()
	var safe_rect := DisplayServer.get_display_safe_area()

	# Insets = distance from each screen edge to the safe rect edge
	var new_top := maxi(safe_rect.position.y, 0)
	var new_left := maxi(safe_rect.position.x, 0)
	var new_bottom := maxi(screen_size.y - (safe_rect.position.y + safe_rect.size.y), 0)
	var new_right := maxi(screen_size.x - (safe_rect.position.x + safe_rect.size.x), 0)

	# Scale from physical pixels to viewport pixels when stretch mode is active
	var viewport_size := get_viewport().get_visible_rect().size
	if screen_size.x > 0 and screen_size.y > 0:
		var scale_x := viewport_size.x / float(screen_size.x)
		var scale_y := viewport_size.y / float(screen_size.y)
		new_top = int(new_top * scale_y)
		new_bottom = int(new_bottom * scale_y)
		new_left = int(new_left * scale_x)
		new_right = int(new_right * scale_x)

	if new_top != top_inset or new_bottom != bottom_inset \
			or new_left != left_inset or new_right != right_inset:
		top_inset = new_top
		bottom_inset = new_bottom
		left_inset = new_left
		right_inset = new_right
		safe_area_changed.emit(top_inset, bottom_inset, left_inset, right_inset)


## Apply safe-area insets to a MarginContainer, adding optional extra design
## padding on top of the safe insets.
func apply_to_margin(margin: MarginContainer,
		pad_top: int = 0, pad_bottom: int = 0,
		pad_left: int = 0, pad_right: int = 0) -> void:
	margin.add_theme_constant_override("margin_top", top_inset + pad_top)
	margin.add_theme_constant_override("margin_bottom", bottom_inset + pad_bottom)
	margin.add_theme_constant_override("margin_left", left_inset + pad_left)
	margin.add_theme_constant_override("margin_right", right_inset + pad_right)
