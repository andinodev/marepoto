extends Control
## ChallengeManager.gd — CRUD UI for challenges database.
## Static layout is defined in ChallengeManager.tscn; this script handles
## dynamic content (cards, pagination, sip/passive rows) and all logic.

signal closed

# --- Constants ---
const PAGE_SIZE := 25
const BTN_TEX: Texture2D = preload("res://sprites/gui/Buttons/button_white.png")
const CARD_TEX: Texture2D = preload("res://sprites/gui/Buttons/button_white.png")

const TARGET_KEYS := ["SELF", "SPECIFIC", "ALL", "DISTRIBUTE"]
const TARGET_LABELS := ["Uno mismo", "Específico", "Todos", "Distribuir"]

const PASIVE_KEYS := ["X_PLAYER_TURN", "X_TURN", "ANY_TURN"]
const PASIVE_LABELS := ["Turno del jugador", "Turno general", "Permanente"]

const MINIGAME_KEYS := ["", "HOCKEY", "FINGER"]
const MINIGAME_LABELS := ["Ninguno", "🏒 Air Hockey", "👇 Último Dedo"]

# --- Scene node references ---
@onready var _tab_player_btn: Button = $SafeMargin/Content/TabBar/TabPlayerBtn
@onready var _tab_all_btn: Button = $SafeMargin/Content/TabBar/TabAllBtn
@onready var _search_input: LineEdit = $SafeMargin/Content/SearchBar/SearchInput
@onready var _new_btn: Button = $SafeMargin/Content/SearchBar/NewBtn
@onready var _back_btn: Button = $SafeMargin/Content/Header/BackBtn
@onready var _scroll: ScrollContainer = $SafeMargin/Content/Scroll
@onready var _list_container: VBoxContainer = $SafeMargin/Content/Scroll/ListContainer

# Form overlay
@onready var _form_overlay: Control = $FormOverlay
@onready var _form_panel: PanelContainer = $FormOverlay/FormSafeMargin/FormPanel
@onready var _form_title_label: Label = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormTitleLabel
@onready var _title_input: LineEdit = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/TitleInput
@onready var _story_input: TextEdit = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/StoryInput
@onready var _action_input: TextEdit = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/ActionInput
@onready var _timer_spin: SpinBox = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/HBoxContainer/TimerSpin
@onready var _sips_container: VBoxContainer = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/SipsContainer
@onready var _add_sip_btn: Button = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/AddSipBtn
@onready var _pasive_container: VBoxContainer = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/PasiveContainer
@onready var _add_pasive_btn: Button = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/AddPasiveBtn
@onready var _minigame_option: OptionButton = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/MinigameRow/MinigameOption
@onready var _minigame_rounds_row: HBoxContainer = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/MinigameRow/MinigameRoundsRow
@onready var _minigame_rounds_spin: SpinBox = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/FormScroll/FormVBox/MinigameRow/MinigameRoundsRow/MinigameRoundsSpin
@onready var _cancel_btn: Button = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/BtnRow/CancelBtn
@onready var _save_btn: Button = $FormOverlay/FormSafeMargin/FormPanel/VBoxContainer/BtnRow/SaveBtn

# Confirm overlay
@onready var _confirm_overlay: Control = $ConfirmOverlay
@onready var _confirm_label: Label = $ConfirmOverlay/ConfirmSafeMargin/CenterContainer/ConfirmPanel/VBox/ConfirmLabel
@onready var _confirm_no: Button = $ConfirmOverlay/ConfirmSafeMargin/CenterContainer/ConfirmPanel/VBox/BtnRow/ConfirmNo
@onready var _confirm_yes: Button = $ConfirmOverlay/ConfirmSafeMargin/CenterContainer/ConfirmPanel/VBox/BtnRow/ConfirmYes

# Toast
@onready var _toast_label: Label = $ToastLabel

# --- State ---
var _current_tab := "player"
var _search_text := ""
var _editing_id: int = -1
var _editing_category := ""
var _current_page: int = 0
var _total_pages: int = 1
var _pending_delete_id: int = -1
var _pending_delete_cat := ""


