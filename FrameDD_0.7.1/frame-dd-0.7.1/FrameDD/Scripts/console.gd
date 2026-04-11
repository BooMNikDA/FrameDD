extends Control

@onready var line_edit = $Panel/LineEdit
@onready var output_label = $Panel/OutputLabel

var world_environment: WorldEnvironment = null

var godmode_enabled = false
var noclip_enabled = false
var default_fov = 75.0
var default_time_scale = 1.0


var spawnable_objects = {
	"bank": "res://Scenes/bank.tscn",
	"zombie": "res://Scenes/zombie.tscn",
	"dwarf": "res://Scenes/dwarf.tscn",
	"heavy_zombie": "res://Scenes/heavy_zombie.tscn",
	"gnome": "res://Scenes/gnome.tscn",
	"gas_station": "res://Scenes/gas_station.tscn",
	"trash": "res://Scenes/trash.tscn",
	"mailbox": "res://Scenes/mailbox.tscn",
	"sign": "res://Scenes/sign.tscn",
	"barrel": "res://Scenes/barrel.tscn",
	"crate": "res://Scenes/crate.tscn",
	"lamp": "res://Scenes/lamp.tscn",
	"tree": "res://Scenes/tree.tscn",
	"rock": "res://Scenes/rock.tscn"
}

func _ready():
	$".".visible = false
	line_edit.text = ""
	find_world_environment()

func find_world_environment():
	var env_nodes = get_tree().get_nodes_in_group("WorldEnvironment")
	if env_nodes.size() > 0:
		world_environment = env_nodes[0] as WorldEnvironment
		print_message("Найден WorldEnvironment: " + world_environment.name)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("`"):
		$".".visible = !$".".visible
		if $".".visible:
			line_edit.grab_focus()

func _process(delta: float) -> void:
	if $".".visible and line_edit.has_focus():
		if Input.is_action_just_pressed("ui_accept"):
			process_command(line_edit.text)
			line_edit.clear()
			line_edit.grab_focus()

func process_command(command: String) -> void:
	command = command.strip_edges()
	
	if command == "":
		return
	
	if command.begins_with("spawn_"):
		var object_name = command.trim_prefix("spawn_").strip_edges()
		spawn_object(object_name)
		return
	
	if command.begins_with("teleport_player_"):
		var coords = command.trim_prefix("teleport_player_").split(",")
		if coords.size() == 3:
			var x = float(coords[0])
			var y = float(coords[1])
			var z = float(coords[2])
			teleport_player(Vector3(x, y, z))
			print_message("Телепортация на: " + str(x) + ", " + str(y) + ", " + str(z))
		else:
			print_message("Ошибка: нужно 3 координаты (X,Y,Z)")
	
	elif command.begins_with("fog_"):
		handle_fog_commands(command)
	
	elif command.begins_with("volumetric_"):
		handle_volumetric_commands(command)
	
	# GODMODE
	elif command == "godmode" or command == "god":
		toggle_godmode()
	elif command == "godmode on" or command == "god on":
		set_godmode(true)
	elif command == "godmode off" or command == "god off":
		set_godmode(false)
	elif command == "invincible":
		toggle_godmode()
	
	# NOCLIP
	elif command == "noclip" or command == "clip":
		toggle_noclip()
	elif command == "noclip on" or command == "clip on":
		set_noclip(true)
	elif command == "noclip off" or command == "clip off":
		set_noclip(false)
	elif command == "fly":
		toggle_noclip()
	elif command == "ghost":
		toggle_noclip()
	
	# FOV
	elif command.begins_with("fov "):
		var fov_value = command.trim_prefix("fov ").strip_edges()
		set_fov(fov_value)
	elif command == "fov+":
		adjust_fov(5)
	elif command == "fov-":
		adjust_fov(-5)
	elif command == "fov default" or command == "fov reset":
		reset_fov()
	elif command.begins_with("zoom "):
		set_fov(command.trim_prefix("zoom "))
	
	# TIME SCALE
	elif command.begins_with("timescale "):
		var scale_value = command.trim_prefix("timescale ").strip_edges()
		set_time_scale(scale_value)
	elif command.begins_with("speed "):
		var speed_value = command.trim_prefix("speed ").strip_edges()
		set_time_scale(speed_value)
	elif command == "slowmo" or command == "slow motion":
		set_time_scale("0.3")
	elif command == "realtime" or command == "normal speed":
		set_time_scale("1.0")
	elif command == "bullet time":
		set_time_scale("0.2")
	elif command == "speedrun":
		set_time_scale("5.0")
	elif command == "timescale+" or command == "speed+":
		adjust_time_scale(0.1)
	elif command == "timescale-" or command == "speed-":
		adjust_time_scale(-0.1)
	
	# ПРОЧЕЕ
	elif command == "quit":
		get_tree().quit()
	elif command == "restart":
		get_tree().reload_current_scene()
	elif command == "help":
		show_help()
	elif command == "spawnlist":
		show_spawn_list()
	
	else:
		print_message("Неизвестная команда: " + command)

