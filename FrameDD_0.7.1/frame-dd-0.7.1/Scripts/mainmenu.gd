extends Node3D

@onready var map_grid = $Panel/VBoxContainer/HSplitContainer/ScrollContainer/GridContainer
@onready var selected_preview = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/TextureRect
@onready var selected_title = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/TitleLabel
@onready var selected_desc = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/DescLabel
@onready var mod_play_button = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/PlayButton

@onready var mods_grid = $ModsPanel/VBoxContainer/HSplitContainer/ScrollContainer/GridContainer
@onready var mods_selected_preview = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/TextureRect
@onready var mods_selected_title = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/TitleLabel
@onready var mods_selected_desc = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/DescLabel
@onready var mods_activate_button = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/ActivateButton
@onready var mods_back_button = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/BackButton

var selected_map = null
var selected_map_path = ""

var selected_mod = null
var selected_mod_path = ""

var user_maps_path = ""
var user_mods_path = ""

var mod_loader = null

func _ready() -> void:
	get_tree().paused = false
	process_mode = PROCESS_MODE_ALWAYS
	
	load_mod_loader()
	
	var appdata_path = OS.get_environment("APPDATA")
	if appdata_path == "":
		appdata_path = OS.get_user_data_dir().get_base_dir().get_base_dir().get_base_dir()
	
	user_maps_path = appdata_path + "/FrameDD/Maps"
	user_mods_path = appdata_path + "/FrameDD/Mods"
	
	print("Путь к AppData: ", appdata_path)
	print("Путь к картам пользователя: ", user_maps_path)
	print("Путь к модам пользователя: ", user_mods_path)
	
	create_folders(appdata_path)
	
	setup_map_panel()
	
	setup_mods_panel()
	
	await get_tree().process_frame
	load_maps()
	load_mods()
	
	if mod_play_button:
		mod_play_button.disabled = true
		if not mod_play_button.pressed.is_connected(_on_mod_play_pressed):
			mod_play_button.pressed.connect(_on_mod_play_pressed)
	
	if mods_activate_button:
		mods_activate_button.disabled = true
		if not mods_activate_button.pressed.is_connected(_on_mod_activate_pressed):
			mods_activate_button.pressed.connect(_on_mod_activate_pressed)

func load_mod_loader():
	var ModLoaderScript = load("res://FrameDD/Scripts/ModLoader.gd")
	if ModLoaderScript:
		mod_loader = ModLoaderScript.new()
		add_child(mod_loader)
		print("ModLoader загружен и добавлен в сцену")
		
		if mod_loader.has_method("_ready"):
			mod_loader._ready()
		
		if mod_loader.has_method("set_mods_directory"):
			mod_loader.set_mods_directory(user_mods_path)
	else:
		print("Не удалось загрузить ModLoader.gd")

func create_folders(appdata_path: String):
	if not DirAccess.dir_exists_absolute(appdata_path + "/FrameDD"):
		var result = DirAccess.make_dir_absolute(appdata_path + "/FrameDD")
		if result == OK:
			print("Создана папка FrameDD")
		else:
			print("Не удалось создать папку FrameDD")
	
	if not DirAccess.dir_exists_absolute(user_maps_path):
		var result = DirAccess.make_dir_absolute(user_maps_path)
		if result == OK:
			print("Создана папка для карт: ", user_maps_path)
		else:
			print("Не удалось создать папку: ", user_maps_path)
	
	if not DirAccess.dir_exists_absolute(user_mods_path):
		var result = DirAccess.make_dir_absolute(user_mods_path)
		if result == OK:
			print("Создана папка для модов: ", user_mods_path)
		else:
			print("Не удалось создать папку для модов: ", user_mods_path)

func setup_map_panel():
	$Panel.size = get_viewport().get_visible_rect().size
	$Panel.position = Vector2(0, 0)
	$Panel/VBoxContainer.size = $Panel.size
	$Panel/VBoxContainer.position = Vector2(0, 0)
	
	var hsplit = $Panel/VBoxContainer/HSplitContainer
	hsplit.size = Vector2($Panel.size.x, $Panel.size.y - 100)
	hsplit.position = Vector2(0, 100)
	hsplit.split_offset = -550

	var vbox = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var texture_rect = $Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/TextureRect
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.custom_minimum_size = Vector2(0, 250)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/TitleLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/DescLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/DescLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/DescLabel.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/DescLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/PlayButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HSplitContainer/Panel2/VBoxContainer/PlayButton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	$Panel/VBoxContainer/HSplitContainer/ScrollContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/HSplitContainer/ScrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	map_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_grid.columns = 2

