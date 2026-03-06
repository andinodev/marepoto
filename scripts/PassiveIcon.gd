extends Control
## PassiveIcon.gd — A small icon representing an active passive effect.
## Shows the challenge icon with a circular player-color border and a round counter.

signal expired

var player_color: Color = Color.WHITE
var rounds_left: int = -1 # -1 = permanent (∞)
var passive_type: String = ""
var challenge_title: String = ""
var owner_name: String = ""

var _icon_texture: Texture2D
var _circle_container: Control
var _count_label: Label
var _icon_rect: TextureRect

const ICON_SIZE := 64
const RING_WIDTH := 36.0
const DEFAULT_ICON_PATH := ""


func _ready() -> void:
	var container_size := ICON_SIZE + RING_WIDTH
	custom_minimum_size = Vector2(container_size, container_size)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	# -- Circle container (draws the ring) --
	_circle_container = Control.new()
	_circle_container.custom_minimum_size = Vector2(container_size, container_size)
	_circle_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_circle_container.draw.connect(_draw_ring)
	add_child(_circle_container)

	# -- Icon texture (centered inside the ring) --
	var icon_display := ICON_SIZE - 12
	_icon_rect = TextureRect.new()
	_icon_rect.custom_minimum_size = Vector2(icon_display, icon_display)
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if _icon_texture:
		_icon_rect.texture = _icon_texture
	_circle_container.add_child(_icon_rect)
	_icon_rect.position = Vector2(
		(container_size - icon_display) / 2.0,
		(container_size - icon_display) / 2.0
	)

	# -- Count label (overlaid, centered on the circle) --
	_count_label = Label.new()
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, 0, 36)
	_update_count_text()
	_circle_container.add_child(_count_label)

	_apply_color_styles()


func setup(color: Color, rounds: int, icon_path: String, title: String) -> void:
	player_color = color
	rounds_left = rounds
	challenge_title = title

	# Load icon texture
	var path := icon_path if icon_path != "" else DEFAULT_ICON_PATH
	if ResourceLoader.exists(path):
		_icon_texture = load(path) as Texture2D
	else:
		_icon_texture = load(DEFAULT_ICON_PATH) as Texture2D

	if _icon_rect:
		_icon_rect.texture = _icon_texture
	if _count_label:
		_update_count_text()
		_apply_color_styles()
	if _circle_container:
		_circle_container.queue_redraw()


func decrement() -> bool:
	## Returns true if the passive has expired (reached 0).
	if rounds_left < 0:
		return false # Permanent, never expires
	rounds_left -= 1
	_update_count_text()
	if rounds_left <= 0:
		expired.emit()
		return true
	return false


func _update_count_text() -> void:
	if _count_label == null:
		return
	if rounds_left < 0:
		_count_label.text = "∞"
	else:
		_count_label.text = str(rounds_left)


func _apply_color_styles() -> void:
	if _count_label == null:
		return
	var ls := LabelSettings.new()
	ls.font_size = 63
	ls.font_color = player_color
	ls.outline_size = 16
	ls.outline_color = Color.BLACK
	ls.shadow_size = 3
	ls.shadow_color = Color(0, 0, 0, 0.5)
	_count_label.label_settings = ls


func _draw_ring() -> void:
	## Called by _circle_container.draw signal
	var container_size := ICON_SIZE + RING_WIDTH
	var center := Vector2(container_size / 2.0, container_size / 2.0)
	var radius := (container_size / 2.0) - (RING_WIDTH / 2.0)

	# Draw filled circle background (dark)
	_circle_container.draw_circle(center, radius + RING_WIDTH / 2.0, Color(0.1, 0.1, 0.1, 0.8))

	# Draw the colored ring
	_circle_container.draw_arc(center, radius, 0, TAU, 64, player_color, RING_WIDTH, true)
