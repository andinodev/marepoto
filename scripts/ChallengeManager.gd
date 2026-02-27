extends Control
## ChallengeManager.gd — CRUD UI for challenges database.

signal closed

# --- Theme colors ---
const NEON_GREEN := Color("#22c55e")
const NEON_YELLOW := Color("#facc15")
const DARK_BG := Color("#1a1a2e")
const DARKER_BG := Color("#0f0f1a")
const CARD_BG := Color("#252545")
const DELETED_ALPHA := 0.4
const CARD_BORDER := Color("#22c55e", 0.4)
const PAGE_SIZE := 25

const TARGET_KEYS := ["SELF", "SPECIFIC", "ALL", "DISTRIBUTE"]
const TARGET_LABELS := ["Uno mismo", "Específico", "Todos", "Distribuir"]

const PASIVE_KEYS := ["X_PLAYER_TURN", "X_TURN", "ANY_TURN"]
const PASIVE_LABELS := ["Turno del jugador", "Turno general", "Permanente"]

# --- State ---
var _current_tab := "player" # "player" or "all"
var _search_text := ""
var _editing_id: int = -1 # -1 = creating new
var _editing_category := ""
var _current_page: int = 0
var _total_pages: int = 1

# --- Nodes (built in _ready) ---
var _tab_player_btn: Button
var _tab_all_btn: Button
var _search_input: LineEdit
var _list_container: VBoxContainer
var _scroll: ScrollContainer
var _form_overlay: Control
var _form_panel: PanelContainer
var _form_scroll: ScrollContainer
var _title_input: LineEdit
var _story_input: TextEdit
var _action_input: TextEdit
var _timer_spin: SpinBox
var _sips_container: VBoxContainer
var _pasive_container: VBoxContainer
var _save_btn: Button
var _cancel_btn: Button
var _form_title_label: Label
var _toast_label: Label
var _confirm_overlay: Control
var _confirm_label: Label
var _confirm_yes: Button
var _confirm_no: Button
var _pending_delete_id: int = -1
var _pending_delete_cat := ""


func _ready() -> void:
	# Full rect
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background
	var bg := ColorRect.new()
	bg.color = DARK_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main VBox
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 12)
	add_child(main_vbox)

	# --- Margin wrapper ---
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Apply safe-zone insets + design padding (24 sides, 20 top/bottom)
	SafeZoneManager.apply_to_margin(margin, 20, 20, 24, 24)
	main_vbox.add_child(margin)

	var content_vbox := VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 16)
	content_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(content_vbox)

	# --- Header ---
	_build_header(content_vbox)

	# --- Tab Bar ---
	_build_tab_bar(content_vbox)

	# --- Search + New ---
	_build_search_bar(content_vbox)

	# --- Challenge List ---
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_vbox.add_child(_scroll)

	_list_container = VBoxContainer.new()
	_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_container.add_theme_constant_override("separation", 12)
	_scroll.add_child(_list_container)

	# --- Form Overlay (hidden) ---
	_build_form_overlay()

	# --- Confirm Dialog (hidden) ---
	_build_confirm_dialog()

	# --- Toast (hidden) ---
	_build_toast()

	# Populate
	_refresh_list()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _confirm_overlay.visible:
			_on_confirm_no()
		elif _form_overlay.visible:
			_hide_form()
		else:
			_on_back()


## ======================================================================
##  HEADER
## ======================================================================

func _build_header(parent: VBoxContainer) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	parent.add_child(hbox)

	var back_btn := Button.new()
	back_btn.text = "← Volver"
	back_btn.custom_minimum_size = Vector2(180, 60)
	_style_button(back_btn, NEON_GREEN)
	back_btn.pressed.connect(_on_back)
	hbox.add_child(back_btn)

	var title_lbl := Label.new()
	title_lbl.text = "🎮 Administrar Retos"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_settings := LabelSettings.new()
	title_settings.font_size = 56
	title_settings.font_color = NEON_YELLOW
	title_settings.outline_size = 3
	title_settings.outline_color = Color.BLACK
	title_settings.shadow_size = 5
	title_settings.shadow_color = Color(NEON_YELLOW, 0.25)
	title_lbl.label_settings = title_settings
	hbox.add_child(title_lbl)


## ======================================================================
##  TAB BAR
## ======================================================================

