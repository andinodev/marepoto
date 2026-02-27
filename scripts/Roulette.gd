extends Control
## Roulette — Spinning wheel component with dynamic segment drawing.

signal spin_completed(winner_name: String, is_all: bool)

const TODOS_COLOR := Color("#fa15e7ff")
const TODOS_SEGMENT_RATIO := 0.15 # "TODOS" takes ~15% of wheel
const SPIN_DURATION := 3.5
const MIN_ROTATIONS := 4.0
const MAX_ROTATIONS := 7.0
const POINTER_COLOR := Color("#ffe600ff")
const SFX_SPIN: AudioStream = preload("res://sounds/spin-wheel.mp3")
const SFX_SELECTED: AudioStream = preload("res://sounds/player-selected.wav")

var _segments: Array[Dictionary] = [] # {name, color, start_angle, end_angle, is_all}
var _current_rotation: float = 0.0
var _is_spinning: bool = false
var _radius: float = 800
var _last_winners: Array[String] = []
const MAX_HISTORY := 2


func is_spinning() -> bool:
	return _is_spinning


func _ready() -> void:
	build_segments()


func _draw() -> void:
	var center := size / 2.0
	_radius = min(center.x, center.y) * 1.32

	var border_width := _radius * 0.075 # Thick border ring
	var inner_radius := _radius - border_width

	# --- 1. Outer glow (soft neon halo) ---
	# for i in range(4, 0, -1):
	# 	var glow_r := _radius + border_width * 0.5 + (i * 32)
	# 	draw_arc(center, glow_r, 0, TAU, 128, Color(POINTER_COLOR, 0.06 * i), 4.0)

	# --- 2. Border ring (dark metallic) ---
	var ring_points := 128
	var ring_color_outer := Color("#8B0000") # Deep red
	var ring_color_inner := Color("#C0392B") # Lighter red
	# Draw thick ring as filled arc between inner_radius and _radius
	for i in range(ring_points):
		var a1 := TAU * (float(i) / ring_points)
		var a2 := TAU * (float(i + 1) / ring_points)
		var outer1 := center + Vector2(cos(a1), sin(a1)) * _radius
		var outer2 := center + Vector2(cos(a2), sin(a2)) * _radius
		var inner1 := center + Vector2(cos(a1), sin(a1)) * inner_radius
		var inner2 := center + Vector2(cos(a2), sin(a2)) * inner_radius
		var blend := float(i) / ring_points
		var ring_col := ring_color_outer.lerp(ring_color_inner, sin(blend * TAU) * 0.5 + 0.5)
		draw_colored_polygon(PackedVector2Array([outer1, outer2, inner2, inner1]), ring_col)

	# Inner edge highlight
	draw_arc(center, inner_radius, 0, TAU, 128, Color(1, 1, 1, 0.15), 1.5)
	# Outer edge highlight
	draw_arc(center, _radius, 0, TAU, 128, Color(0, 0, 0, 0.4), 2.0)

	# --- 3. Draw segments (inside inner_radius) ---
	for seg in _segments:
		_draw_segment(center, seg, inner_radius)

	# --- 4. Segment divider lines ---
	for seg in _segments:
		var start_a: float = seg["start_angle"] + _current_rotation
		var edge_pt := center + Vector2(cos(start_a), sin(start_a)) * inner_radius
		draw_line(center, edge_pt, Color(0, 0, 0, 0.5), 2.5)
		# Bright inner line for depth
		var center_offset := center + Vector2(cos(start_a), sin(start_a)) * 15.0
		draw_line(center_offset, edge_pt, Color(1, 1, 1, 0.08), 1.0)

	# --- 5. Decorative studs around the border ring ---
	var stud_count := _segments.size() * 3
	if stud_count < 16:
		stud_count = 16
	var stud_radius_pos := (_radius + inner_radius) / 2.0
	var stud_size := border_width * 0.18
	for i in range(stud_count):
		var angle := TAU * (float(i) / stud_count)
		var stud_pos := center + Vector2(cos(angle), sin(angle)) * stud_radius_pos
		# Gold stud with highlight
		draw_circle(stud_pos, stud_size + 1.0, Color(0, 0, 0, 0.3))
		draw_circle(stud_pos, stud_size, Color("#DAA520"))
		draw_circle(stud_pos, stud_size * 0.5, Color("#FFD700", 0.7))

	# --- 6. Center hub (metallic gold) ---
	var hub_r := inner_radius * 0.14
	# Shadow
	draw_circle(center + Vector2(0, 2), hub_r + 3, Color(0, 0, 0, 0.3))
	# Outer ring
	draw_circle(center, hub_r + 3, Color("#8B6508"))
	# Main hub - gradient simulated with layers
	draw_circle(center, hub_r, Color("#DAA520"))
	draw_circle(center, hub_r * 0.8, Color("#FFD700"))
	draw_circle(center, hub_r * 0.5, Color("#FFF8DC", 0.6))
	# Highlight
	draw_arc(center, hub_r, -PI * 0.7, -PI * 0.2, 32, Color(1, 1, 1, 0.4), 2.0)

	# --- 7. Pointer (premium triangle at top) ---
	var ptr_h := _radius * 0.12
	var ptr_w := _radius * 0.08
	var ptr_tip := Vector2(center.x, center.y - inner_radius + ptr_h * 0.3)
	var ptr_left := Vector2(center.x - ptr_w, center.y - _radius - ptr_h * 0.5)
	var ptr_right := Vector2(center.x + ptr_w, center.y - _radius - ptr_h * 0.5)
	# Shadow
	var shadow_offset := Vector2(0, 3)
	draw_colored_polygon(PackedVector2Array([ptr_left + shadow_offset, ptr_right + shadow_offset, ptr_tip + shadow_offset]), Color(0, 0, 0, 0.35))
	# Main pointer
	draw_colored_polygon(PackedVector2Array([ptr_left, ptr_right, ptr_tip]), POINTER_COLOR)
	# Highlight
	var ptr_center_x := (ptr_left.x + ptr_right.x + ptr_tip.x) / 3.0
	var ptr_center_y := (ptr_left.y + ptr_right.y + ptr_tip.y) / 3.0
	var ptr_mid := Vector2(ptr_center_x, ptr_center_y)
	draw_colored_polygon(
		PackedVector2Array([
			ptr_left.lerp(ptr_mid, 0.3),
			Vector2(center.x, ptr_left.y),
			ptr_tip.lerp(ptr_mid, 0.3)
		]),
		Color(1, 1, 1, 0.2)
	)
	# Pointer base stud
	var base_center := Vector2(center.x, center.y - _radius - ptr_h * 0.25)
	draw_circle(base_center, ptr_w * 0.4, Color("#DAA520"))
	draw_circle(base_center, ptr_w * 0.25, Color("#FFD700", 0.7))