func spawn_object(object_name: String):
	var args = object_name.split("_")
	var base_name = args[0].to_lower()
	var scale_value = 1.0  
	
	if args.size() >= 3 and args[1] == "scale":
		scale_value = float(args[2])
		object_name = base_name
	elif args.size() >= 1:
		object_name = base_name
	
	if not spawnable_objects.has(object_name):
		print_message("Ошибка: объект '" + object_name + "' не найден в списке доступных")
		print_message("Введите 'spawnlist' для просмотра доступных объектов")
		return
	
	var scene_path = spawnable_objects[object_name]
	
	if not FileAccess.file_exists(scene_path):
		print_message("Ошибка: файл сцены не найден по пути: " + scene_path)
		return
	
	var scene = load(scene_path)
	if not scene:
		print_message("Ошибка: не удалось загрузить сцену")
		return
	
	var instance = scene.instantiate()
	
	if scale_value != 1.0:
		if instance is Node3D:
			instance.scale = Vector3(scale_value, scale_value, scale_value)
			print_message("Масштаб установлен: " + str(scale_value))
		else:
			print_message("Предупреждение: объект не является 3D, масштабирование не применено")
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		print_message("Ошибка: игрок не найден, объект будет создан в центре сцены")
		get_tree().current_scene.add_child(instance)
	else:
		var player = players[0]
		
		if player is Node3D:

			var spawn_distance = 3.0 + scale_value  # Чем больше объект, тем дальше спавн
			var spawn_pos = player.global_position + player.global_transform.basis.z * -spawn_distance
			instance.global_position = spawn_pos
			
			var player_rotation = player.global_rotation
			instance.global_rotation = Vector3(0, player_rotation.y, 0)
		
		get_tree().current_scene.add_child(instance)
	
	var scale_info = " с масштабом " + str(scale_value) if scale_value != 1.0 else ""
	print_message("Заспавнен объект: " + object_name + scale_info)

func show_spawn_list():
	print_message("Обьекты для спавна")
	for object_name in spawnable_objects.keys():
		print_message("  " + object_name)
	print_message("Используйте: spawn название_объекта")
	print_message("Пример: spawn bank")

func add_spawnable_object(name: String, path: String):
	spawnable_objects[name.to_lower()] = path
	print_message("Добавлен объект для спавна: " + name)

func remove_spawnable_object(name: String):
	if spawnable_objects.erase(name.to_lower()):
		print_message("Удален объект из списка спавна: " + name)



func teleport_player(target_pos: Vector3) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		print_message("Ошибка: игроки не найдены в группе 'player'")
		return
	
	for player in players:
		if player is Node3D:
			player.global_position = target_pos
			print_message("Игрок " + player.name + " телепортирован")

func handle_fog_commands(command: String):
	if command == "fog_on":
		set_fog_enabled(true)
	elif command == "fog_off":
		set_fog_enabled(false)
	elif command == "fog_toggle":
		toggle_fog()
	elif command.begins_with("fog_color_"):
		set_fog_color(command.trim_prefix("fog_color_"))
	elif command.begins_with("fog_density_"):
		set_fog_density(command.trim_prefix("fog_density_"))

func handle_volumetric_commands(command: String):
	if command == "volumetric_on":
		set_volumetric_fog_enabled(true)
	elif command == "volumetric_off":
		set_volumetric_fog_enabled(false)
	elif command == "volumetric_toggle":
		toggle_volumetric_fog()
	elif command.begins_with("volumetric_density_"):
		set_volumetric_density(command.trim_prefix("volumetric_density_"))