func _build_tab_bar(parent: VBoxContainer) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)

	_tab_player_btn = Button.new()
	_tab_player_btn.text = "🎯 Jugador"
	_tab_player_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_player_btn.custom_minimum_size.y = 60
	_tab_player_btn.pressed.connect(_on_tab_player)
	hbox.add_child(_tab_player_btn)

	_tab_all_btn = Button.new()
	_tab_all_btn.text = "👥 Todos"
	_tab_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_all_btn.custom_minimum_size.y = 60
	_tab_all_btn.pressed.connect(_on_tab_all)
	hbox.add_child(_tab_all_btn)

	_update_tab_styles()


func _update_tab_styles() -> void:
	if _current_tab == "player":
		_style_button(_tab_player_btn, NEON_GREEN, true)
		_style_button(_tab_all_btn, Color(0.4, 0.4, 0.5), false)
	else:
		_style_button(_tab_player_btn, Color(0.4, 0.4, 0.5), false)
		_style_button(_tab_all_btn, NEON_GREEN, true)


## ======================================================================
##  SEARCH BAR
## ======================================================================

func _build_search_bar(parent: VBoxContainer) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	parent.add_child(hbox)

	_search_input = LineEdit.new()
	_search_input.placeholder_text = "🔍 Buscar por título..."
	_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_input.custom_minimum_size.y = 56
	_style_line_edit(_search_input)
	_search_input.text_changed.connect(_on_search_changed)
	hbox.add_child(_search_input)

	var new_btn := Button.new()
	new_btn.text = "+ Nuevo"
	new_btn.custom_minimum_size = Vector2(160, 56)
	_style_button(new_btn, NEON_YELLOW)
	new_btn.pressed.connect(_on_new_challenge)
	hbox.add_child(new_btn)


## ======================================================================
##  CHALLENGE LIST
## ======================================================================

func _refresh_list() -> void:
	# Clear
	for child in _list_container.get_children():
		child.queue_free()

	# Filter
	var challenges := ChallengeDB.get_all_raw(_current_tab)
	var filtered: Array[Dictionary] = []
	for c in challenges:
		var title_str: String = c.get("title", "")
		if _search_text != "" and _search_text.to_lower() not in title_str.to_lower():
			continue
		filtered.append(c)

	# Pagination math
	var total_items := filtered.size()
	_total_pages = maxi(1, ceili(float(total_items) / PAGE_SIZE))
	_current_page = clampi(_current_page, 0, _total_pages - 1)
	var start_idx := _current_page * PAGE_SIZE
	var end_idx := mini(start_idx + PAGE_SIZE, total_items)

	# Top pagination
	if _total_pages > 1:
		_list_container.add_child(_build_pagination_bar())

	# Render page items
	var visual_idx := 0
	for i in range(start_idx, end_idx):
		_create_card(filtered[i], visual_idx)
		visual_idx += 1

	# Bottom pagination
	if _total_pages > 1:
		_list_container.add_child(_build_pagination_bar())

	# Scroll to top
	_scroll.scroll_vertical = 0


func _build_pagination_bar() -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# First
	var first_btn := Button.new()
	first_btn.text = "«"
	first_btn.custom_minimum_size = Vector2(70, 60)
	first_btn.disabled = _current_page == 0
	_style_page_button(first_btn, not first_btn.disabled)
	first_btn.pressed.connect(_go_to_page.bind(0))
	bar.add_child(first_btn)

	# Prev
	var prev_btn := Button.new()
	prev_btn.text = "‹"
	prev_btn.custom_minimum_size = Vector2(70, 60)
	prev_btn.disabled = _current_page == 0
	_style_page_button(prev_btn, not prev_btn.disabled)
	prev_btn.pressed.connect(_go_to_page.bind(_current_page - 1))
	bar.add_child(prev_btn)

	# Page indicator
	var page_lbl := Label.new()
	page_lbl.text = "%d / %d" % [_current_page + 1, _total_pages]
	page_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_lbl.custom_minimum_size = Vector2(140, 60)
	var pls := LabelSettings.new()
	pls.font_size = 32
	pls.font_color = NEON_YELLOW
	pls.outline_size = 2
	pls.outline_color = Color.BLACK
	page_lbl.label_settings = pls
	bar.add_child(page_lbl)

	# Next
	var next_btn := Button.new()
	next_btn.text = "›"
	next_btn.custom_minimum_size = Vector2(70, 60)
	next_btn.disabled = _current_page >= _total_pages - 1
	_style_page_button(next_btn, not next_btn.disabled)
	next_btn.pressed.connect(_go_to_page.bind(_current_page + 1))
	bar.add_child(next_btn)

	# Last
	var last_btn := Button.new()
	last_btn.text = "»"
	last_btn.custom_minimum_size = Vector2(70, 60)
	last_btn.disabled = _current_page >= _total_pages - 1
	_style_page_button(last_btn, not last_btn.disabled)
	last_btn.pressed.connect(_go_to_page.bind(_total_pages - 1))
	bar.add_child(last_btn)

	return bar