func _draw_segment(center: Vector2, seg: Dictionary, seg_radius: float) -> void:
	var start_a: float = seg["start_angle"] + _current_rotation
	var end_a: float = seg["end_angle"] + _current_rotation
	var arc_angle := end_a - start_a
	var num_points := maxi(int(abs(arc_angle) / 0.05), 8)
	var base_color: Color = seg["color"]

	# Draw segment with radial gradient (3 concentric bands: dark center → bright → slightly dark edge)
	var band_count := 5
	var band_ratios := [0.0, 0.15, 0.35, 0.7, 0.95, 1.0]
	var band_colors := [
		base_color.darkened(0.50), # Dark center
		base_color.darkened(0.25), # Full color mid
		base_color.darkened(0.15), # Slightly darker edge,
		base_color.darkened(0.15), # Full color mid
		base_color.darkened(0.50), # Slightly darker edge


	]

	for b in range(band_count):
		var r_inner = seg_radius * band_ratios[b]
		var r_outer = seg_radius * band_ratios[b + 1]
		var color = band_colors[b]

		var band_points := PackedVector2Array()
		# Inner arc (from center outward)
		for i in range(num_points + 1):
			var angle := start_a + arc_angle * (float(i) / num_points)
			if r_inner < 1.0:
				band_points.append(center)
				break
			else:
				band_points.append(center + Vector2(cos(angle), sin(angle)) * r_inner)

		# Outer arc (reverse direction)
		for i in range(num_points, -1, -1):
			var angle := start_a + arc_angle * (float(i) / num_points)
			band_points.append(center + Vector2(cos(angle), sin(angle)) * r_outer)

		draw_colored_polygon(band_points, color)

	# Subtle shine on upper half of segment
	var mid_angle := (start_a + end_a) / 2.0
	var shine_dir := Vector2(cos(mid_angle), sin(mid_angle))
	if shine_dir.y < 0: # Upper segments get a shine
		var shine_points := PackedVector2Array()
		shine_points.append(center)
		for i in range(num_points + 1):
			var angle := start_a + arc_angle * (float(i) / num_points)
			shine_points.append(center + Vector2(cos(angle), sin(angle)) * seg_radius * 0.5)
		draw_colored_polygon(shine_points, Color(1, 1, 1, 0.07))

	# Label
	var label_pos := center + Vector2(cos(mid_angle), sin(mid_angle)) * (seg_radius * 0.55)
	var label_text: String = seg["name"]
	if label_text.length() > 8:
		label_text = label_text.left(7) + "."

	var font := ThemeDB.fallback_font
	var font_size := 44
	var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_offset := text_size / 2.0

	# Text shadow (dark outline for readability)
	var shadow_color := Color(0, 0, 0, 0.85)
	for offset in [Vector2(2, 2), Vector2(-2, 2), Vector2(2, -2), Vector2(-2, -2), Vector2(0, 2), Vector2(2, 0), Vector2(-2, 0), Vector2(0, -2)]:
		draw_string(font, label_pos - text_offset + offset, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, shadow_color)
	# Main text (white for max contrast)
	draw_string(font, label_pos - text_offset, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)