func set_fog_enabled(enabled: bool):
	if not check_environment(): return
	world_environment.environment.fog_enabled = enabled
	print_message("Обычный туман " + ("включен" if enabled else "выключен"))

func toggle_fog():
	if not check_environment(): return
	var env = world_environment.environment
	env.fog_enabled = !env.fog_enabled
	print_message("Обычный туман " + ("включен" if env.fog_enabled else "выключен"))

func set_volumetric_fog_enabled(enabled: bool):
	if not check_environment(): return
	world_environment.environment.volumetric_fog_enabled = enabled
	print_message("Объемный туман " + ("включен" if enabled else "выключен"))

func toggle_volumetric_fog():
	if not check_environment(): return
	var env = world_environment.environment
	env.volumetric_fog_enabled = !env.volumetric_fog_enabled
	print_message("Объемный туман " + ("включен" if env.volumetric_fog_enabled else "выключен"))

func set_fog_color(color_str: String):
	if not check_environment(): return
	var color = parse_color(color_str)
	if color:
		world_environment.environment.fog_light_color = color
		print_message("Цвет тумана установлен")

func set_fog_density(density_str: String):
	if not check_environment(): return
	var density = float(density_str)
	world_environment.environment.fog_density = density
	print_message("Плотность тумана: " + str(density))

func set_volumetric_density(density_str: String):
	if not check_environment(): return
	var density = float(density_str)
	world_environment.environment.volumetric_fog_density = density
	print_message("Плотность объемного тумана: " + str(density))

func check_environment() -> bool:
	if not world_environment:
		find_world_environment()
	if not world_environment or not world_environment.environment:
		print_message("WorldEnvironment не найден")
		return false
	return true

func parse_color(color_str: String) -> Color:
	color_str = color_str.strip_edges().to_lower()
	match color_str:
		"white": return Color.WHITE
		"black": return Color.BLACK
		"red": return Color.RED
		"green": return Color.GREEN
		"blue": return Color.BLUE
		"yellow": return Color.YELLOW
	
	var parts = color_str.split(",")
	if parts.size() == 3:
		return Color(float(parts[0]), float(parts[1]), float(parts[2]))
	return Color(0.5, 0.5, 0.5)

func set_godmode(enabled: bool):
	godmode_enabled = enabled
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() == 0:
		print_message("Ошибка: игроки не найдены в группе 'player'")
		return
	
	for player in players:
		if player.has_method("set_invincible"):
			player.set_invincible(enabled)
		elif player is CharacterBody3D:
			player.set_meta("godmode", enabled)
		
		var areas = player.find_children("*", "Area3D")
		for area in areas:
			area.set_meta("godmode", enabled)
	
	print_message("God Mode: " + ("ON" if enabled else "OFF"))

func toggle_godmode():
	set_godmode(!godmode_enabled)

func set_noclip(enabled: bool):
	noclip_enabled = enabled
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() == 0:
		print_message("Ошибка: игроки не найдены в группе 'player'")
		return
	
	for player in players:
		if player is CharacterBody3D:
			if enabled:
				if not player.has_meta("original_collision_mask"):
					player.set_meta("original_collision_mask", player.collision_mask)
				player.collision_mask = 1
			else:
				if player.has_meta("original_collision_mask"):
					player.collision_mask = player.get_meta("original_collision_mask")
			
			player.set_meta("noclip", enabled)
	
	if enabled:
		print_message("Noclip: ON (можно летать сквозь стены)")
	else:
		print_message("Noclip: OFF")

func toggle_noclip():
	set_noclip(!noclip_enabled)

func set_fov(fov_value: String):
	var fov = float(fov_value)
	if fov < 10: fov = 10
	if fov > 179: fov = 179
	
	var cameras = get_tree().get_nodes_in_group("PlayerCamera")
	
	if cameras.size() == 0:
		var camera = get_viewport().get_camera_3d()
		if camera:
			cameras = [camera]
			print_message("Группа 'PlayerCamera' не найдена, используется текущая камера")
	
	if cameras.size() == 0:
		print_message("Ошибка: камеры не найдены")
		return
	
	for cam in cameras:
		if cam is Camera3D:
			if not cam.has_meta("original_fov"):
				cam.set_meta("original_fov", cam.fov)
			cam.fov = fov
			print_message("FOV камеры " + cam.name + " установлен: " + str(fov))