func _style_page_button(btn: Button, active: bool) -> void:
	btn.add_theme_font_size_override("font_size", 36)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(NEON_GREEN, 0.2) if active else Color(0.15, 0.15, 0.2)
	normal.border_color = Color(NEON_GREEN, 0.6) if active else Color(0.3, 0.3, 0.4)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(NEON_GREEN, 0.35)
	hover.border_color = NEON_GREEN
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(NEON_GREEN, 0.5)
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.1, 0.1, 0.15, 0.5)
	disabled.border_color = Color(0.2, 0.2, 0.25, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color", Color.WHITE if active else Color(0.4, 0.4, 0.4))
	btn.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.35))


func _go_to_page(page: int) -> void:
	_current_page = clampi(page, 0, _total_pages - 1)
	_refresh_list()


func _create_card(data: Dictionary, index: int) -> void:
	var is_deleted: bool = data.get("deleted", false)
	var id: int = int(data.get("id", 0))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size.y = 130
	card.mouse_filter = Control.MOUSE_FILTER_PASS

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = CARD_BG if not is_deleted else Color(CARD_BG, 0.3)
	card_style.set_corner_radius_all(14)
	card_style.border_color = CARD_BORDER if not is_deleted else Color(0.5, 0.2, 0.2, 0.3)
	card_style.set_border_width_all(2)
	card_style.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", card_style)

	if is_deleted:
		card.modulate.a = DELETED_ALPHA

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	card.add_child(hbox)

	# --- Left: Info ---
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	info_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(info_vbox)

	# Title
	var title_lbl := Label.new()
	title_lbl.text = data.get("title", "Sin título")
	title_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	var ts := LabelSettings.new()
	ts.font_size = 40
	ts.font_color = NEON_YELLOW if not is_deleted else Color(0.6, 0.6, 0.6)
	ts.outline_size = 2
	ts.outline_color = Color.BLACK
	title_lbl.label_settings = ts
	info_vbox.add_child(title_lbl)

	# Story excerpt
	var story_lbl := Label.new()
	var story_text: String = data.get("story", "")
	story_lbl.text = story_text.left(60) + ("..." if story_text.length() > 60 else "")
	story_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	var ss := LabelSettings.new()
	ss.font_size = 30
	ss.font_color = Color(0.7, 0.7, 0.8)
	story_lbl.label_settings = ss
	info_vbox.add_child(story_lbl)

	# Sips badges
	var sips_arr: Array = data.get("sips", [])
	if sips_arr.size() > 0:
		var badge_hbox := HBoxContainer.new()
		badge_hbox.add_theme_constant_override("separation", 6)
		badge_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
		info_vbox.add_child(badge_hbox)
		for sip in sips_arr:
			var badge := Label.new()
			badge.text = "🍺×%s" % str(sip.get("amount", 0))
			badge.mouse_filter = Control.MOUSE_FILTER_PASS
			var bs := LabelSettings.new()
			bs.font_size = 28
			bs.font_color = NEON_GREEN
			badge.label_settings = bs
			badge_hbox.add_child(badge)

	# Timer badge
	var timer_val: int = int(data.get("timer", 0))
	if timer_val > 0:
		var timer_lbl := Label.new()
		timer_lbl.text = "⏱ %ds" % timer_val
		timer_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		var tls := LabelSettings.new()
		tls.font_size = 28
		tls.font_color = Color(0.9, 0.6, 0.2)
		timer_lbl.label_settings = tls
		info_vbox.add_child(timer_lbl)

	# --- Right: Action buttons ---
	var btn_vbox := VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 8)
	btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(btn_vbox)

	if is_deleted:
		var restore_btn := Button.new()
		restore_btn.text = "♻"
		restore_btn.custom_minimum_size = Vector2(60, 60)
		_style_button(restore_btn, NEON_GREEN)
		restore_btn.pressed.connect(_on_restore.bind(_current_tab, id))
		btn_vbox.add_child(restore_btn)
	else:
		var edit_btn := Button.new()
		edit_btn.text = "✏"
		edit_btn.custom_minimum_size = Vector2(60, 60)
		_style_button(edit_btn, NEON_YELLOW)
		edit_btn.pressed.connect(_on_edit.bind(_current_tab, id, data))
		btn_vbox.add_child(edit_btn)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.custom_minimum_size = Vector2(60, 60)
		_style_button(del_btn, Color(0.9, 0.3, 0.3))
		del_btn.pressed.connect(_on_delete_request.bind(_current_tab, id))
		btn_vbox.add_child(del_btn)

	_list_container.add_child(card)

	# Stagger animation
	card.modulate.a = 0.0 if not is_deleted else 0.0
	card.position.x = 80
	var tween := create_tween()
	tween.set_parallel(true)
	var target_alpha := DELETED_ALPHA if is_deleted else 1.0
	tween.tween_property(card, "modulate:a", target_alpha, 0.3).set_delay(index * 0.04)
	tween.tween_property(card, "position:x", 0.0, 0.3).set_delay(index * 0.04) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