func setup_mods_panel():
	$ModsPanel.size = get_viewport().get_visible_rect().size
	$ModsPanel.position = Vector2(0, 0)
	$ModsPanel/VBoxContainer.size = $ModsPanel.size
	$ModsPanel/VBoxContainer.position = Vector2(0, 0)
	
	var hsplit = $ModsPanel/VBoxContainer/HSplitContainer
	hsplit.size = Vector2($ModsPanel.size.x, $ModsPanel.size.y - 100)
	hsplit.position = Vector2(0, 100)
	hsplit.split_offset = -550

	var vbox = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var texture_rect = $ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/TextureRect
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.custom_minimum_size = Vector2(0, 250)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/TitleLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/TitleLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/DescLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/DescLabel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/DescLabel.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/DescLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/ActivateButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/ActivateButton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/BackButton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/Panel/VBoxContainer/BackButton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	$ModsPanel/VBoxContainer/HSplitContainer/ScrollContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$ModsPanel/VBoxContainer/HSplitContainer/ScrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	mods_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mods_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mods_grid.columns = 2

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)	 	
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if Input.is_action_just_pressed("ui_tab"):
		$Panel.visible = not $Panel.visible
		$ModsPanel.visible = not $ModsPanel.visible


func load_maps():
	print("Загружаем карты...")
	
	if not is_instance_valid(map_grid):
		print("ERROR: map_grid не существует!")
		return
	
	for child in map_grid.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var maps_found = 0
	
	maps_found += load_maps_from_res()
	
	if user_maps_path != "":
		maps_found += load_maps_from_appdata()
	
	print("Карт всего: ", maps_found)
	
	await get_tree().process_frame
	print("В GridContainer детей: ", map_grid.get_child_count())
	print("Загрузка карт окончена")

func load_maps_from_res() -> int:
	var maps_found = 0
	var res_path = "res://Maps"
	
	if not DirAccess.dir_exists_absolute(res_path):
		print("Папка /Maps не найдена")
		return 0
	
	var dir = DirAccess.open(res_path)
	if not dir:
		return 0
	
	dir.list_dir_begin()
	var item = dir.get_next()
	
	while item != "":
		if item == "." or item == "..":
			item = dir.get_next()
			continue
		
		if dir.current_is_dir():
			var folder_path = res_path + "/" + item
			var map_scene_path = folder_path + "/map.tscn"
			var preview_path = folder_path + "/preview.png"
			var config_path = folder_path + "/config.json"
			
			if ResourceLoader.exists(map_scene_path):
				print("НАЙДЕНА КАРТА (встроенная): ", item)
				maps_found += 1
				
				var config = {}
				if FileAccess.file_exists(config_path):
					var file = FileAccess.open(config_path, FileAccess.READ)
					if file:
						var content = file.get_as_text()
						var json = JSON.new()
						if json.parse(content) == OK:
							config = json.get_data()
				
				create_map_button(item, folder_path, preview_path, config)
		
		item = dir.get_next()
	
	dir.list_dir_end()
	return maps_found

func load_maps_from_appdata() -> int:
	var maps_found = 0
	
	if not DirAccess.dir_exists_absolute(user_maps_path):
		print("Папка пользователя не найдена: ", user_maps_path)
		return 0
	
	var dir = DirAccess.open(user_maps_path)
	if not dir:
		print("Не удалось открыть папку пользователя")
		return 0
	
	print("Поиск карт в папке пользователя: ", user_maps_path)
	
	dir.list_dir_begin()
	var item = dir.get_next()
	
	while item != "":
		if item == "." or item == "..":
			item = dir.get_next()
			continue
		
		var full_path = user_maps_path + "/" + item
		if dir.current_is_dir():
			var map_scene_path = full_path + "/map.tscn"
			var preview_path = full_path + "/preview.png"
			var config_path = full_path + "/config.json"
			
			if FileAccess.file_exists(map_scene_path):
				print("НАЙДЕНА КАРТА (пользовательская): ", item)
				maps_found += 1
				
				var config = {}
				if FileAccess.file_exists(config_path):
					var file = FileAccess.open(config_path, FileAccess.READ)
					if file:
						var content = file.get_as_text()
						var json = JSON.new()
						if json.parse(content) == OK:
							config = json.get_data()
				
				create_map_button(item, full_path, preview_path, config)
			else:
				print("  Пропущено (нет map.tscn): ", item)
		
		item = dir.get_next()
	
	dir.list_dir_end()
	return maps_found