func adjust_fov(delta: float):
	var cameras = get_tree().get_nodes_in_group("PlayerCamera")
	if cameras.size() == 0:
		var camera = get_viewport().get_camera_3d()
		if camera:
			cameras = [camera]
	
	if cameras.size() > 0:
		var cam = cameras[0]
		if cam is Camera3D:
			var new_fov = cam.fov + delta
			set_fov(str(new_fov))

func reset_fov():
	var cameras = get_tree().get_nodes_in_group("PlayerCamera")
	if cameras.size() == 0:
		cameras = [get_viewport().get_camera_3d()]
	
	for cam in cameras:
		if cam is Camera3D and cam.has_meta("original_fov"):
			cam.fov = cam.get_meta("original_fov")
			print_message("FOV камеры " + cam.name + " сброшен к стандартному")
		elif cam is Camera3D:
			cam.fov = default_fov
			print_message("FOV камеры " + cam.name + " установлен: " + str(default_fov))

func set_time_scale(scale_value: String):
	var scale = float(scale_value)
	if scale < 0.1: scale = 0.1
	if scale > 10.0: scale = 10.0
	
	Engine.time_scale = scale
	print_message("Скорость игры: " + str(scale) + "x")

func adjust_time_scale(delta: float):
	var new_scale = Engine.time_scale + delta
	if new_scale < 0.1: new_scale = 0.1
	if new_scale > 10.0: new_scale = 10.0
	Engine.time_scale = new_scale
	print_message("Скорость игры: " + str(new_scale) + "x")

func show_help():
	print_message("========== КОМАНДЫ КОНСОЛИ ==========")
	print_message("")
	print_message("СПАВН ОБЪЕКТОВ:")
	print_message("  spawn название - заспавнить объект перед игроком")
	print_message("  spawn название scale 2.5 - заспавнить с масштабом")
	print_message("  spawnlist - показать список доступных объектов")
	print_message("")
	print_message("ТЕЛЕПОРТАЦИЯ:")
	print_message("  teleport_player_X,Y,Z - телепорт на координаты")
	print_message("")
	print_message("РЕЖИМЫ ИГРОКА (группа 'player'):")
	print_message("  godmode / god - переключить неуязвимость")
	print_message("  noclip / clip / fly - режим полета сквозь стены")
	print_message("")
	print_message("КАМЕРА (группа 'PlayerCamera'):")
	print_message("  fov 90 - установить угол обзора")
	print_message("  fov+ / fov- - увеличить/уменьшить на 5")
	print_message("  fov default - сбросить к стандарту")
	print_message("")
	print_message("СКОРОСТЬ ИГРЫ:")
	print_message("  timescale 2 / speed 2 - ускорить игру")
	print_message("  slowmo / bullet time - замедление")
	print_message("  realtime / normal speed - нормальная скорость")
	print_message("  speed+ / speed- - плавная регулировка")
	print_message("")
	print_message("ТУМАН (ОБЫЧНЫЙ):")
	print_message("  fog_on/off/toggle - вкл/выкл/переключить")
	print_message("  fog_color_R,G,B - цвет тумана")
	print_message("  fog_density_0.1 - плотность")
	print_message("")
	print_message("ТУМАН (ОБЪЕМНЫЙ):")
	print_message("  volumetric_on/off/toggle - вкл/выкл/переключить")
	print_message("  volumetric_density_0.1 - плотность")
	print_message("")
	print_message("ПРОЧЕЕ:")
	print_message("  quit - выход из игры")
	print_message("  restart - перезапустить текущую сцену")
	print_message("  help - показать эту справку")

func print_message(msg: String) -> void:
	print(msg)
	if output_label:
		output_label.text += msg + "\n"
		var lines = output_label.text.split("\n")
		if lines.size() > 20:
			lines = lines.slice(lines.size() - 20, lines.size())
			output_label.text = "\n".join(lines)