## ======================================================================
##  FORM OVERLAY
## ======================================================================

func _build_form_overlay() -> void:
	_form_overlay = Control.new()
	_form_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_form_overlay.visible = false
	add_child(_form_overlay)

	# Dimmer
	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.7)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_form_overlay.add_child(dimmer)

	# SafeZone margin wrapper for form
	var form_safe_margin := MarginContainer.new()
	form_safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	SafeZoneManager.apply_to_margin(form_safe_margin, 60, 20, 16, 16)
	_form_overlay.add_child(form_safe_margin)

	# Panel
	_form_panel = PanelContainer.new()
	_form_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_form_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = DARKER_BG
	panel_style.set_corner_radius_all(20)
	panel_style.border_color = Color(NEON_GREEN, 0.5)
	panel_style.set_border_width_all(2)
	panel_style.set_content_margin_all(20)
	panel_style.shadow_size = 10
	panel_style.shadow_color = Color(NEON_GREEN, 0.15)
	_form_panel.add_theme_stylebox_override("panel", panel_style)
	form_safe_margin.add_child(_form_panel)

	_form_scroll = ScrollContainer.new()
	_form_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_form_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_form_panel.add_child(_form_scroll)

	var form_vbox := VBoxContainer.new()
	form_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_vbox.add_theme_constant_override("separation", 14)
	_form_scroll.add_child(form_vbox)

	# Form title
	_form_title_label = Label.new()
	_form_title_label.text = "Nuevo Reto"
	var fts := LabelSettings.new()
	fts.font_size = 50
	fts.font_color = NEON_YELLOW
	fts.outline_size = 2
	fts.outline_color = Color.BLACK
	_form_title_label.label_settings = fts
	_form_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form_vbox.add_child(_form_title_label)

	# Title
	form_vbox.add_child(_make_form_label("Título *"))
	_title_input = LineEdit.new()
	_title_input.placeholder_text = "Nombre del reto"
	_title_input.custom_minimum_size.y = 52
	_style_line_edit(_title_input)
	form_vbox.add_child(_title_input)

	# Story
	form_vbox.add_child(_make_form_label("Historia"))
	_story_input = TextEdit.new()
	_story_input.placeholder_text = "Contexto narrativo..."
	_story_input.custom_minimum_size.y = 100
	_story_input.set_line_wrapping_mode(1)
	_style_text_edit(_story_input)
	form_vbox.add_child(_story_input)

	# Action
	form_vbox.add_child(_make_form_label("Acción *"))
	_action_input = TextEdit.new()
	_action_input.placeholder_text = "Lo que deben hacer los jugadores..."
	_action_input.custom_minimum_size.y = 120
	_action_input.set_line_wrapping_mode(1)
	_style_text_edit(_action_input)
	form_vbox.add_child(_action_input)

	# Timer
	form_vbox.add_child(_make_form_label("Timer (seg) — opcional"))
	_timer_spin = SpinBox.new()
	_timer_spin.min_value = 0
	_timer_spin.max_value = 600
	_timer_spin.step = 5
	_timer_spin.value = 0
	_timer_spin.custom_minimum_size.y = 52
	_timer_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timer_spin.add_theme_font_size_override("font_size", 32)
	var timer_line_edit := _timer_spin.get_line_edit()
	if timer_line_edit:
		timer_line_edit.add_theme_font_size_override("font_size", 32)
	form_vbox.add_child(_timer_spin)

	# Sips section
	form_vbox.add_child(_make_form_label("Sorbos 🍺"))
	_sips_container = VBoxContainer.new()
	_sips_container.add_theme_constant_override("separation", 8)
	form_vbox.add_child(_sips_container)

	var add_sip_btn := Button.new()
	add_sip_btn.text = "+ Agregar Sorbo"
	add_sip_btn.custom_minimum_size.y = 50
	_style_button(add_sip_btn, NEON_GREEN)
	add_sip_btn.pressed.connect(_on_add_sip_row)
	form_vbox.add_child(add_sip_btn)

	# Pasive section
	form_vbox.add_child(_make_form_label("Pasiva ⏳"))
	_pasive_container = VBoxContainer.new()
	_pasive_container.add_theme_constant_override("separation", 8)
	form_vbox.add_child(_pasive_container)

	var add_pasive_btn := Button.new()
	add_pasive_btn.text = "+ Agregar Pasiva"
	add_pasive_btn.custom_minimum_size.y = 50
	_style_button(add_pasive_btn, NEON_YELLOW)
	add_pasive_btn.pressed.connect(_on_add_pasive_row)
	form_vbox.add_child(add_pasive_btn)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 20
	form_vbox.add_child(spacer)

	# Buttons
	var btn_hbox := HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 12)
	form_vbox.add_child(btn_hbox)

	_cancel_btn = Button.new()
	_cancel_btn.text = "Cancelar"
	_cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cancel_btn.custom_minimum_size.y = 60
	_style_button(_cancel_btn, Color(0.5, 0.5, 0.5))
	_cancel_btn.pressed.connect(_on_form_cancel)
	btn_hbox.add_child(_cancel_btn)

	_save_btn = Button.new()
	_save_btn.text = "💾 Guardar"
	_save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_save_btn.custom_minimum_size.y = 60
	_style_button(_save_btn, NEON_GREEN)
	_save_btn.pressed.connect(_on_form_save)
	btn_hbox.add_child(_save_btn)


