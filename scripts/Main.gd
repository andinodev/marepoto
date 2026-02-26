extends Control
## Main.gd — Root controller: manages SetupUI, GameUI and ChallengeModal visibility.

@onready var setup_ui: Control = $SetupUI
@onready var game_ui: Control = $GameUI
@onready var challenge_modal: Control = $ChallengeModal
@onready var roulette: Control = $GameUI/SafeMargin/GameContent/RouletteContainer/Roulette

# Setup UI refs
@onready var setup_safe_margin: MarginContainer = $SetupUI/SafeMargin
@onready var player_name_input: LineEdit = $SetupUI/SafeMargin/VBox/InputRow/PlayerNameInput
@onready var add_player_btn: Button = $SetupUI/SafeMargin/VBox/InputRow/AddPlayerBtn
@onready var player_list_container: VBoxContainer = $SetupUI/SafeMargin/VBox/PlayerListScroll/PlayerList
@onready var start_btn: Button = $SetupUI/SafeMargin/VBox/StartBtn
@onready var manage_btn: Button = $SetupUI/SafeMargin/VBox/ManageBtn
@onready var setup_title: Label = $SetupUI/SafeMargin/VBox/Title

# Game UI refs
@onready var game_safe_margin: MarginContainer = $GameUI/SafeMargin
@onready var turn_label: Label = $GameUI/SafeMargin/GameContent/TopBar/HBox/TurnLabel
@onready var back_to_menu_btn: Button = $GameUI/SafeMargin/GameContent/TopBar/HBox/BackToMenuBtn
@onready var spin_btn: Button = $GameUI/SafeMargin/GameContent/SpinBtn

# Challenge modal refs
@onready var challenge_player: RichTextLabel = $ChallengeModal/Panel/VBox/MarginContainer/VBox/ChallengePlayer
@onready var challenge_title: Label = $ChallengeModal/Panel/VBox/ChallengeTitle
@onready var challenge_story: Label = $ChallengeModal/Panel/VBox/MarginContainer/VBox/ChallengeStory
@onready var challenge_action: Label = $ChallengeModal/Panel/VBox/MarginContainer/VBox/ChallengeAction
@onready var sips_label: Label = $ChallengeModal/Panel/VBox/SipsContainer/SipsLabel
@onready var timer_container: HBoxContainer = $ChallengeModal/Panel/VBox/TimerContainer
@onready var timer_label: Label = $ChallengeModal/Panel/VBox/TimerContainer/TimerLabel
@onready var timer_btn: Button = $ChallengeModal/Panel/VBox/TimerContainer/TimerBtn
@onready var done_btn: Button = $ChallengeModal/Panel/VBox/DoneBtn

const ChallengeManagerScene := preload("res://scenes/ChallengeManager.tscn")
const BANNER_TEX: Texture2D = preload("res://sprites/ui/PNG/Double/banner_classic_curtain.png")
const MODAL_PANEL_TEX: Texture2D = preload("res://sprites/ui/PNG/Double/panel_brown_corners_a.png")

var _challenge_timer: Timer
var _timer_seconds: int = 0
var _timer_running: bool = false
var _challenge_manager: Control = null
var _is_transitioning: bool = false


func _ready() -> void:
	# Setup timer node
	_challenge_timer = Timer.new()
	_challenge_timer.one_shot = false
	_challenge_timer.wait_time = 1.0
	_challenge_timer.timeout.connect(_on_timer_tick)
	add_child(_challenge_timer)

	# Connect signals
	add_player_btn.pressed.connect(_on_add_player)
	player_name_input.text_submitted.connect(func(_text: String) -> void: _on_add_player())
	start_btn.pressed.connect(_on_start_game)
	manage_btn.pressed.connect(_on_manage_challenges)
	back_to_menu_btn.pressed.connect(_on_back_to_menu)
	spin_btn.pressed.connect(_on_spin)
	done_btn.pressed.connect(_on_challenge_done)
	timer_btn.pressed.connect(_on_timer_start)
	roulette.spin_completed.connect(_on_spin_completed)
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.game_started.connect(roulette.reset)

	# _apply_neon_theme()
	_apply_safe_zone()
	_on_state_changed(GameManager.State.SETUP)

## ---------- Safe Zone ----------

func _apply_safe_zone() -> void:
	# SetupUI: safe insets + design padding (40 sides, 80 top, 40 bottom)
	SafeZoneManager.apply_to_margin(setup_safe_margin, 80, 40, 40, 40)
	# GameUI: safe insets + minimal padding
	SafeZoneManager.apply_to_margin(game_safe_margin, 0, 0, 0, 0)
	# Re-apply on changes (e.g. rotation)
	if not SafeZoneManager.safe_area_changed.is_connected(_on_safe_area_changed):
		SafeZoneManager.safe_area_changed.connect(_on_safe_area_changed)