func create_map_button(folder_name: String, folder_path: String, preview_path: String, config: Dictionary):
	var button = Button.new()
	button.name = "MapButton_" + folder_name
	button.text = config.get("name", folder_name)
	
	button.custom_minimum_size = Vector2(280, 220)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.169, 0.173, 0.169, 0.902)
	normal_style.set_border_width_all(4)
	normal_style.border_color = Color(1, 0, 0)
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.17, 0.173, 0.167, 1.0)
	hover_style.set_border_width_all(4)
	hover_style.border_color = Color(1, 1, 0)
	button.add_theme_stylebox_override("hover", hover_style)
	
	if FileAccess.file_exists(preview_path):
		var image = Image.new()
		if image.load(preview_path) == OK:
			var texture = ImageTexture.create_from_image(image)
			button.icon = texture
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.expand_icon = true
			print("  Загружено превью для ", folder_name)
	
	var map_scene_path = folder_path + "/map.tscn"
	button.set_meta("map_path", map_scene_path)
	button.set_meta("config", config)
	button.set_meta("folder_path", folder_path)
	
	button.pressed.connect(_on_map_button_pressed.bind(button))
	
	map_grid.add_child(button)
	print("  Кнопка добавлена: ", folder_name)


func load_mods():
	print("\nЗагрузка модов...")
	
	if not is_instance_valid(mods_grid):
		print("ERROR: mods_grid не существует!")
		return
	
	for child in mods_grid.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var mods_found = 0
	
	mods_found += load_mods_from_res()
	
	if user_mods_path != "":
		mods_found += load_mods_from_appdata()
	
	print("Найдено модов всего: ", mods_found)
	
	await get_tree().process_frame
	print("В Mods GridContainer детей: ", mods_grid.get_child_count())
	print("Загрузка модов окончена\n")

func load_mods_from_res() -> int:
	var mods_found = 0
	var res_path = "res://Mods"
	
	if not DirAccess.dir_exists_absolute(res_path):
		print("Папка /Mods не найдена")
		return 0
	
	var dir = DirAccess.open(res_path)
	if not dir:
		return 0
	
	dir.list_dir_begin()
	var item = dir.get_next()
	
	while item != "":
		if item == "." or item == "..":
			item = dir.get_next()
			continue
		
		if dir.current_is_dir():
			var folder_path = res_path + "/" + item
			var config_path = folder_path + "/config.json"
			var preview_path = folder_path + "/preview.png"
			
			if FileAccess.file_exists(config_path):
				print("НАЙДЕН МОД (встроенный): ", item)
				mods_found += 1
				
				var config = {}
				var file = FileAccess.open(config_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					var json = JSON.new()
					if json.parse(content) == OK:
						config = json.get_data()
						print("  Имя мода: ", config.get("name", "Без имени"))
				
				create_mod_button(item, folder_path, preview_path, config)
			else:
				print("  Пропущено (нет config.json): ", item)
		
		item = dir.get_next()
	
	dir.list_dir_end()
	return mods_found

func load_mods_from_appdata() -> int:
	var mods_found = 0
	
	if not DirAccess.dir_exists_absolute(user_mods_path):
		print("Папка модов пользователя не найдена: ", user_mods_path)
		return 0
	
	var dir = DirAccess.open(user_mods_path)
	if not dir:
		print("Не удалось открыть папку модов пользователя")
		return 0
	
	print("Поиск модов в папке пользователя: ", user_mods_path)
	
	dir.list_dir_begin()
	var item = dir.get_next()
	
	while item != "":
		if item == "." or item == "..":
			item = dir.get_next()
			continue
		
		var full_path = user_mods_path + "/" + item
		if dir.current_is_dir():
			var config_path = full_path + "/config.json"
			var preview_path = full_path + "/preview.png"
			
			if FileAccess.file_exists(config_path):
				print("НАЙДЕН МОД (пользовательский): ", item)
				mods_found += 1
				
				var config = {}
				var file = FileAccess.open(config_path, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					var json = JSON.new()
					if json.parse(content) == OK:
						config = json.get_data()
				
				create_mod_button(item, full_path, preview_path, config)
			else:
				print("  Пропущено (нет config.json): ", item)
		
		item = dir.get_next()
	
	dir.list_dir_end()
	return mods_found

func create_mod_button(folder_name: String, folder_path: String, preview_path: String, config: Dictionary):
	var button = Button.new()
	button.name = "ModButton_" + folder_name
	button.text = config.get("name", folder_name)
	
	button.custom_minimum_size = Vector2(280, 220)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.169, 0.173, 0.169, 0.902)
	normal_style.set_border_width_all(4)
	normal_style.border_color = Color(0.3, 0.3, 1)
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.17, 0.173, 0.167, 1.0)
	hover_style.set_border_width_all(4)
	hover_style.border_color = Color(1, 1, 0)
	button.add_theme_stylebox_override("hover", hover_style)
	
	if FileAccess.file_exists(preview_path):
		var image = Image.new()
		if image.load(preview_path) == OK:
			var texture = ImageTexture.create_from_image(image)
			button.icon = texture
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.expand_icon = true
			print("  Загружено превью для ", folder_name)
	
	button.set_meta("mod_path", folder_path)
	button.set_meta("config", config)
	button.set_meta("folder_name", folder_name)
	
	button.pressed.connect(_on_mod_button_pressed.bind(button))
	
	mods_grid.add_child(button)
	print("  Кнопка мода добавлена: ", folder_name)


