extends Node
## ChallengeDB — Loads, serves, and manages challenges (CRUD + soft-delete).

const RES_PATH := "res://data/challenges.json"
const USER_PATH := "user://challenges.json"

signal challenges_changed

var challenges_player: Array[Dictionary] = []
var challenges_all: Array[Dictionary] = []
var _used_ids: Array[int] = []
var _raw_data: Dictionary = {}


func _ready() -> void:
	load_challenges()


func load_challenges() -> void:
	var path := USER_PATH if FileAccess.file_exists(USER_PATH) else RES_PATH
	if not FileAccess.file_exists(path):
		push_error("ChallengeDB: challenges.json not found")
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var json_text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("ChallengeDB: JSON parse error: %s" % json.get_error_message())
		return
	_raw_data = json.data as Dictionary
	_rebuild_pools()
	print("ChallengeDB: Loaded from %s — %d player + %d all challenges" % [
		path, challenges_player.size(), challenges_all.size()
	])


func _rebuild_pools() -> void:
	challenges_player.clear()
	challenges_all.clear()
	if _raw_data.has("player"):
		for entry in _raw_data["player"]:
			var d: Dictionary = entry
			if not d.get("deleted", false):
				challenges_player.append(d)
	if _raw_data.has("all"):
		for entry in _raw_data["all"]:
			var d: Dictionary = entry
			if not d.get("deleted", false):
				challenges_all.append(d)


func save_challenges() -> void:
	var json_text := JSON.stringify(_raw_data, "  ")
	var file := FileAccess.open(USER_PATH, FileAccess.WRITE)
	if file == null:
		push_error("ChallengeDB: Could not write to %s" % USER_PATH)
		return
	file.store_string(json_text)
	file.close()
	_rebuild_pools()
	challenges_changed.emit()


## --- CRUD ---

func get_all_raw(category: String) -> Array[Dictionary]:
	## Returns ALL entries (including deleted) for a category.
	var result: Array[Dictionary] = []
	if _raw_data.has(category):
		for entry in _raw_data[category]:
			result.append(entry as Dictionary)
	return result


func add_challenge(category: String, data: Dictionary) -> Dictionary:
	if not _raw_data.has(category):
		_raw_data[category] = []
	# Auto-generate next ID
	var max_id := 0
	for cat_key in _raw_data:
		for entry in _raw_data[cat_key]:
			var eid: int = int(entry.get("id", 0))
			if eid > max_id:
				max_id = eid
	data["id"] = max_id + 1
	_raw_data[category].append(data)
	save_challenges()
	return data


func update_challenge(category: String, id: int, data: Dictionary) -> bool:
	if not _raw_data.has(category):
		return false
	for i in range(_raw_data[category].size()):
		var entry: Dictionary = _raw_data[category][i]
		if int(entry.get("id", -1)) == id:
			data["id"] = id
			# Preserve deleted flag
			if entry.has("deleted"):
				data["deleted"] = entry["deleted"]
			_raw_data[category][i] = data
			save_challenges()
			return true
	return false


func delete_challenge(category: String, id: int) -> bool:
	if not _raw_data.has(category):
		return false
	for entry in _raw_data[category]:
		if int(entry.get("id", -1)) == id:
			entry["deleted"] = true
			save_challenges()
			return true
	return false


func restore_challenge(category: String, id: int) -> bool:
	if not _raw_data.has(category):
		return false
	for entry in _raw_data[category]:
		if int(entry.get("id", -1)) == id:
			entry.erase("deleted")
			save_challenges()
			return true
	return false


## --- Game API (unchanged interface) ---

func get_random_challenge(is_all: bool) -> Dictionary:
	var pool: Array[Dictionary] = challenges_all if is_all else challenges_player
	var available: Array[Dictionary] = []
	for c in pool:
		if not _used_ids.has(int(c["id"])):
			available.append(c)
	if available.is_empty():
		_reset_used(is_all)
		available = pool.duplicate()
	if available.is_empty():
		return {}
	var chosen: Dictionary = available[randi() % available.size()]
	_used_ids.append(int(chosen["id"]))
	return chosen


func _reset_used(is_all: bool) -> void:
	var pool: Array[Dictionary] = challenges_all if is_all else challenges_player
	var pool_ids: Array[int] = []
	for c in pool:
		pool_ids.append(int(c["id"]))
	var new_used: Array[int] = []
	for uid in _used_ids:
		if not pool_ids.has(uid):
			new_used.append(uid)
	_used_ids = new_used


func reset_all() -> void:
	_used_ids.clear()
