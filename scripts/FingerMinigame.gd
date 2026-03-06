extends Control
## FingerMinigame.gd — "El Último Dedo" (Last Finger Standing)
## Two players place fingers on screen. After countdown, last to lift loses.
## Built entirely via code. Emits game_finished(winner_idx) when done.

signal game_finished(winner_idx: int) # 0 = bottom player won, 1 = top player won

# --- Configuration (set before adding to tree) ---
var player1_name: String = "Jugador 1" # Bottom
var player2_name: String = "Jugador 2" # Top
var player1_color: Color = Color("#22c55e")
var player2_color: Color = Color("#ef4444")

# --- Constants ---
const FINGER_RADIUS := 90.0
const PULSE_SPEED := 4.0
const RING_WIDTH := 8.0

# --- State ---
enum Phase {WAITING_FINGERS, COUNTDOWN, GO, FINISHED}
var _phase: Phase = Phase.WAITING_FINGERS
var _touch_map: Dictionary = {} # finger_idx -> player_idx (0=bottom, 1=top)
var _finger_down := [false, false] # Is each player's finger currently down?
var _finger_pos := [Vector2.ZERO, Vector2.ZERO] # Position of each player's finger
var _lifted_order: Array[int] = [] # Order in which players lifted: first = winner
var _countdown_step: int = 3
var _game_over := false

# --- Nodes ---
var _canvas: Control
var _countdown_label: Label
var _instruction_bottom: Label
var _instruction_top: Label
var _result_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Dark background
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Canvas for custom drawing
	_canvas = Control.new()
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_game)
	add_child(_canvas)

	# Bottom player instruction
	_instruction_bottom = _make_instruction_label(false)
	add_child(_instruction_bottom)

	# Top player instruction (rotated 180°)
	_instruction_top = _make_instruction_label(true)
	add_child(_instruction_top)

	# Countdown label
	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cls := LabelSettings.new()
	cls.font_size = 160
	cls.font_color = Color.WHITE
	cls.outline_size = 10
	cls.outline_color = Color(0, 0, 0, 0.8)
	_countdown_label.label_settings = cls
	_countdown_label.visible = false
	_countdown_label.z_index = 10
	add_child(_countdown_label)

	# Result label
	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_result_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rls := LabelSettings.new()
	rls.font_size = 72
	rls.font_color = Color.WHITE
	rls.outline_size = 8
	rls.outline_color = Color(0, 0, 0, 0.8)
	_result_label.label_settings = rls
	_result_label.visible = false
	_result_label.z_index = 10
	add_child(_result_label)

	# Set initial instruction text
	_update_instructions()


func _process(_delta: float) -> void:
	_canvas.queue_redraw()


# ========== INPUT ==========

func _input(event: InputEvent) -> void:
	if _game_over:
		return

	var vp_size := get_viewport().get_visible_rect().size
	var center_y := vp_size.y / 2.0

	# --- Touch input ---
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed:
			var player_idx := 0 if touch.position.y > center_y else 1
			# Only allow one finger per player
			if not _finger_down[player_idx]:
				_touch_map[touch.index] = player_idx
				_finger_down[player_idx] = true
				_finger_pos[player_idx] = touch.position
				_on_finger_down(player_idx)
		else:
			if _touch_map.has(touch.index):
				var player_idx: int = _touch_map[touch.index]
				_touch_map.erase(touch.index)
				_finger_down[player_idx] = false
				_on_finger_up(player_idx)

	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event
		if _touch_map.has(drag.index):
			var player_idx: int = _touch_map[drag.index]
			_finger_pos[player_idx] = drag.position

	# --- Mouse fallback for desktop ---
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var player_idx := 0 if mb.position.y > center_y else 1
				if not _finger_down[player_idx]:
					_touch_map[-1] = player_idx
					_finger_down[player_idx] = true
					_finger_pos[player_idx] = mb.position
					_on_finger_down(player_idx)
			else:
				if _touch_map.has(-1):
					var player_idx: int = _touch_map[-1]
					_touch_map.erase(-1)
					_finger_down[player_idx] = false
					_on_finger_up(player_idx)
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			if mb.pressed:
				var player_idx := 1 # Right click = top player for testing
				if not _finger_down[player_idx]:
					_touch_map[-2] = player_idx
					_finger_down[player_idx] = true
					_finger_pos[player_idx] = mb.position
					_on_finger_down(player_idx)
			else:
				if _touch_map.has(-2):
					var player_idx: int = _touch_map[-2]
					_touch_map.erase(-2)
					_finger_down[player_idx] = false
					_on_finger_up(player_idx)

	elif event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		if _touch_map.has(-1):
			var player_idx: int = _touch_map[-1]
			_finger_pos[player_idx] = mm.position
		if _touch_map.has(-2):
			var player_idx: int = _touch_map[-2]
			_finger_pos[player_idx] = mm.position


