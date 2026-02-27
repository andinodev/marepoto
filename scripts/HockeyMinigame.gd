extends Control
## HockeyMinigame.gd — 1v1 Air Hockey minigame (tabletop mode, single screen).
## Built entirely via code. Emits game_finished(winner_idx) when done.

signal game_finished(winner_idx: int) # 0 = bottom player, 1 = top player

# --- Configuration (set before adding to tree) ---
var player1_name: String = "Jugador 1" # Bottom
var player2_name: String = "Jugador 2" # Top
var player1_color: Color = Color("#22c55e")
var player2_color: Color = Color("#ef4444")
var rounds_to_win: int = 3

# --- Constants ---
const PUCK_RADIUS := 50.0
const PADDLE_RADIUS := 78.0
const PUCK_MAX_SPEED := 1800.0 * 1.25
const PUCK_START_SPEED := 600.0 * 0.4
const PUCK_FRICTION := 0.998 * 1.15
const GOAL_WIDTH := 340.0
const GOAL_DEPTH := 12.0
const ARENA_MARGIN := 30.0
const BORDER_WIDTH := 4.0
const NEON_GLOW_DURATION := 0.3
const CENTER_DEAD_ZONE := 60.0 # Paddles can't cross center ± this

# --- State ---
var _score := [0, 0]
var _puck_pos: Vector2
var _puck_vel: Vector2
var _paddle_pos := [Vector2.ZERO, Vector2.ZERO]
var _touch_map: Dictionary = {} # finger_idx -> player_idx
var _arena_rect: Rect2
var _goal_rects := [Rect2(), Rect2()] # bottom, top
var _paused := false
var _goal_scored := false
var _goal_flash_timer := 0.0
var _game_over := false
var _impact_flashes: Array = [] # [{pos, color, timer, max_timer}]
var _puck_trail: Array = [] # [Vector2] recent positions
const TRAIL_LENGTH := 12

# --- Nodes ---
var _canvas: Control
var _score_label_bottom: Label
var _score_label_top: Label
var _name_label_bottom: Label
var _name_label_top: Label
var _countdown_label: Label
var _result_overlay: Control


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
	_canvas.draw.connect(_draw_arena)
	add_child(_canvas)

	# Score labels
	_score_label_bottom = _make_score_label(false)
	add_child(_score_label_bottom)
	_score_label_top = _make_score_label(true)
	add_child(_score_label_top)

	# Player name labels
	_name_label_bottom = _make_name_label(false)
	add_child(_name_label_bottom)
	_name_label_top = _make_name_label(true)
	add_child(_name_label_top)

	# Countdown label (shown during goal reset)
	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cls := LabelSettings.new()
	cls.font_size = 120
	cls.font_color = Color.WHITE
	cls.outline_size = 8
	cls.outline_color = Color(0, 0, 0, 0.8)
	_countdown_label.label_settings = cls
	_countdown_label.visible = false
	_countdown_label.z_index = 10
	add_child(_countdown_label)

	# Setup game
	await get_tree().process_frame
	_setup_arena()
	_reset_positions()
	_update_score_labels()
	_start_countdown()


func _setup_arena() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	_arena_rect = Rect2(
		ARENA_MARGIN, ARENA_MARGIN,
		vp_size.x - ARENA_MARGIN * 2,
		vp_size.y - ARENA_MARGIN * 2
	)
	# Goal rects (bottom and top)
	var goal_x := (vp_size.x - GOAL_WIDTH) / 2.0
	_goal_rects[0] = Rect2(goal_x, vp_size.y - ARENA_MARGIN - GOAL_DEPTH, GOAL_WIDTH, GOAL_DEPTH + 10)
	_goal_rects[1] = Rect2(goal_x, ARENA_MARGIN - 10, GOAL_WIDTH, GOAL_DEPTH + 10)


func _reset_positions() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var center := vp_size / 2.0
	_puck_pos = center
	_puck_vel = Vector2.ZERO
	_paddle_pos[0] = Vector2(center.x, center.y + vp_size.y * 0.3) # Bottom player
	_paddle_pos[1] = Vector2(center.x, center.y - vp_size.y * 0.3) # Top player
	_puck_trail.clear()