func _make_form_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	var ls := LabelSettings.new()
	ls.font_size = 34
	ls.font_color = Color(0.8, 0.85, 0.9)
	lbl.label_settings = ls
	return lbl


func _add_sip_row(amount: int = 1, condition: String = "", target: String = "SELF") -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.custom_minimum_size.y = 56

	var spin := SpinBox.new()
	spin.min_value = 0
	spin.max_value = 999
	spin.value = amount
	spin.custom_minimum_size = Vector2(130, 56)
	spin.tooltip_text = "Cantidad"
	spin.add_theme_font_size_override("font_size", 32)
	var spin_line_edit := spin.get_line_edit()
	if spin_line_edit:
		spin_line_edit.add_theme_font_size_override("font_size", 32)
	row.add_child(spin)

	var cond_input := LineEdit.new()
	cond_input.placeholder_text = "Condición..."
	cond_input.text = condition
	cond_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cond_input.custom_minimum_size.y = 50
	_style_line_edit(cond_input)
	row.add_child(cond_input)

	var target_btn := OptionButton.new()
	target_btn.custom_minimum_size = Vector2(220, 56)
	target_btn.add_theme_font_size_override("font_size", 28)
	for i in TARGET_LABELS.size():
		target_btn.add_item(TARGET_LABELS[i], i)
	var popup := target_btn.get_popup()
	if popup:
		popup.add_theme_font_size_override("font_size", 32)
	var target_idx := TARGET_KEYS.find(target)
	if target_idx >= 0:
		target_btn.select(target_idx)
	else:
		target_btn.select(0)
	row.add_child(target_btn)

	var del_btn := Button.new()
	del_btn.text = "✕"
	del_btn.custom_minimum_size = Vector2(50, 50)
	_style_button(del_btn, Color(0.8, 0.3, 0.3))
	del_btn.pressed.connect(func(): row.queue_free())
	row.add_child(del_btn)

	_sips_container.add_child(row)