# ========== GAME LOGIC ==========

func _on_finger_down(player_idx: int) -> void:
	if _phase != Phase.WAITING_FINGERS:
		return

	_update_instructions()

	# Check if both fingers are down
	if _finger_down[0] and _finger_down[1]:
		_start_countdown()


func _on_finger_up(player_idx: int) -> void:
	match _phase:
		Phase.WAITING_FINGERS:
			_update_instructions()
		Phase.COUNTDOWN:
			# Lifted during countdown = penalty, they lose
			_phase = Phase.FINISHED
			_game_over = true
			# The one who lifted early loses (other player wins)
			var winner_idx := 1 if player_idx == 0 else 0
			_show_early_lift_result(player_idx, winner_idx)
		Phase.GO:
			# First to lift wins! (they reacted faster)
			_lifted_order.append(player_idx)
			if _lifted_order.size() == 1:
				# First lift = this player WINS (the fast one)
				_phase = Phase.FINISHED
				_game_over = true
				var winner_idx := player_idx
				_show_result(winner_idx)


func _start_countdown() -> void:
	_phase = Phase.COUNTDOWN
	_instruction_bottom.visible = false
	_instruction_top.visible = false
	_countdown_label.visible = true
	_countdown_step = 3
	_countdown_label.text = "3"

	var tw := create_tween()
	# 3
	tw.tween_callback(func():
		_countdown_label.text = "3"
		_pulse_label(_countdown_label)
	)
	tw.tween_interval(0.8)
	# 2
	tw.tween_callback(func():
		_countdown_label.text = "2"
		_pulse_label(_countdown_label)
	)
	tw.tween_interval(0.8)
	# 1
	tw.tween_callback(func():
		_countdown_label.text = "1"
		_pulse_label(_countdown_label)
	)
	tw.tween_interval(0.8)
	# GO!
	tw.tween_callback(func():
		_countdown_label.text = "¡SUELTA!"
		_countdown_label.label_settings.font_size = 120
		_countdown_label.label_settings.font_color = Color("#FFD700")
		_pulse_label(_countdown_label)
		_phase = Phase.GO
	)
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		_countdown_label.visible = false
	)


func _pulse_label(lbl: Label) -> void:
	lbl.scale = Vector2(1.3, 1.3)
	lbl.pivot_offset = lbl.size / 2.0
	var tw := create_tween()
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _show_result(winner_idx: int) -> void:
	var winner_name := player1_name if winner_idx == 0 else player2_name
	var loser_idx := 1 if winner_idx == 0 else 0
	var loser_name := player1_name if loser_idx == 0 else player2_name

	_countdown_label.visible = false
	_result_label.visible = true
	_result_label.text = "💀 %s pierde\n🏆 %s gana" % [loser_name, winner_name]
	_result_label.label_settings.font_color = player1_color if winner_idx == 0 else player2_color

	_result_label.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_result_label, "modulate:a", 1.0, 0.3)
	tw.tween_interval(1.5)
	tw.tween_callback(func(): game_finished.emit(winner_idx))


func _show_early_lift_result(loser_idx: int, winner_idx: int) -> void:
	var loser_name := player1_name if loser_idx == 0 else player2_name
	var winner_name := player1_name if winner_idx == 0 else player2_name

	_countdown_label.visible = false
	_result_label.visible = true
	_result_label.text = "⚠️ %s soltó antes!\n🏆 %s gana" % [loser_name, winner_name]
	_result_label.label_settings.font_color = Color("#FF4444")

	_result_label.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_result_label, "modulate:a", 1.0, 0.3)
	tw.tween_interval(2.0)
	tw.tween_callback(func(): game_finished.emit(winner_idx))