func _on_safe_area_changed(_top: int, _bottom: int, _left: int, _right: int) -> void:
	_apply_safe_zone()


## ---------- Neón Selvático Theme ----------

func _apply_neon_theme() -> void:
	var neon_green := Color("#22c55e")
	var neon_yellow := Color("#facc15")
	var dark_bg := Color("#1a1a2e")
	var darker_bg := Color("#0f0f1a")

	# Style all buttons
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = dark_bg
	btn_normal.border_color = neon_green
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(12)
	btn_normal.set_content_margin_all(12)

	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(neon_green, 0.15)
	btn_hover.border_color = neon_green
	btn_hover.set_border_width_all(3)
	btn_hover.set_corner_radius_all(12)
	btn_hover.set_content_margin_all(12)

	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = Color(neon_green, 0.3)
	btn_pressed.border_color = neon_yellow
	btn_pressed.set_border_width_all(3)
	btn_pressed.set_corner_radius_all(12)
	btn_pressed.set_content_margin_all(12)

	var btn_disabled := StyleBoxFlat.new()
	btn_disabled.bg_color = Color(0.1, 0.1, 0.1, 0.5)
	btn_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5)
	btn_disabled.set_border_width_all(1)
	btn_disabled.set_corner_radius_all(12)
	btn_disabled.set_content_margin_all(12)

	for btn: Button in _get_all_buttons(self ):
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("disabled", btn_disabled)
		btn.add_theme_color_override("font_color", neon_green)
		btn.add_theme_color_override("font_hover_color", neon_yellow)
		btn.add_theme_color_override("font_pressed_color", neon_yellow)
		btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))
		btn.add_theme_font_size_override("font_size", 36)

	# Style spin button bigger
	spin_btn.add_theme_font_size_override("font_size", 52)

	# Style start button
	start_btn.add_theme_font_size_override("font_size", 48)

	# Style panels
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.06, 0.12, 0.95)
	panel_style.border_color = neon_green
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(16)
	panel_style.set_content_margin_all(24)

	var modal_panel := challenge_modal.get_node_or_null("Panel") as PanelContainer

	for panel: PanelContainer in _get_all_panels(self ):
		# Skip modal panel — it gets a special style below
		if panel == modal_panel:
			continue
		panel.add_theme_stylebox_override("panel", panel_style)

	# --- ChallengeModal: decorative panel with corner ornaments ---
	if modal_panel:
		var modal_sbt := StyleBoxTexture.new()
		modal_sbt.texture = MODAL_PANEL_TEX
		modal_sbt.texture_margin_left = 24.0
		modal_sbt.texture_margin_top = 24.0
		modal_sbt.texture_margin_right = 24.0
		modal_sbt.texture_margin_bottom = 24.0
		modal_sbt.content_margin_left = 32.0
		modal_sbt.content_margin_top = 32.0
		modal_sbt.content_margin_right = 32.0
		modal_sbt.content_margin_bottom = 32.0
		# Light tint to preserve texture detail (corners, border ornaments)
		modal_sbt.modulate_color = Color(0.85, 0.75, 0.65, 1.0)
		modal_panel.add_theme_stylebox_override("panel", modal_sbt)

	# --- ChallengeTitle: banner ribbon behind the title ---
	_setup_title_banner()

	# Style LineEdit
	var line_style := StyleBoxFlat.new()
	line_style.bg_color = darker_bg
	line_style.border_color = Color(neon_green, 0.5)
	line_style.set_border_width_all(2)
	line_style.set_corner_radius_all(8)
	line_style.set_content_margin_all(10)
	player_name_input.add_theme_stylebox_override("normal", line_style)
	player_name_input.add_theme_color_override("font_color", Color.WHITE)
	player_name_input.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.5))
	player_name_input.add_theme_font_size_override("font_size", 32)