func _add_pasive_row(type_key: String = "X_PLAYER_TURN", count: int = 1) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.custom_minimum_size.y = 56

	var type_btn := OptionButton.new()
	type_btn.custom_minimum_size = Vector2(280, 56)
	type_btn.add_theme_font_size_override("font_size", 28)
	for i in PASIVE_LABELS.size():
		type_btn.add_item(PASIVE_LABELS[i], i)
	var popup := type_btn.get_popup()
	if popup:
		popup.add_theme_font_size_override("font_size", 32)
	var type_idx := PASIVE_KEYS.find(type_key)
	if type_idx >= 0:
		type_btn.select(type_idx)
	else:
		type_btn.select(0)
	row.add_child(type_btn)

	var count_spin := SpinBox.new()
	count_spin.min_value = 1
	count_spin.max_value = 99
	count_spin.value = count
	count_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_spin.custom_minimum_size = Vector2(120, 56)
	count_spin.tooltip_text = "Turnos"
	count_spin.prefix = "x"
	count_spin.add_theme_font_size_override("font_size", 32)
	var spin_le := count_spin.get_line_edit()
	if spin_le:
		spin_le.add_theme_font_size_override("font_size", 32)
	# Hide count for ANY_TURN (permanent)
	count_spin.visible = (type_key != "ANY_TURN")
	row.add_child(count_spin)

	# Toggle count visibility when type changes
	type_btn.item_selected.connect(func(idx: int):
		count_spin.visible = (PASIVE_KEYS[idx] != "ANY_TURN")
	)

	var del_btn := Button.new()
	del_btn.text = "✕"
	del_btn.custom_minimum_size = Vector2(50, 50)
	_style_button(del_btn, Color(0.8, 0.3, 0.3))
	del_btn.pressed.connect(func(): row.queue_free())
	row.add_child(del_btn)

	_pasive_container.add_child(row)


func _on_add_pasive_row() -> void:
	_add_pasive_row()


## ======================================================================
##  CONFIRM DIALOG
## ======================================================================

func _build_confirm_dialog() -> void:
	_confirm_overlay = Control.new()
	_confirm_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_overlay.visible = false
	add_child(_confirm_overlay)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_overlay.add_child(dim)

	# SafeZone margin wrapper for confirm dialog
	var confirm_safe_margin := MarginContainer.new()
	confirm_safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	SafeZoneManager.apply_to_margin(confirm_safe_margin, 0, 0, 0, 0)
	_confirm_overlay.add_child(confirm_safe_margin)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_safe_margin.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(700, 280)
	var ps := StyleBoxFlat.new()
	ps.bg_color = DARKER_BG
	ps.set_corner_radius_all(20)
	ps.border_color = Color(0.9, 0.3, 0.3, 0.7)
	ps.set_border_width_all(2)
	ps.set_content_margin_all(30)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)

	_confirm_label = Label.new()
	_confirm_label.text = "¿Eliminar este reto?"
	_confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var cls := LabelSettings.new()
	cls.font_size = 42
	cls.font_color = Color.WHITE
	_confirm_label.label_settings = cls
	vbox.add_child(_confirm_label)

	var sub := Label.new()
	sub.text = "Se marcará como eliminado, no se borrará permanentemente."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD
	var sls := LabelSettings.new()
	sls.font_size = 30
	sls.font_color = Color(0.6, 0.6, 0.7)
	sub.label_settings = sls
	vbox.add_child(sub)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)

	_confirm_no = Button.new()
	_confirm_no.text = "Cancelar"
	_confirm_no.custom_minimum_size = Vector2(200, 56)
	_style_button(_confirm_no, Color(0.5, 0.5, 0.5))
	_confirm_no.pressed.connect(_on_confirm_no)
	btn_row.add_child(_confirm_no)

	_confirm_yes = Button.new()
	_confirm_yes.text = "🗑 Eliminar"
	_confirm_yes.custom_minimum_size = Vector2(200, 56)
	_style_button(_confirm_yes, Color(0.9, 0.3, 0.3))
	_confirm_yes.pressed.connect(_on_confirm_yes)
	btn_row.add_child(_confirm_yes)


## ======================================================================
##  TOAST
## ======================================================================