func _update_instructions() -> void:
	if _phase != Phase.WAITING_FINGERS:
		return

	if _finger_down[0]:
		_instruction_bottom.text = "✅ %s listo" % player1_name
		_instruction_bottom.label_settings.font_color = player1_color
	else:
		_instruction_bottom.text = "👇 %s\nPon tu dedo aquí" % player1_name
		_instruction_bottom.label_settings.font_color = Color(0.7, 0.7, 0.7)

	if _finger_down[1]:
		_instruction_top.text = "✅ %s listo" % player2_name
		_instruction_top.label_settings.font_color = player2_color
	else:
		_instruction_top.text = "👇 %s\nPon tu dedo aquí" % player2_name
		_instruction_top.label_settings.font_color = Color(0.7, 0.7, 0.7)


# ========== DRAWING ==========

func _draw_game() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var center := vp_size / 2.0
	var time := Time.get_ticks_msec() / 1000.0

	# Divider line
	_canvas.draw_line(
		Vector2(0, center.y),
		Vector2(vp_size.x, center.y),
		Color(1, 1, 1, 0.15), 2.0
	)

	# Player zones (subtle tint)
	var bottom_rect := Rect2(0, center.y, vp_size.x, center.y)
	var top_rect := Rect2(0, 0, vp_size.x, center.y)
	_canvas.draw_rect(bottom_rect, Color(player1_color, 0.06), true)
	_canvas.draw_rect(top_rect, Color(player2_color, 0.06), true)

	# Draw finger indicators
	for i in 2:
		if _finger_down[i]:
			var pos: Vector2 = _finger_pos[i]
			var color: Color = player1_color if i == 0 else player2_color
			var pulse := sin(time * PULSE_SPEED) * 0.3 + 0.7

			# Outer glow rings (pulsing)
			_canvas.draw_arc(pos, FINGER_RADIUS * 1.8, 0, TAU, 64, Color(color, 0.15 * pulse), 4.0)
			_canvas.draw_arc(pos, FINGER_RADIUS * 1.4, 0, TAU, 64, Color(color, 0.25 * pulse), 3.0)

			# Main circle
			_canvas.draw_circle(pos, FINGER_RADIUS, Color(color, 0.3))
			_canvas.draw_arc(pos, FINGER_RADIUS, 0, TAU, 64, Color(color, 0.8), RING_WIDTH)

			# Inner highlight
			_canvas.draw_circle(pos, FINGER_RADIUS * 0.3, Color(color.lightened(0.4), 0.5 * pulse))

			# "Hold" ripple during GO phase
			if _phase == Phase.GO:
				var ripple_r := FINGER_RADIUS + fmod(time * 100.0, 60.0)
				var ripple_a := 1.0 - fmod(time * 100.0, 60.0) / 60.0
				_canvas.draw_arc(pos, ripple_r, 0, TAU, 64, Color(color, ripple_a * 0.4), 2.0)


# ========== UI HELPERS ==========

func _make_instruction_label(is_top: bool) -> Label:
	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var ls := LabelSettings.new()
	ls.font_size = 56
	ls.font_color = Color(0.7, 0.7, 0.7)
	ls.outline_size = 6
	ls.outline_color = Color(0, 0, 0, 0.6)
	lbl.label_settings = ls
	lbl.z_index = 5

	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lbl.grow_vertical = Control.GROW_DIRECTION_BOTH
	lbl.custom_minimum_size = Vector2(500, 200)
	lbl.pivot_offset = Vector2(250, 100)

	if is_top:
		lbl.rotation = PI
		lbl.anchor_top = 0.25
		lbl.anchor_bottom = 0.25
	else:
		lbl.anchor_top = 0.75
		lbl.anchor_bottom = 0.75

	lbl.anchor_left = 0.5
	lbl.anchor_right = 0.5
	lbl.offset_left = -250
	lbl.offset_right = 250
	lbl.offset_top = -100
	lbl.offset_bottom = 100

	return lbl