func _setup_title_banner() -> void:
	# Wrap challenge_title in a container with a NinePatchRect banner behind it
	var vbox := challenge_title.get_parent()
	var idx := challenge_title.get_index()

	# Create a container that holds the banner + label
	var banner_container := Control.new()
	banner_container.name = "BannerContainer"
	banner_container.custom_minimum_size = Vector2(0, 250)
	banner_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# NinePatchRect for the banner ribbon
	var banner := NinePatchRect.new()
	banner.name = "BannerBg"
	banner.texture = BANNER_TEX
	# 9-patch margins for the curtain banner (wider left/right for the folds)
	banner.patch_margin_left = 40
	banner.patch_margin_right = 40
	banner.patch_margin_top = 12
	banner.patch_margin_bottom = 20
	banner.anchor_left = 0.0
	banner.anchor_top = 0.0
	banner.anchor_right = 1.0
	banner.anchor_bottom = 1.0
	banner.offset_left = -20.0
	banner.offset_right = 20.0
	banner.offset_top = -5.0
	banner.offset_bottom = 5.0
	banner_container.add_child(banner)

	# Move the label into the banner container
	vbox.remove_child(challenge_title)
	challenge_title.anchor_left = 0.0
	challenge_title.anchor_top = 0.0
	challenge_title.anchor_right = 1.0
	challenge_title.anchor_bottom = 1.0
	challenge_title.offset_left = 40.0
	challenge_title.offset_right = -40.0
	challenge_title.offset_top = 0.0
	challenge_title.offset_bottom = 0.0
	challenge_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	challenge_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	challenge_title.add_theme_font_size_override("font_size", 40)
	challenge_title.add_theme_color_override("font_color", Color.WHITE)
	banner_container.add_child(challenge_title)

	# Insert at the same position in the VBox
	vbox.add_child(banner_container)
	vbox.move_child(banner_container, idx)


func _get_all_buttons(node: Node) -> Array[Button]:
	var result: Array[Button] = []
	if node is Button:
		result.append(node as Button)
	for child in node.get_children():
		result.append_array(_get_all_buttons(child))
	return result


func _get_all_panels(node: Node) -> Array[PanelContainer]:
	var result: Array[PanelContainer] = []
	if node is PanelContainer:
		result.append(node as PanelContainer)
	for child in node.get_children():
		result.append_array(_get_all_panels(child))
	return result


## ---------- State Management ----------

func _on_state_changed(new_state: int) -> void:
	# Challenge modal visibility is handled by its own tween animations
	if new_state == GameManager.State.CHALLENGE_VIEW:
		challenge_modal.visible = true
		spin_btn.visible = false
	elif new_state == GameManager.State.PLAYING:
		challenge_modal.visible = false
		spin_btn.visible = true
		if not game_ui.visible:
			_slide_transition(setup_ui, game_ui, -1) # slide left
	elif new_state == GameManager.State.SETUP:
		if game_ui.visible and not _is_transitioning:
			_slide_transition(game_ui, setup_ui, 1) # slide right
		else:
			setup_ui.visible = _challenge_manager == null
			game_ui.visible = false

	if new_state == GameManager.State.SETUP:
		_refresh_player_list()

	if new_state == GameManager.State.PLAYING:
		roulette.build_segments()
		turn_label.text = "MAREPOTO"