func _ready() -> void:
	# Apply safe-zone insets
	SafeZoneManager.apply_to_margin($SafeMargin, 20, 20, 24, 24)
	SafeZoneManager.apply_to_margin($FormOverlay/FormSafeMargin, 60, 20, 16, 16)
	SafeZoneManager.apply_to_margin($ConfirmOverlay/ConfirmSafeMargin, 20, 20, 16, 16)

	# Connect signals
	_back_btn.pressed.connect(_on_back)
	_tab_player_btn.pressed.connect(_on_tab_player)
	_tab_all_btn.pressed.connect(_on_tab_all)
	_search_input.text_changed.connect(_on_search_changed)
	_new_btn.pressed.connect(_on_new_challenge)
	_add_sip_btn.pressed.connect(_on_add_sip_row)
	_add_pasive_btn.pressed.connect(_on_add_pasive_row)
	_cancel_btn.pressed.connect(_on_form_cancel)
	_save_btn.pressed.connect(_on_form_save)
	_confirm_no.pressed.connect(_on_confirm_no)
	_confirm_yes.pressed.connect(_on_confirm_yes)

	# Populate minigame dropdown
	_minigame_option.clear()
	for i in MINIGAME_LABELS.size():
		_minigame_option.add_item(MINIGAME_LABELS[i], i)
	_minigame_option.item_selected.connect(_on_minigame_type_changed)

	# Initial state
	_update_tab_styles()
	_refresh_list()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_handle_back()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back()


func _handle_back() -> void:
	if _confirm_overlay.visible:
		_on_confirm_no()
	elif _form_overlay.visible:
		_hide_form()
	else:
		_on_back()


## ======================================================================
##  TAB STYLES
## ======================================================================

func _update_tab_styles() -> void:
	_tab_player_btn.modulate = Color.WHITE if _current_tab == "player" else Color(0.6, 0.6, 0.6)
	_tab_all_btn.modulate = Color.WHITE if _current_tab == "all" else Color(0.6, 0.6, 0.6)


## ======================================================================
##  CHALLENGE LIST
## ======================================================================

func _refresh_list() -> void:
	for child in _list_container.get_children():
		child.queue_free()

	var challenges := ChallengeDB.get_all_raw(_current_tab)
	var filtered: Array[Dictionary] = []
	for c in challenges:
		var title_str: String = c.get("title", "")
		if _search_text != "" and _search_text.to_lower() not in title_str.to_lower():
			continue
		filtered.append(c)

	# Pagination
	var total_items := filtered.size()
	_total_pages = maxi(1, ceili(float(total_items) / PAGE_SIZE))
	_current_page = clampi(_current_page, 0, _total_pages - 1)
	var start_idx := _current_page * PAGE_SIZE
	var end_idx := mini(start_idx + PAGE_SIZE, total_items)

	if _total_pages > 1:
		_list_container.add_child(_build_pagination_bar())

	var visual_idx := 0
	for i in range(start_idx, end_idx):
		_create_card(filtered[i], visual_idx)
		visual_idx += 1

	if _total_pages > 1:
		_list_container.add_child(_build_pagination_bar())

	_scroll.scroll_vertical = 0


