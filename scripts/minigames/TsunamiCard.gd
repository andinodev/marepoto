extends Button
## TsunamiCard.gd — Individual card component (Button-based) for Tusunami.

const BLUE_TEXTURE := preload("res://sprites/cards/carta azul.png")
const RED_TEXTURE := preload("res://sprites/cards/carta roja.png")
const GREEN_TEXTURE := preload("res://sprites/cards/carta verde.png")

signal clicked(card: Button)

@onready var front: TextureRect = null
@onready var back: TextureRect = null

var is_flipped: bool = false
var card_color: Color = Color.WHITE
var card_value: int = 1

func _ready() -> void:
	custom_minimum_size = Vector2(180, 260) * 1.50
	pivot_offset = custom_minimum_size / 2.0
	
	# Make button "flat" so it doesn't draw default styles over children
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if not has_node("Back"):
		var b := TextureRect.new()
		b.name = "Back"
		b.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		b.texture = GREEN_TEXTURE
		b.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		b.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(b)
		back = b
		
	if not has_node("Front"):
		var f := TextureRect.new()
		f.name = "Front"
		f.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		f.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		f.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		f.visible = false
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(f)
		front = f
		
	pressed.connect(_on_pressed)


func setup(color: Color, value: int = 1) -> void:
	card_color = color
	card_value = value
	is_flipped = false
	if back: back.show()
	if front: front.hide()
	# scale.x = 1.25
	scale = scale * 1.75


func flip() -> void:
	if is_flipped: return
	is_flipped = true
	
	var tween = create_tween()
	tween.tween_property(self , "scale:x", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		# Map color to texture
		if card_color.is_equal_approx(Color("#ff415c")): # RED
			front.texture = RED_TEXTURE
		elif card_color.is_equal_approx(Color("#3689ac")): # BLUE
			front.texture = BLUE_TEXTURE
		else:
			front.texture = RED_TEXTURE # Fallback
			
		front.show()
		back.hide()
	)
	tween.tween_property(self , "scale:x", 1.0, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _on_pressed() -> void:
	if not is_flipped:
		clicked.emit(self )