func _build_toast() -> void:
	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_toast_label.offset_top = 30
	_toast_label.offset_bottom = 90
	_toast_label.offset_left = 60
	_toast_label.offset_right = -60
	_toast_label.visible = false
	var tls := LabelSettings.new()
	tls.font_size = 36
	tls.font_color = DARK_BG
	_toast_label.label_settings = tls
	add_child(_toast_label)

	var toast_bg := StyleBoxFlat.new()
	toast_bg.bg_color = NEON_GREEN
	toast_bg.set_corner_radius_all(12)
	toast_bg.set_content_margin_all(14)
	_toast_label.add_theme_stylebox_override("normal", toast_bg)


func _show_toast(message: String) -> void:
	_toast_label.text = message
	_toast_label.visible = true
	_toast_label.modulate.a = 0.0
	_toast_label.position.y = -60

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_toast_label, "modulate:a", 1.0, 0.25)
	tween.tween_property(_toast_label, "position:y", 30.0, 0.3) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_interval(1.5)
	tween.chain().tween_property(_toast_label, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(func(): _toast_label.visible = false)


## ======================================================================
##  EVENT HANDLERS
## ======================================================================

func _on_back() -> void:
	closed.emit()

func _on_tab_player() -> void:
	_current_tab = "player"
	_current_page = 0
	_update_tab_styles()
	_refresh_list()

func _on_tab_all() -> void:
	_current_tab = "all"
	_current_page = 0
	_update_tab_styles()
	_refresh_list()

func _on_search_changed(new_text: String) -> void:
	_search_text = new_text
	_current_page = 0
	_refresh_list()


func _on_new_challenge() -> void:
	_editing_id = -1
	_editing_category = _current_tab
	_form_title_label.text = "✨ Nuevo Reto"
	_title_input.text = ""
	_story_input.text = ""
	_action_input.text = ""
	_timer_spin.value = 0
	# Clear sips
	for child in _sips_container.get_children():
		child.queue_free()
	# Clear pasives
	for child in _pasive_container.get_children():
		child.queue_free()
	_show_form()


func _on_edit(_category: String, _id: int, data: Dictionary) -> void:
	_editing_id = _id
	_editing_category = _category
	_form_title_label.text = "✏ Editar Reto #%d" % _id
	_title_input.text = data.get("title", "")
	_story_input.text = data.get("story", "")
	_action_input.text = data.get("action", "")
	_timer_spin.value = int(data.get("timer", 0))
	# Clear & rebuild sips
	for child in _sips_container.get_children():
		child.queue_free()
	var sips_arr: Array = data.get("sips", [])
	for sip in sips_arr:
		_add_sip_row(
			int(sip.get("amount", 0)),
			str(sip.get("condition", "")),
			str(sip.get("target", "SELF"))
		)
	# Clear & rebuild pasives
	for child in _pasive_container.get_children():
		child.queue_free()
	var pasive_arr: Array = data.get("pasive", [])
	for pas in pasive_arr:
		_add_pasive_row(
			str(pas.get("type", "X_PLAYER_TURN")),
			int(pas.get("count", 1))
		)
	_show_form()


func _on_delete_request(category: String, id: int) -> void:
	_pending_delete_cat = category
	_pending_delete_id = id
	_confirm_overlay.visible = true
	_confirm_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_confirm_overlay, "modulate:a", 1.0, 0.2)


func _on_confirm_yes() -> void:
	ChallengeDB.delete_challenge(_pending_delete_cat, _pending_delete_id)
	_confirm_overlay.visible = false
	_refresh_list()
	_show_toast("🗑 Reto eliminado")

func _on_confirm_no() -> void:
	_confirm_overlay.visible = false


func _on_restore(category: String, id: int) -> void:
	ChallengeDB.restore_challenge(category, id)
	_refresh_list()
	_show_toast("♻ Reto restaurado")


func _on_add_sip_row() -> void:
	_add_sip_row()


## ======================================================================
##  FORM OPEN / CLOSE
## ======================================================================

func _show_form() -> void:
	_form_overlay.visible = true
	_form_overlay.modulate.a = 0.0
	_form_panel.position.y = 200

	var tween := create_tween().set_parallel(true)
	tween.tween_property(_form_overlay, "modulate:a", 1.0, 0.25)
	tween.tween_property(_form_panel, "position:y", 0.0, 0.35) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _hide_form() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_form_overlay, "modulate:a", 0.0, 0.2)
	tween.tween_property(_form_panel, "position:y", 200.0, 0.25) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(func(): _form_overlay.visible = false)

