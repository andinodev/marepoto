extends Node
## ThemeManager — Loads and applies the global UI theme.


func _ready() -> void:
	var theme := load("res://sprites/ui/theme.tres") as Theme
	if theme:
		get_tree().root.theme = theme