func build_segments() -> void:
	_segments.clear()
	var players := GameManager.players
	if players.is_empty():
		queue_redraw()
		return

	var total_segments := players.size() + 1 # players + TODOS
	var segment_angle := TAU / float(total_segments)

	var angle := -PI / 2.0 # Start from top

	for player in players:
		_segments.append({
			"name": player["name"],
			"color": player["color"],
			"start_angle": angle,
			"end_angle": angle + segment_angle,
			"is_all": false,
		})
		angle += segment_angle

	# "TODOS" segment (same size as player segments)
	_segments.append({
		"name": "TODOS",
		"color": TODOS_COLOR,
		"start_angle": angle,
		"end_angle": angle + segment_angle,
		"is_all": true,
	})

	queue_redraw()


func reset() -> void:
	_current_rotation = 0.0
	_last_winners.clear()
	queue_redraw()


func spin() -> void:
	if _is_spinning or _segments.is_empty():
		return
	_is_spinning = true
	AudioManager.play_sfx(SFX_SPIN)

	# --- Anti-repetition: pick a target segment avoiding recent winners ---
	var candidates: Array[Dictionary] = []
	for seg in _segments:
		if not _last_winners.has(seg["name"]):
			candidates.append(seg)
	# Fallback: if all segments are in history, allow any
	if candidates.is_empty():
		candidates = _segments.duplicate()

	var target_seg: Dictionary = candidates[randi() % candidates.size()]

	# Calculate the exact rotation to land the pointer on the middle of the target segment.
	# Pointer is fixed at -PI/2 (top). A segment is hit when:
	#   seg.start_angle + rotation <= -PI/2 <= seg.end_angle + rotation
	# So we need rotation such that the pointer in local space falls at the segment midpoint.
	var seg_mid: float = (target_seg["start_angle"] + target_seg["end_angle"]) / 2.0
	# Add slight jitter so it doesn't always land dead-center (±30% of segment arc)
	var seg_arc: float = target_seg["end_angle"] - target_seg["start_angle"]
	var jitter: float = randf_range(-0.3, 0.3) * seg_arc
	var landing_angle: float = seg_mid + jitter

	# The pointer is at -PI/2. We need: landing_angle + final_rotation ≡ -PI/2 (mod TAU)
	# => final_rotation = -PI/2 - landing_angle  (then normalize)
	var base_rotation: float = (-PI / 2.0) - landing_angle
	# Normalize to [0, TAU)
	base_rotation = fmod(base_rotation, TAU)
	if base_rotation < 0:
		base_rotation += TAU

	# Add full rotations for the spinning animation
	var full_spins: float = randf_range(MIN_ROTATIONS, MAX_ROTATIONS)
	var target_rotation: float = _current_rotation + base_rotation + TAU * full_spins
	# Ensure we always spin forward (clockwise)
	if target_rotation <= _current_rotation:
		target_rotation += TAU

	var tween := create_tween()
	tween.tween_property(self , "_current_rotation", target_rotation, SPIN_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_on_spin_finished)


func _process(_delta: float) -> void:
	if _is_spinning:
		queue_redraw()


func _on_spin_finished() -> void:
	_is_spinning = false
	AudioManager.stop_sfx(SFX_SPIN)
	queue_redraw()

	# The pointer is fixed at the top of the screen: angle = -PI/2 in screen space.
	# The wheel has been rotated by _current_rotation (added to each segment's draw angle).
	# So in the wheel's LOCAL coordinate system, the pointer sits at:
	#   local_pointer = (-PI/2) - _current_rotation
	# Segments are defined with start_angle in [-PI/2, -PI/2 + TAU), so normalize to that range.
	var local_pointer := fmod((-PI / 2.0) - _current_rotation, TAU)
	# Normalize to [-PI/2, -PI/2 + TAU)
	while local_pointer < -PI / 2.0:
		local_pointer += TAU
	while local_pointer >= -PI / 2.0 + TAU:
		local_pointer -= TAU

	for seg in _segments:
		var s: float = seg["start_angle"]
		var e: float = seg["end_angle"]
		if local_pointer >= s and local_pointer < e:
			_record_winner(seg["name"])
			AudioManager.play_sfx(SFX_SELECTED)
			spin_completed.emit(seg["name"], seg["is_all"])
			return

	# Fallback (should not happen)
	if not _segments.is_empty():
		_record_winner(_segments[0]["name"])
		spin_completed.emit(_segments[0]["name"], _segments[0]["is_all"])


func _record_winner(winner_name: String) -> void:
	_last_winners.append(winner_name)
	if _last_winners.size() > MAX_HISTORY:
		_last_winners.remove_at(0)