func _build_pagination_bar() -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var first_btn := Button.new()
	first_btn.text = "«"
	first_btn.custom_minimum_size = Vector2(70, 60)
	first_btn.disabled = _current_page == 0
	first_btn.pressed.connect(_go_to_page.bind(0))
	bar.add_child(first_btn)

	var prev_btn := Button.new()
	prev_btn.text = "‹"
	prev_btn.custom_minimum_size = Vector2(70, 60)
	prev_btn.disabled = _current_page == 0
	prev_btn.pressed.connect(_go_to_page.bind(_current_page - 1))
	bar.add_child(prev_btn)

	var page_lbl := Label.new()
	page_lbl.text = "%d / %d" % [_current_page + 1, _total_pages]
	page_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_lbl.custom_minimum_size = Vector2(140, 60)
	bar.add_child(page_lbl)

	var next_btn := Button.new()
	next_btn.text = "›"
	next_btn.custom_minimum_size = Vector2(70, 60)
	next_btn.disabled = _current_page >= _total_pages - 1
	next_btn.pressed.connect(_go_to_page.bind(_current_page + 1))
	bar.add_child(next_btn)

	var last_btn := Button.new()
	last_btn.text = "»"
	last_btn.custom_minimum_size = Vector2(70, 60)
	last_btn.disabled = _current_page >= _total_pages - 1
	last_btn.pressed.connect(_go_to_page.bind(_total_pages - 1))
	bar.add_child(last_btn)

	return bar


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
	var card_style := StyleBoxTexture.new()
	card_style.texture = CARD_TEX
	card_style.texture_margin_left = 32.0
	card_style.texture_margin_top = 32.0
	card_style.texture_margin_right = 32.0
	card_style.texture_margin_bottom = 32.0
	card_style.content_margin_left = 32.0
	card_style.content_margin_top = 32.0
	card_style.content_margin_right = 32.0
	card_style.content_margin_bottom = 32.0
	card.add_theme_stylebox_override("panel", card_style)
	if is_deleted:
		card.modulate.a = 0.4

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
	info_vbox.add_child(title_lbl)

	# Story excerpt
	var story_lbl := Label.new()
	var story_text: String = data.get("story", "")
	story_lbl.text = story_text.left(60) + ("..." if story_text.length() > 60 else "")
	story_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	var ss := LabelSettings.new()
	ss.font_size = 30
	ss.font_color = Color("#264e76ff")
	story_lbl.label_settings = ss
	info_vbox.add_child(story_lbl)

	# Badge row (sips + timer + minigame + passives)
	var badge_grid := GridContainer.new()
	badge_grid.columns = 4
	badge_grid.add_theme_constant_override("separation", 10)
	badge_grid.mouse_filter = Control.MOUSE_FILTER_PASS
	info_vbox.add_child(badge_grid)

	# Sips badges
	var sips_arr: Array = data.get("sips", [])
	for sip in sips_arr:
		var badge := Label.new()
		badge.text = "🍺×%s" % str(sip.get("amount", 0))
		badge.mouse_filter = Control.MOUSE_FILTER_PASS
		var bs := LabelSettings.new()
		bs.font_size = 48
		bs.font_color = Color("#264e76ff")
		badge.label_settings = bs
		badge_grid.add_child(badge)

	# Timer badge
	var timer_val: int = int(data.get("timer", 0))
	if timer_val > 0:
		var timer_lbl := Label.new()
		timer_lbl.text = "⏱ %ds" % timer_val
		timer_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		var tls := LabelSettings.new()
		tls.font_size = 48
		tls.font_color = Color("#264e76ff")
		timer_lbl.label_settings = tls
		badge_grid.add_child(timer_lbl)

	# Minigame badge
	var mg_data: Dictionary = data.get("minigame", {})
	if not mg_data.is_empty():
		var mg_lbl := Label.new()
		var mg_type: String = str(mg_data.get("type", ""))
		var mg_rounds: int = int(mg_data.get("rounds", 3))
		mg_lbl.text = "🎮 %s (%d)" % [mg_type, mg_rounds]
		mg_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		var mls := LabelSettings.new()
		mls.font_size = 48
		mls.font_color = Color("#264e76ff")
		mg_lbl.label_settings = mls
		badge_grid.add_child(mg_lbl)

	# Passive badges
	var pasive_arr: Array = data.get("pasive", [])
	for pas in pasive_arr:
		var p_lbl := Label.new()
		var ptype: String = str(pas.get("type", ""))
		if ptype == "ANY_TURN":
			p_lbl.text = "🗣️ ∞"
		else:
			p_lbl.text = "🗣️ ×%d" % int(pas.get("count", 1))
		p_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		var pls := LabelSettings.new()
		pls.font_size = 48
		pls.font_color = Color("#264e76ff")
		p_lbl.label_settings = pls
		badge_grid.add_child(p_lbl)

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
		restore_btn.add_theme_stylebox_override("normal", _make_btn_style(Color("#99C1B9")))
		restore_btn.pressed.connect(_on_restore.bind(_current_tab, id))
		btn_vbox.add_child(restore_btn)
	else:
		var edit_btn := Button.new()
		edit_btn.text = "✏"
		edit_btn.custom_minimum_size = Vector2(60, 60)
		edit_btn.add_theme_stylebox_override("normal", _make_btn_style(Color("#99C1B9")))
		edit_btn.pressed.connect(_on_edit.bind(_current_tab, id, data))
		btn_vbox.add_child(edit_btn)

		var del_btn := Button.new()
		del_btn.text = "🗑"
		del_btn.custom_minimum_size = Vector2(60, 60)
		del_btn.add_theme_stylebox_override("normal", _make_btn_style(Color("#D88C9A")))
		del_btn.pressed.connect(_on_delete_request.bind(_current_tab, id))
		btn_vbox.add_child(del_btn)

	_list_container.add_child(card)

	# Stagger animation
	card.modulate.a = 0.0
	card.position.x = 80
	var tween := create_tween()
	tween.set_parallel(true)
	var target_alpha := 0.4 if is_deleted else 1.0
	tween.tween_property(card, "modulate:a", target_alpha, 0.3).set_delay(index * 0.04)
	tween.tween_property(card, "position:x", 0.0, 0.3).set_delay(index * 0.04) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


## ======================================================================
##  DYNAMIC FORM ROWS
## ======================================================================