func _start_countdown() -> void:
	_paused = true
	_countdown_label.visible = true
	_countdown_label.text = "3"
	_countdown_label.modulate.a = 1.0

	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func(): _countdown_label.text = "2")
	tw.tween_interval(0.6)
	tw.tween_callback(func(): _countdown_label.text = "1")
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		_countdown_label.text = "¡GO!"
		# Give puck a random starting push
		var angle := randf_range(-PI / 4, PI / 4)
		if randi() % 2 == 0:
			angle += PI
		_puck_vel = Vector2.from_angle(angle) * PUCK_START_SPEED
	)
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		_countdown_label.visible = false
		_paused = false
	)


func _process(delta: float) -> void:
	if _paused or _game_over:
		_canvas.queue_redraw()
		_decay_flashes(delta)
		return

	_update_puck(delta)
	_check_paddle_collisions()
	_check_wall_collisions()
	_check_goals()

	# Trail
	_puck_trail.push_front(_puck_pos)
	if _puck_trail.size() > TRAIL_LENGTH:
		_puck_trail.resize(TRAIL_LENGTH)

	_decay_flashes(delta)
	_canvas.queue_redraw()


func _update_puck(delta: float) -> void:
	_puck_vel *= PUCK_FRICTION
	# Clamp speed
	if _puck_vel.length() > PUCK_MAX_SPEED:
		_puck_vel = _puck_vel.normalized() * PUCK_MAX_SPEED
	_puck_pos += _puck_vel * delta


func _check_wall_collisions() -> void:
	var left := _arena_rect.position.x + PUCK_RADIUS
	var right := _arena_rect.end.x - PUCK_RADIUS
	var top := _arena_rect.position.y + PUCK_RADIUS
	var bottom := _arena_rect.end.y - PUCK_RADIUS

	# Left/right walls
	if _puck_pos.x < left:
		_puck_pos.x = left
		_puck_vel.x = abs(_puck_vel.x)
		_add_impact(Vector2(left, _puck_pos.y), Color(0.4, 0.8, 1.0))
	elif _puck_pos.x > right:
		_puck_pos.x = right
		_puck_vel.x = - abs(_puck_vel.x)
		_add_impact(Vector2(right, _puck_pos.y), Color(0.4, 0.8, 1.0))

	# Top/bottom walls (outside goal area)
	var goal_left = _goal_rects[0].position.x
	var goal_right = _goal_rects[0].end.x

	if _puck_pos.y < top and (_puck_pos.x < goal_left or _puck_pos.x > goal_right):
		_puck_pos.y = top
		_puck_vel.y = abs(_puck_vel.y)
		_add_impact(Vector2(_puck_pos.x, top), Color(0.4, 0.8, 1.0))
	elif _puck_pos.y > bottom and (_puck_pos.x < goal_left or _puck_pos.x > goal_right):
		_puck_pos.y = bottom
		_puck_vel.y = - abs(_puck_vel.y)
		_add_impact(Vector2(_puck_pos.x, bottom), Color(0.4, 0.8, 1.0))

	# Goal post collisions (edges of goal openings)
	for goal_idx in 2:
		var gr: Rect2 = _goal_rects[goal_idx]
		var post_left := Vector2(gr.position.x, gr.position.y if goal_idx == 1 else gr.end.y)
		var post_right := Vector2(gr.end.x, post_left.y)
		for post_pos in [post_left, post_right]:
			var diff = _puck_pos - post_pos
			if diff.length() < PUCK_RADIUS:
				_puck_vel = diff.normalized() * _puck_vel.length()
				_puck_pos = post_pos + diff.normalized() * PUCK_RADIUS
				_add_impact(post_pos, player1_color if goal_idx == 0 else player2_color)


func _check_paddle_collisions() -> void:
	for i in 2:
		var diff = _puck_pos - _paddle_pos[i]
		var dist = diff.length()
		var min_dist := PUCK_RADIUS + PADDLE_RADIUS
		if dist < min_dist and dist > 0:
			var normal = diff.normalized()
			_puck_pos = _paddle_pos[i] + normal * min_dist
			# Reflect velocity + add paddle push
			_puck_vel = normal * max(_puck_vel.length(), PUCK_START_SPEED * 0.8)
			var color := player1_color if i == 0 else player2_color
			_add_impact(_paddle_pos[i] + normal * PADDLE_RADIUS, color)


func _check_goals() -> void:
	if _goal_scored:
		return
	# Bottom goal (player 1's goal) — player 2 scores
	if _goal_rects[0].has_point(_puck_pos):
		_on_goal(1)
	# Top goal (player 2's goal) — player 1 scores
	elif _goal_rects[1].has_point(_puck_pos):
		_on_goal(0)


