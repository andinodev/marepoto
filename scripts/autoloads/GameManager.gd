extends Node
## GameManager — Global state singleton for Marepoto.
## Manages players, game state, and turn cycling.

const PLAYERS_PATH := "user://players.json"
const PLAYER_LIMIT := 15
signal state_changed(new_state: int)
signal players_changed()
signal turn_changed(player: Dictionary)
signal game_started

enum State {SETUP, PLAYING, CHALLENGE_VIEW}

const PLAYER_COLORS: Array[Color] = [
	Color("#e74c3c"),
	Color("#3498db"),
	Color("#2ecc71"),
	Color("#f39c12"),
	Color("#9b59b6"),
	Color("#009f7fff"),
	Color("#e91e63"),
	Color("#00bcd4"),
	Color("#ff9800"),
	Color("#8bc34a"),
	Color("#ff5722"),
	Color("#ff00a2ff"),
	Color("#79fffdff"),
	Color("#77ff00ff"),
	Color("#ff0000ff"),
	Color("#00ff00ff"),
	Color("#0000ffff"),
	Color("#ff00ffff"),
	Color("#ff84ffff"),
	Color("#1929a6ff"),
	Color("#a77120ff"),
	Color("#187671ff"),
	Color("#61114200"),
	Color("#000000ff"),
]

var state: State = State.SETUP:
	set(value):
		state = value
		state_changed.emit(state)

var players: Array[Dictionary] = []
var current_player_index: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_fonts()
	_load_players()


func _setup_fonts() -> void:
	var roboto := load("res://fonts/Roboto-VariableFont_wdth,wght.ttf") as Font
	var emoji := load("res://fonts/NotoColorEmoji-Regular.ttf") as Font
	if roboto and emoji:
		roboto.fallbacks = [emoji]
		ThemeDB.fallback_font = roboto


## ---------- Player Management ----------

func add_player(player_name: String) -> bool:
	if player_name.strip_edges().is_empty():
		return false
	if players.size() >= PLAYER_LIMIT:
		return false

	var player := {
		"id": players.size(),
		"name": player_name.strip_edges(),
		"color": PLAYER_COLORS[players.size() % PLAYER_COLORS.size()],
	}
	players.append(player)
	players_changed.emit()
	_save_players()
	return true


func remove_player(index: int) -> void:
	if index < 0 or index >= players.size():
		return
	players.remove_at(index)
	# Reassign colors
	for i in players.size():
		players[i]["id"] = i
		players[i]["color"] = PLAYER_COLORS[i % PLAYER_COLORS.size()]
	players_changed.emit()
	_save_players()


func get_player_count() -> int:
	return players.size()


## ---------- Turn Management ----------

func get_current_player() -> Dictionary:
	if players.is_empty():
		return {}
	return players[current_player_index % players.size()]


func next_turn() -> void:
	current_player_index = (current_player_index + 1) % players.size()
	turn_changed.emit(get_current_player())


func get_random_other_player(exclude_index: int = -1) -> Dictionary:
	if players.size() < 2:
		return get_current_player()
	var idx := exclude_index
	if idx < 0:
		idx = current_player_index
	var other_idx := idx
	while other_idx == idx:
		other_idx = randi() % players.size()
	return players[other_idx]


## ---------- Game Flow ----------

func start_game() -> void:
	if players.size() < 2:
		return
	current_player_index = 0
	state = State.PLAYING
	game_started.emit()


func return_to_setup() -> void:
	## Go back to setup without clearing players.
	current_player_index = 0
	state = State.SETUP


func reset_game() -> void:
	players.clear()
	current_player_index = 0
	state = State.SETUP
	players_changed.emit()
	_save_players()


## ---------- Persistence ----------

func _save_players() -> void:
	var data: Array = []
	for p in players:
		data.append({"name": p["name"]})
	var file := FileAccess.open(PLAYERS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func _load_players() -> void:
	if not FileAccess.file_exists(PLAYERS_PATH):
		return
	var file := FileAccess.open(PLAYERS_PATH, FileAccess.READ)
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	file.close()
	var data: Array = json.data
	for entry in data:
		add_player(entry["name"])