func _add_sip_row(amount: int = 1, condition: String = "", target: String = "SELF") -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 4)

	# Row 1: Amount + Target + Delete
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	group.add_child(top_row)

	var spin := SpinBox.new()
	spin.min_value = 0
	spin.max_value = 999
	spin.value = amount
	spin.custom_minimum_size = Vector2(130, 56)
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.tooltip_text = "Cantidad"
	top_row.add_child(spin)

	var target_btn := OptionButton.new()
	target_btn.custom_minimum_size = Vector2(220, 56)
	target_btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD
	for i in TARGET_LABELS.size():
		target_btn.add_item(TARGET_LABELS[i], i)
	var target_idx := TARGET_KEYS.find(target)
	if target_idx >= 0:
		target_btn.select(target_idx)
	else:
		target_btn.select(0)
	top_row.add_child(target_btn)

	var del_btn := Button.new()
	del_btn.text = "✕"
	del_btn.custom_minimum_size = Vector2(50, 50)
	del_btn.pressed.connect(func(): group.queue_free())
	top_row.add_child(del_btn)

	# Row 2: Condition (full width)
	var cond_input := LineEdit.new()
	cond_input.placeholder_text = "Condición..."
	cond_input.text = condition
	cond_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cond_input.custom_minimum_size.y = 50
	group.add_child(cond_input)

	_sips_container.add_child(group)


func _add_pasive_row(type_key: String = "X_PLAYER_TURN", count: int = 1) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.custom_minimum_size.y = 56

	var type_btn := OptionButton.new()
	type_btn.custom_minimum_size = Vector2(280, 56)
	for i in PASIVE_LABELS.size():
		type_btn.add_item(PASIVE_LABELS[i], i)
	var type_idx := PASIVE_KEYS.find(type_key)
	if type_idx >= 0:
		type_btn.select(type_idx)
	else:
		type_btn.select(0)
	type_btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD
	row.add_child(type_btn)

	var count_spin := SpinBox.new()
	count_spin.min_value = 1
	count_spin.max_value = 99
	count_spin.value = count
	count_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_spin.custom_minimum_size = Vector2(120, 56)
	count_spin.tooltip_text = "Turnos"
	count_spin.prefix = "x"
	count_spin.visible = (type_key != "ANY_TURN")
	row.add_child(count_spin)

	# Toggle count visibility when type changes
	type_btn.item_selected.connect(func(idx: int):
		count_spin.visible = (PASIVE_KEYS[idx] != "ANY_TURN")
	)

	var del_btn := Button.new()
	del_btn.text = "✕"
	del_btn.custom_minimum_size = Vector2(50, 50)
	del_btn.pressed.connect(func(): row.queue_free())
	row.add_child(del_btn)

	_pasive_container.add_child(row)


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
	for child in _sips_container.get_children():
		child.queue_free()
	for child in _pasive_container.get_children():
		child.queue_free()
	_minigame_option.select(0)
	_minigame_rounds_spin.value = 3
	_minigame_rounds_row.visible = false
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
	# Minigame
	var mg_data: Dictionary = data.get("minigame", {})
	if not mg_data.is_empty():
		var mg_type: String = str(mg_data.get("type", ""))
		var mg_idx := MINIGAME_KEYS.find(mg_type)
		_minigame_option.select(mg_idx if mg_idx >= 0 else 0)
		_minigame_rounds_spin.value = int(mg_data.get("rounds", 3))
		_minigame_rounds_row.visible = mg_idx > 0
	else:
		_minigame_option.select(0)
		_minigame_rounds_spin.value = 3
		_minigame_rounds_row.visible = false
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


func _on_add_pasive_row() -> void:
	_add_pasive_row()


func _on_minigame_type_changed(index: int) -> void:
	_minigame_rounds_row.visible = index > 0


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
	for group in _sips_container.get_children():
		if not group is VBoxContainer:
			continue
		var vgroup: VBoxContainer = group as VBoxContainer
		if vgroup.get_child_count() < 2:
			continue
		var top_row: HBoxContainer = vgroup.get_child(0) as HBoxContainer
		var cond_edit: LineEdit = vgroup.get_child(1) as LineEdit
		if top_row == null or cond_edit == null or top_row.get_child_count() < 2:
			continue
		var amount_spin: SpinBox = top_row.get_child(0) as SpinBox
		var target_opt: OptionButton = top_row.get_child(1) as OptionButton

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

	# Minigame
	var mg_selected: int = _minigame_option.selected
	if mg_selected > 0 and mg_selected < MINIGAME_KEYS.size():
		data["minigame"] = {
			"type": MINIGAME_KEYS[mg_selected],
			"rounds": int(_minigame_rounds_spin.value),
		}

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
##  TOAST
## ======================================================================

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


func _make_btn_style(color: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = BTN_TEX
	style.texture_margin_left = 32.0
	style.texture_margin_top = 32.0
	style.texture_margin_right = 32.0
	style.texture_margin_bottom = 32.0
	style.modulate_color = color
	return style