func _on_goal(scorer_idx: int) -> void:
	_goal_scored = true
	_paused = true
	_score[scorer_idx] += 1
	_update_score_labels()

	# Goal flash
	var flash_color := player1_color if scorer_idx == 0 else player2_color
	var vp_size := get_viewport().get_visible_rect().size
	var flash_y := ARENA_MARGIN if scorer_idx == 0 else vp_size.y - ARENA_MARGIN
	for i in 5:
		_add_impact(Vector2(vp_size.x / 2.0 + randf_range(-100, 100), flash_y), flash_color, 0.6)

	# Check win condition
	if _score[scorer_idx] >= rounds_to_win:
		_game_over = true
		var tw := create_tween()
		tw.tween_interval(1.0)
		tw.tween_callback(func(): game_finished.emit(scorer_idx))
		return

	# Reset after delay
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func():
		_goal_scored = false
		_reset_positions()
		_start_countdown()
	)


func _add_impact(pos: Vector2, color: Color, duration: float = NEON_GLOW_DURATION) -> void:
	_impact_flashes.append({
		"pos": pos,
		"color": color,
		"timer": duration,
		"max_timer": duration,
	})


func _decay_flashes(delta: float) -> void:
	var i := _impact_flashes.size() - 1
	while i >= 0:
		_impact_flashes[i]["timer"] -= delta
		if _impact_flashes[i]["timer"] <= 0:
			_impact_flashes.remove_at(i)
		i -= 1


# ========== INPUT ==========

func _input(event: InputEvent) -> void:
	if _paused or _game_over:
		return
	var vp_size := get_viewport().get_visible_rect().size
	var center_y := vp_size.y / 2.0

	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed:
			# Determine which player based on Y position
			var player_idx := 0 if touch.position.y > center_y else 1
			_touch_map[touch.index] = player_idx
		else:
			_touch_map.erase(touch.index)

	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event
		if _touch_map.has(drag.index):
			var player_idx: int = _touch_map[drag.index]
			_move_paddle(player_idx, drag.position)

	# Mouse fallback for desktop testing
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				var player_idx := 0 if mb.position.y > center_y else 1
				_touch_map[-1] = player_idx
				_move_paddle(player_idx, mb.position)
			else:
				_touch_map.erase(-1)

	elif event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		if _touch_map.has(-1):
			var player_idx: int = _touch_map[-1]
			_move_paddle(player_idx, mm.position)


func _move_paddle(player_idx: int, pos: Vector2) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var center_y := vp_size.y / 2.0

	# Clamp to arena bounds
	var x = clamp(pos.x, _arena_rect.position.x + PADDLE_RADIUS, _arena_rect.end.x - PADDLE_RADIUS)
	var y := pos.y

	# Clamp to player's half (with dead zone)
	if player_idx == 0: # Bottom
		y = clamp(y, center_y + CENTER_DEAD_ZONE, _arena_rect.end.y - PADDLE_RADIUS)
	else: # Top
		y = clamp(y, _arena_rect.position.y + PADDLE_RADIUS, center_y - CENTER_DEAD_ZONE)

	_paddle_pos[player_idx] = Vector2(x, y)


# ========== DRAWING ==========