func _slide_transition(from_ui: Control, to_ui: Control, direction: int) -> void:
	var screen_w := get_viewport().get_visible_rect().size.x
	_is_transitioning = true

	# Position to_ui off-screen on the opposite side
	to_ui.visible = true
	to_ui.position.x = - direction * screen_w

	var tween := create_tween().set_parallel(true)
	tween.tween_property(from_ui, "position:x", direction * screen_w, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(to_ui, "position:x", 0.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback(func():
		from_ui.visible = false
		from_ui.position.x = 0.0
		_is_transitioning = false
	)


func _on_manage_challenges() -> void:
	setup_ui.visible = false
	_challenge_manager = ChallengeManagerScene.instantiate()
	_challenge_manager.closed.connect(_on_challenge_manager_closed)
	add_child(_challenge_manager)


func _on_challenge_manager_closed() -> void:
	if _challenge_manager:
		_challenge_manager.queue_free()
		_challenge_manager = null
	setup_ui.visible = true


## ---------- Setup ----------

func _on_add_player() -> void:
	var pname := player_name_input.text.strip_edges()
	if GameManager.add_player(pname):
		player_name_input.text = ""
		_refresh_player_list()
	player_name_input.grab_focus()


func _refresh_player_list() -> void:
	# Clear existing
	for child in player_list_container.get_children():
		child.queue_free()

	for i in GameManager.players.size():
		var player: Dictionary = GameManager.players[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)

		# Color indicator
		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(24, 24)
		color_rect.color = player["color"]
		row.add_child(color_rect)

		# Name label
		var name_lbl := Label.new()
		name_lbl.text = player["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var ls := LabelSettings.new()
		ls.font_color = Color.WHITE
		ls.font_size = 36
		name_lbl.label_settings = ls
		row.add_child(name_lbl)

		# Remove button
		var remove_btn := Button.new()
		remove_btn.text = "✕"
		remove_btn.custom_minimum_size = Vector2(40, 40)
		var idx := i
		remove_btn.pressed.connect(func() -> void:
			GameManager.remove_player(idx)
			_refresh_player_list()
		)
		row.add_child(remove_btn)

		player_list_container.add_child(row)

	# Enable start button when >= 2 players
	start_btn.disabled = GameManager.get_player_count() < 2
	start_btn.text = "¡A BEBER! (%d)" % GameManager.get_player_count() if GameManager.get_player_count() >= 2 else "Mínimo 2 jugadores"


func _on_start_game() -> void:
	if GameManager.get_player_count() >= 2:
		GameManager.start_game()


## ---------- Game ----------


func _on_spin() -> void:
	spin_btn.disabled = true
	back_to_menu_btn.disabled = true
	turn_label.text = "Buscando imputado"
	$AnimationPlayer.play("anim_spin")
	roulette.spin()


func _on_spin_completed(winner_name: String, is_all: bool) -> void:
	spin_btn.disabled = false
	back_to_menu_btn.disabled = false
	$AnimationPlayer.play("RESET")
	_show_challenge(winner_name, is_all)


func _on_back_to_menu() -> void:
	GameManager.return_to_setup()


## ---------- Challenge Modal ----------

func _show_challenge(winner_name: String, is_all: bool) -> void:
	var challenge := ChallengeDB.get_random_challenge(is_all)
	if challenge.is_empty():
		return

	var current_player := GameManager.get_current_player()
	var j1_name: String = winner_name
	var j2_player := GameManager.get_random_other_player()
	var j2_name: String = j2_player.get("name", "???")

	if is_all:
		challenge_player.text = "👥 ¡TODOS!"
	else:
		challenge_player.text = "Imputado/a: [b]%s[/b]" % winner_name

	var title_text: String = challenge.get("title", "")
	challenge_title.text = "🔥 %s" % title_text

	var story_text: String = challenge.get("story", "")
	story_text = story_text.replace("{J1}", j1_name).replace("{J2}", j2_name)
	challenge_story.text = story_text

	var action_text: String = challenge.get("action", "")
	action_text = action_text.replace("{J1}", j1_name).replace("{J2}", j2_name)
	challenge_action.text = action_text

	# Sips
	var sips_arr: Array = challenge.get("sips", [])
	if sips_arr.is_empty():
		sips_label.text = "Sin sorbos 🎉"
	else:
		var sips_text := ""
		for sip in sips_arr:
			var amount: int = int(sip.get("amount", 0))
			var condition: String = sip.get("condition", "")
			condition = condition.replace("{J1}", j1_name).replace("{J2}", j2_name)
			sips_text += "🍺 x%d — %s\n" % [amount, condition]
		sips_label.text = sips_text.strip_edges()

	# Timer
	var timer_val: int = int(challenge.get("timer", 0))
	if timer_val > 0:
		timer_container.visible = true
		_timer_seconds = timer_val
		_timer_running = false
		timer_label.text = _format_time(_timer_seconds)
		timer_btn.text = "⏱ Iniciar"
		timer_btn.disabled = false
	else:
		timer_container.visible = false

	# Target info in header
	challenge_title.text = "%s" % title_text

	GameManager.state = GameManager.State.CHALLENGE_VIEW

	# Animate modal entrance
	challenge_modal.modulate.a = 0.0
	challenge_modal.scale = Vector2(0.8, 0.8)
	challenge_modal.pivot_offset = challenge_modal.size / 2.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(challenge_modal, "modulate:a", 1.0, 0.3)
	tween.tween_property(challenge_modal, "scale", Vector2.ONE, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_challenge_done() -> void:
	_challenge_timer.stop()
	_timer_running = false
	done_btn.disabled = true
	challenge_modal.pivot_offset = challenge_modal.size / 2.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(challenge_modal, "modulate:a", 0.0, 0.25)
	tween.tween_property(challenge_modal, "scale", Vector2.ZERO, 0.1) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_callback(func():
		done_btn.disabled = false
		GameManager.next_turn()
		GameManager.state = GameManager.State.PLAYING
	)


func _on_timer_start() -> void:
	if not _timer_running:
		_timer_running = true
		_challenge_timer.start()
		timer_btn.text = "⏸ Pausar"
	else:
		_timer_running = false
		_challenge_timer.stop()
		timer_btn.text = "▶ Reanudar"


func _on_timer_tick() -> void:
	_timer_seconds -= 1
	timer_label.text = _format_time(_timer_seconds)
	if _timer_seconds <= 0:
		_challenge_timer.stop()
		_timer_running = false
		timer_label.text = "⏰ ¡TIEMPO!"
		timer_btn.disabled = true


func _format_time(seconds: int) -> String:
	var m := seconds / 60
	var s := seconds % 60
	return "%d:%02d" % [m, s]
