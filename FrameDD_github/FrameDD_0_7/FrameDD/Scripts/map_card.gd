extends PanelContainer

@onready var preview = $MarginContainer/VBoxContainer/TextureRect
@onready var map_name = $MarginContainer/VBoxContainer/MapName
@onready var author_label = $MarginContainer/VBoxContainer/AuthorLabel

var map_data = {}
var selected = false

signal map_selected(map_data)

func setup(data):
	map_data = data
	
	map_name.text = data.get("name", "Без имени")
	
	var author = "Unknown"
	if data.has("config") and data.config.has("author"):
		author = data.config.author
	author_label.text = "by " + author
	
	var preview_texture = load(data.get("preview", "res://Assets/default_preview.png"))
	if preview_texture:
		preview.texture = preview_texture
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.25, 0.25, 0.7)
	add_theme_stylebox_override("panel", style)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.4, 0.4, 0.4, 0.8)
		add_theme_stylebox_override("panel", style)
		
		emit_signal("map_selected", map_data)