func _on_map_button_pressed(button: Button):
	print("Выбрана карта: ", button.text)
	
	var map_path = button.get_meta("map_path", "")
	var config = button.get_meta("config", {})
	var folder_path = button.get_meta("folder_path", "")
	
	selected_map_path = map_path
	
	print("Путь к карте: ", selected_map_path)
	
	var file_exists = false
	if selected_map_path.begins_with("res://"):
		file_exists = ResourceLoader.exists(selected_map_path)
	else:
		file_exists = FileAccess.file_exists(selected_map_path)
	
	print("Файл существует: ", file_exists)
	
	if selected_title:
		selected_title.text = config.get("name", button.text)
	if selected_desc:
		var author = config.get("author", "Unknown")
		var desc = config.get("description", "Нет описания")
		selected_desc.text = desc + "\n\nАвтор: " + author
	
	var preview_path = folder_path + "/preview.png"
	if selected_preview and FileAccess.file_exists(preview_path):
		var image = Image.new()
		if image.load(preview_path) == OK:
			selected_preview.texture = ImageTexture.create_from_image(image)
			print("  Загружено большое превью")
	else:
		selected_preview.texture = null
	
	if mod_play_button:
		mod_play_button.disabled = false

func _on_mod_play_pressed():
	print("Нажата кнопка ИГРАТЬ")
	print("Загружаем карту: ", selected_map_path)
	
	if selected_map_path == "":
		print("Ошибка: карта не выбрана")
		return
	
	var file_exists = false
	if selected_map_path.begins_with("res://"):
		file_exists = ResourceLoader.exists(selected_map_path)
	else:
		file_exists = FileAccess.file_exists(selected_map_path)
	
	if not file_exists:
		print("Ошибка: файл не существует: ", selected_map_path)
		return
	
	print("Файл существует, загружаем...")
	
	var error = get_tree().change_scene_to_file(selected_map_path)
	print("Результат загрузки: ", error)



func _on_mod_button_pressed(button: Button):
	print("Выбран мод: ", button.text)
	
	var mod_path = button.get_meta("mod_path", "")
	var config = button.get_meta("config", {})
	var folder_name = button.get_meta("folder_name", "")
	
	selected_mod_path = mod_path
	selected_mod = config
	
	print("Путь к моду: ", selected_mod_path)
	
	if mods_selected_title:
		mods_selected_title.text = config.get("name", button.text)
	if mods_selected_desc:
		var author = config.get("author", "Unknown")
		var desc = config.get("description", "Нет описания")
		mods_selected_desc.text = desc + "\n\nАвтор: " + author
	
	var preview_path = mod_path + "/preview.png"
	if mods_selected_preview and FileAccess.file_exists(preview_path):
		var image = Image.new()
		if image.load(preview_path) == OK:
			mods_selected_preview.texture = ImageTexture.create_from_image(image)
			print("  Загружено большое превью мода")
	else:
		mods_selected_preview.texture = null
	
	if mods_activate_button:
		mods_activate_button.disabled = false

func _on_mod_activate_pressed():
	print("S")
	print("selected_mod_path = ", selected_mod_path)
	
	if selected_mod_path == null or selected_mod_path == "":
		print("ERROR: путь к моду пустой!")
		return
	
	if mod_loader == null:
		print("ERROR: ModLoader не загружен!")
		mods_activate_button.text = "ОШИБКА"
		return
	
	
	if not mod_loader.has_method("activate_mod"):
		print("ERROR: У ModLoader нет метода activate_mod!")
		mods_activate_button.text = "ОШИБКА"
		return
	
	var success = await mod_loader.activate_mod(selected_mod_path)
	print("Результат activate_mod: ", success)
	
	if success:
		print("Мод успешно активирован!")
		mods_activate_button.text = "АКТИВИРОВАНО"
		mods_activate_button.disabled = true
	else:
		print("Ошибка активации мода")
		mods_activate_button.text = "ОШИБКА"
	



func _on_back_button_pressed() -> void:
	pass


func _on_activate_button_pressed() -> void:
	pass