func _draw_arena() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var center := vp_size / 2.0

	# Arena border
	_canvas.draw_rect(_arena_rect, Color(0.3, 0.5, 1.0, 0.6), false, BORDER_WIDTH)

	# Center line
	_canvas.draw_line(
		Vector2(_arena_rect.position.x, center.y),
		Vector2(_arena_rect.end.x, center.y),
		Color(0.3, 0.5, 1.0, 0.3), 2.0
	)

	# Center circle
	_canvas.draw_arc(center, 80.0, 0, TAU, 64, Color(0.3, 0.5, 1.0, 0.2), 2.0)

	# Goals
	for i in 2:
		var gr: Rect2 = _goal_rects[i]
		var color := player1_color if i == 0 else player2_color
		_canvas.draw_rect(gr, Color(color, 0.15), true)
		# Goal opening line
		var y_line := gr.position.y if i == 1 else gr.end.y
		_canvas.draw_line(
			Vector2(gr.position.x, y_line),
			Vector2(gr.end.x, y_line),
			Color(color, 0.8), 3.0
		)

	# Dead zone indicator (subtle)
	var dz_rect := Rect2(
		_arena_rect.position.x, center.y - CENTER_DEAD_ZONE,
		_arena_rect.size.x, CENTER_DEAD_ZONE * 2
	)
	_canvas.draw_rect(dz_rect, Color(1, 1, 1, 0.03), true)

	# Impact flashes (glow effect)
	for flash in _impact_flashes:
		var t: float = flash["timer"] / flash["max_timer"]
		var alpha := t * 0.6
		var radius := (1.0 - t) * 60.0 + 20.0
		var color: Color = flash["color"]
		_canvas.draw_circle(flash["pos"], radius, Color(color, alpha * 0.3))
		_canvas.draw_circle(flash["pos"], radius * 0.5, Color(color, alpha * 0.5))
		_canvas.draw_circle(flash["pos"], radius * 0.2, Color(color, alpha))

	# Puck trail
	for i in _puck_trail.size():
		var t := 1.0 - float(i) / float(TRAIL_LENGTH)
		var r := PUCK_RADIUS * t * 0.6
		_canvas.draw_circle(_puck_trail[i], r, Color(1, 1, 1, t * 0.15))

	# Puck
	_canvas.draw_circle(_puck_pos, PUCK_RADIUS + 4, Color(1, 1, 1, 0.15)) # Outer glow
	_canvas.draw_circle(_puck_pos, PUCK_RADIUS, Color(0.9, 0.9, 0.95))
	_canvas.draw_circle(_puck_pos, PUCK_RADIUS * 0.4, Color(0.7, 0.7, 0.8))

	# Paddles
	for i in 2:
		var color := player1_color if i == 0 else player2_color
		_canvas.draw_circle(_paddle_pos[i], PADDLE_RADIUS + 6, Color(color, 0.2)) # Glow
		_canvas.draw_circle(_paddle_pos[i], PADDLE_RADIUS, Color(color, 0.9))
		_canvas.draw_circle(_paddle_pos[i], PADDLE_RADIUS * 0.5, Color(color.lightened(0.3), 0.8))
		_canvas.draw_arc(_paddle_pos[i], PADDLE_RADIUS, 0, TAU, 32, Color(color.lightened(0.5)), 2.0)


# ========== UI HELPERS ==========

func _make_score_label(is_top: bool) -> Label:
	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ls := LabelSettings.new()
	ls.font_size = 72
	ls.font_color = Color(1, 1, 1, 0.12)
	ls.outline_size = 0
	lbl.label_settings = ls
	lbl.z_index = 1

	# Position in the middle of each half
	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lbl.grow_vertical = Control.GROW_DIRECTION_BOTH
	lbl.custom_minimum_size = Vector2(200, 100)
	lbl.pivot_offset = Vector2(100, 50)

	if is_top:
		lbl.rotation = PI # Rotated 180° for top player
		lbl.anchor_top = 0.22
		lbl.anchor_bottom = 0.22
	else:
		lbl.anchor_top = 0.78
		lbl.anchor_bottom = 0.78

	lbl.anchor_left = 0.5
	lbl.anchor_right = 0.5
	lbl.offset_left = -100
	lbl.offset_right = 100
	lbl.offset_top = -50
	lbl.offset_bottom = 50

	return lbl


func _make_name_label(is_top: bool) -> Label:
	var lbl := Label.new()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ls := LabelSettings.new()
	ls.font_size = 48
	ls.font_color = (player2_color if is_top else player1_color).lightened(0.2)
	ls.outline_size = 4
	ls.outline_color = Color(0, 0, 0, 0.6)
	lbl.label_settings = ls
	lbl.text = player2_name if is_top else player1_name
	lbl.z_index = 1

	lbl.set_anchors_preset(Control.PRESET_CENTER)
	lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	lbl.grow_vertical = Control.GROW_DIRECTION_BOTH
	lbl.custom_minimum_size = Vector2(300, 40)
	lbl.pivot_offset = Vector2(150, 20)

	if is_top:
		lbl.rotation = PI
		lbl.anchor_top = 0.12
		lbl.anchor_bottom = 0.12
	else:
		lbl.anchor_top = 0.88
		lbl.anchor_bottom = 0.88

	lbl.anchor_left = 0.5
	lbl.anchor_right = 0.5
	lbl.offset_left = -150
	lbl.offset_right = 150
	lbl.offset_top = -20
	lbl.offset_bottom = 20

	return lbl


func _update_score_labels() -> void:
	_score_label_bottom.text = str(_score[0])
	_score_label_top.text = str(_score[1])
