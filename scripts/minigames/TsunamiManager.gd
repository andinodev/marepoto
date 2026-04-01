extends Control
class_name TsunamiManager
## TsunamiManager.gd — Main controller for the Tusunami card game.

signal game_finished()

const CARD_SCENE := preload("res://scripts/minigames/TsunamiCard.gd")
const RED_COLOR := Color("#ff415c")
const BLUE_COLOR := Color("#3689ac")
const BACK_COLOR := Color("#22c55e")

# --- Nodes ---
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/CenterContainer/GridContainer
@onready var deck_button: Button = $MarginContainer/VBoxContainer/CenterContainer/DeckButton
@onready var sip_label: Label = $MarginContainer/VBoxContainer/FooterHBox/SipLabel
@onready var prediction_modal: Control = $PredictionModal
@onready var prediction_dim: ColorRect = $PredictionModal/Dim
@onready var prediction_container: VBoxContainer = $PredictionModal/VBoxContainer
@onready var red_btn: Button = $PredictionModal/VBoxContainer/PanelContainer/ButtonHBox/RedBtn
@onready var blue_btn: Button = $PredictionModal/VBoxContainer/PanelContainer/ButtonHBox/BlueBtn
@onready var fail_modal: Control = $FailModal
@onready var fail_label: Label = $FailModal/Container/VBox/LoserLbl
@onready var fail_button: Button = $FailModal/Container/VBox/Button
@onready var fail_background: ColorRect = $FailModal/Dim
@onready var fail_container: Control = $FailModal/Container

# --- State ---
var deck: Array = []
var active_cards: Array = []
var resolved_cards: Array = []
var sip_count: int = 0
var current_card: Button = null
var is_waiting_for_prediction: bool = false
var is_processing_result: bool = false

func _ready() -> void:
	# set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT) # Now handled by scene
	# Connect signals from scene nodes
	deck_button.pressed.connect(_on_deck_button_pressed)
	red_btn.pressed.connect(func(): _on_prediction_made(RED_COLOR))
	blue_btn.pressed.connect(func(): _on_prediction_made(BLUE_COLOR))
	fail_button.pressed.connect(_on_fail_button_pressed)
	
	reset_game_ui()
	
	# Initial state for modals to allow clean animations
	prediction_modal.visible = false
	fail_modal.visible = false
	prediction_container.pivot_offset = prediction_container.size / 2
	fail_container.pivot_offset = fail_container.size / 2


func reset_game_ui() -> void:
	_initialize_deck()
	_replenish_all_cards()
	sip_count = 0
	_update_labels()
	
	is_waiting_for_prediction = false
	is_processing_result = false
	
	# Close all modals
	prediction_modal.visible = false
	fail_modal.visible = false
	
	# Reset their visual properties for a clean next show animation
	if prediction_container: prediction_container.scale = Vector2.ONE
	if fail_container: fail_container.scale = Vector2.ONE
	if prediction_dim: prediction_dim.modulate.a = 1.0
	if fail_background: fail_background.modulate.a = 1.0


func _initialize_deck() -> void:
	deck.clear()
	# Standard deck has 26 red, 26 black (here red/blue)
	for i in 26:
		deck.append(RED_COLOR)
		deck.append(BLUE_COLOR)
	deck.shuffle()


func _serve_initial_cards() -> void:
	for i in 6:
		var card = _create_card()
		grid_container.add_child(card)
		active_cards.append(card)


func _create_card() -> Button:
	var color = deck.pop_back() if not deck.is_empty() else (RED_COLOR if randf() > 0.5 else BLUE_COLOR)
	var card = CARD_SCENE.new() as Button
	# Wait for card to be ready to setup
	card.setup(color)
	card.clicked.connect(_on_card_clicked)
	return card


func _on_deck_button_pressed() -> void:
	if is_waiting_for_prediction or is_processing_result: return
	
	# Draw one card for survival
	var card = _create_card()
	# Add to the "center" of the grid area somehow, or just replace the button
	# For survival mode, we'll hide the button and show the card.
	deck_button.visible = false
	grid_container.add_child(card)
	active_cards.append(card)
	
	_on_card_clicked(card)


func _on_card_clicked(card: Button) -> void:
	if is_waiting_for_prediction or is_processing_result: return
	current_card = card
	_show_prediction_modal()


func _show_prediction_modal() -> void:
	is_waiting_for_prediction = true
	_animate_modal_in(prediction_modal, prediction_dim, prediction_container)


func _on_prediction_made(prediction: Color) -> void:
	_animate_modal_out(prediction_modal, prediction_dim, prediction_container)
	is_waiting_for_prediction = false
	is_processing_result = true
	
	current_card.flip()
	
	# Wait for flip animation
	await get_tree().create_timer(0.4).timeout
	
	if current_card.card_color == prediction:
		_on_correct_guess()
	else:
		_on_wrong_guess()


func _on_correct_guess() -> void:
	sip_count += 1
	_update_labels()
	
	# Resolve card
	active_cards.erase(current_card)
	resolved_cards.append(current_card)
	current_card.modulate = Color(1, 1, 1, 0.5) # Fade out
	current_card.disabled = true
	
	# Check if board is empty
	if active_cards.is_empty():
		deck_button.visible = true
	
	# Turn goes to next player
	await get_tree().create_timer(0.4).timeout
	is_processing_result = false
	GameManager.next_turn()
	_update_labels()


func _on_wrong_guess() -> void:
	# Player must drink
	var total_to_drink = sip_count + 1
	
	# Show "YOU DRINK" message
	_show_drink_result(total_to_drink)
	
	sip_count = 0
	_update_labels()
	# The reset logic is now in _on_fail_button_pressed to avoid the "automated hang"


func _replenish_all_cards() -> void:
	# Clear EVERYTHING
	for card in active_cards:
		card.queue_free()
	for card in resolved_cards:
		card.queue_free()
	if current_card:
		current_card.queue_free()
		current_card = null
		
	active_cards.clear()
	resolved_cards.clear()
	deck_button.visible = false
	
	# Reshuffle if deck is low
	if deck.size() < 10:
		_initialize_deck()
		
	_serve_initial_cards()


func _update_labels() -> void:
	sip_label.text = "Sorbos Acumulados: %d" % sip_count
	
	# Pulse animation for sip label if count is high
	if sip_count >= 5:
		sip_label.add_theme_color_override("font_color", Color("#ff415c"))
	else:
		sip_label.add_theme_color_override("font_color", Color("#facc15"))


func _show_drink_result(amount: int) -> void:
	fail_label.text = "¡TSUNAMI!\nTomas %d sorbos" % [amount]
	_animate_modal_in(fail_modal, fail_background, fail_container)

func _on_fail_button_pressed() -> void:
	_animate_modal_out(fail_modal, fail_background, fail_container)
	
	# Reset game state after modal is dismissed
	_replenish_all_cards()
	is_processing_result = false
	GameManager.next_turn()
	_update_labels()

# --- UI Animations ---

func _animate_modal_in(modal: Control, dim: Control, container: Control) -> void:
	modal.visible = true
	
	# Ensure pivot is centered for scaling
	container.pivot_offset = container.size / 2
	
	# Initial state
	dim.modulate.a = 0.0
	container.scale = Vector2(0.8, 0.8)
	container.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _animate_modal_out(modal: Control, dim: Control, container: Control) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(container, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(container, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await tween.finished
	modal.visible = false