func _on_form_cancel() -> void:
	_hide_form()


func _on_form_save() -> void:
	# --- Validation ---
	var title_val := _title_input.text.strip_edges()
	if title_val.is_empty():
		_show_toast("⚠ El título es obligatorio")
		return
	var action_val := _action_input.text.strip_edges()
	if action_val.is_empty():
		_show_toast("⚠ La acción es obligatoria")
		return

	# Build data
	var data := {
		"title": title_val,
		"story": _story_input.text.strip_edges(),
		"action": action_val,
	}

	# Timer (optional)
	var timer_val := int(_timer_spin.value)
	if timer_val > 0:
		data["timer"] = timer_val

	# Sips
	var sips_arr: Array = []
	for row in _sips_container.get_children():
		if not row is HBoxContainer:
			continue
		var hrow: HBoxContainer = row as HBoxContainer
		if hrow.get_child_count() < 3:
			continue
		var amount_spin: SpinBox = hrow.get_child(0) as SpinBox
		var cond_edit: LineEdit = hrow.get_child(1) as LineEdit
		var target_opt: OptionButton = hrow.get_child(2) as OptionButton

		var sip_data := {
			"amount": int(amount_spin.value),
			"condition": cond_edit.text.strip_edges(),
			"target": TARGET_KEYS[target_opt.selected] if target_opt.selected < TARGET_KEYS.size() else "SELF",
		}
		sips_arr.append(sip_data)
	data["sips"] = sips_arr

	# Pasives
	var pasive_arr: Array = []
	for row in _pasive_container.get_children():
		if not row is HBoxContainer:
			continue
		var hrow: HBoxContainer = row as HBoxContainer
		if hrow.get_child_count() < 2:
			continue
		var type_opt: OptionButton = hrow.get_child(0) as OptionButton
		var count_spin: SpinBox = hrow.get_child(1) as SpinBox
		var pas_type: String = PASIVE_KEYS[type_opt.selected] if type_opt.selected < PASIVE_KEYS.size() else "X_PLAYER_TURN"
		var pas_data := {"type": pas_type}
		if pas_type != "ANY_TURN":
			pas_data["count"] = int(count_spin.value)
		pasive_arr.append(pas_data)
	if not pasive_arr.is_empty():
		data["pasive"] = pasive_arr

	# Save
	if _editing_id == -1:
		ChallengeDB.add_challenge(_editing_category, data)
		_show_toast("✅ Reto creado")
	else:
		ChallengeDB.update_challenge(_editing_category, _editing_id, data)
		_show_toast("✅ Reto actualizado")

	_hide_form()
	_refresh_list()


## ======================================================================
##  STYLE HELPERS
## ======================================================================

func _style_button(btn: Button, color: Color, active: bool = false) -> void:
	pass
	btn.add_theme_font_size_override("font_size", 32)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color, 0.2)
	normal.border_color = Color(color, 0.7 if active else 0.4)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(12)
	normal.set_content_margin_all(10)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(color, 0.35)
	hover.border_color = color
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(12)
	hover.set_content_margin_all(10)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(color, 0.5)
	pressed.border_color = color
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(12)
	pressed.set_content_margin_all(10)
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)


func _style_line_edit(le: LineEdit) -> void:
	pass
	le.add_theme_font_size_override("font_size", 32)

	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.1, 0.1, 0.18)
	s.border_color = Color(NEON_GREEN, 0.4)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.set_content_margin_all(10)
	le.add_theme_stylebox_override("normal", s)

	var focus := s.duplicate() as StyleBoxFlat
	focus.border_color = NEON_GREEN
	le.add_theme_stylebox_override("focus", focus)

	le.add_theme_color_override("font_color", Color.WHITE)
	le.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.6))


func _style_text_edit(te: TextEdit) -> void:
	pass
	te.add_theme_font_size_override("font_size", 32)

	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.1, 0.1, 0.18)
	s.border_color = Color(NEON_GREEN, 0.4)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	s.set_content_margin_all(10)
	te.add_theme_stylebox_override("normal", s)

	var focus := s.duplicate() as StyleBoxFlat
	focus.border_color = NEON_GREEN
	te.add_theme_stylebox_override("focus", focus)

	te.add_theme_color_override("font_color", Color.WHITE)
	te.add_theme_color_override("font_placeholder_color", Color(0.5, 0.5, 0.6))
