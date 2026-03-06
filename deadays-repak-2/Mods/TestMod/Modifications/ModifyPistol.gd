extends Node

@export var enabled: bool = true  # Флажок включения/выключения

@export var scene_path: String = "res://Scenes/player.tscn"
@export var node_path: NodePath = NodePath("CameraRoot/Camera3D/WeaponManager/Weapons/Makarov/Graphics/Bones/Skeleton3D/Cube/Cube")  # путь внутри сцены

@export var new_model_path: String = "res://Models/m4a1.glb"
@export var keep_original_script: bool = true 

@export var change_scale: bool = true
@export var scale_multiplier: float = 1.0
@export var custom_scale: Vector3 = Vector3(10, 10, 10)

@export var change_rotation: bool = true
@export var rotation_multiplier: float = 1.0
@export var custom_rotation: Vector3 = Vector3(0, 180, 0)  # Конкретный поворот в градусах
@export var rotation_offset: Vector3 = Vector3(0, 0, 0)  # Дополнительное смещение поворота

func _ready():
	print("ModifyPistol: _ready() вызван")
	print("ModifyPistol: enabled = ", enabled)
	
	if not enabled:
		print("ModifyPistol: скрипт отключен")
		return
	
	# Даем время на загрузку всех сцен
	print("ModifyPistol: ждем 1 секунду...")
	await get_tree().create_timer(1.0).timeout
	print("ModifyPistol: начинаем поиск...")
	find_and_replace()

func find_and_replace():
	print("\n=== НАЧАЛО ПОИСКА ===")
	
	if new_model_path.is_empty():
		print("ModifyPistol: ОШИБКА - путь к модели пуст")
		return
	
	# Проверяем существование файла модели
	var model_file = FileAccess.file_exists(new_model_path)
	print("ModifyPistol: файл модели существует? ", model_file)
	
	print("ModifyPistol: ищем сцену: ", scene_path)
	var scene_instance = null
	
	var root = get_tree().root
	print("ModifyPistol: корневой узел: ", root.name)
	
	_find_scene_recursive(root, scene_path)
	
	scene_instance = _find_scene_recursive(root, scene_path)
	
	if scene_instance == null:
		print("ModifyPistol: ОШИБКА - сцена не найдена: ", scene_path)
		print("ModifyPistol: пробуем найти игрока по имени...")
		
		var player = root.find_child("Player", true, false)
		if player:
			print("ModifyPistol: найден игрок по имени: ", player.name)
			scene_instance = player
		else:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				print("ModifyPistol: найден игрок по группе: ", players[0].name)
				scene_instance = players[0]
			else:
				print("ModifyPistol: игрок не найден")
				return
	
	print("ModifyPistol: сцена/игрок найдена, имя узла: ", scene_instance.name)
	
	# Ищем пистолет внутри сцены
	print("ModifyPistol: ищем пистолет по пути: ", node_path)
	var pistol = scene_instance.get_node(node_path)
	
	if pistol == null:
		print("ModifyPistol: ОШИБКА - пистолет не найден по пути: ", node_path)
		print("ModifyPistol: пробуем найти вручную...")
		
		var current = scene_instance
		var path_parts = str(node_path).split("/")
		print("ModifyPistol: части пути: ", path_parts)
		
		for part in path_parts:
			if part.is_empty():
				continue
			print("ModifyPistol: ищем: ", part)
			if current.has_node(part):
				current = current.get_node(part)
				print("ModifyPistol: найден: ", current.name)
			else:
				print("ModifyPistol: НЕ НАЙДЕН: ", part)
				print("ModifyPistol: доступные дети: ")
				for child in current.get_children():
					print("  - ", child.name)
				return
		
		pistol = current
	
	if pistol == null:
		print("ModifyPistol: ОШИБКА - пистолет не найден")
		return
	
	print("ModifyPistol: ПИСТОЛЕТ НАЙДЕН!")
	print("ModifyPistol: имя: ", pistol.name)
	print("ModifyPistol: класс: ", pistol.get_class())
	print("ModifyPistol: позиция: ", pistol.position)
	print("ModifyPistol: родитель: ", pistol.get_parent().name)
	
	# Загружаем новую модель
	print("ModifyPistol: загружаем модель: ", new_model_path)
	var new_model_scene = load(new_model_path)
	
	if new_model_scene == null:
		print("ModifyPistol: ОШИБКА - не удалось загрузить модель")
		print("ModifyPistol: проверьте путь: ", new_model_path)
		return
	
	print("ModifyPistol: модель загружена, тип: ", new_model_scene.get_class())
	
	# Заменяем модель
	replace_pistol_model(pistol, new_model_scene)

func _find_scene_recursive(node: Node, scene_path: String) -> Node:
	var scene_file = node.get_scene_file() if node.has_method("get_scene_file") else ""
	if scene_file == scene_path:
		print("ModifyPistol: НАЙДЕНА СЦЕНА! Узел: ", node.name)
		return node
	
	for child in node.get_children():
		var found = _find_scene_recursive(child, scene_path)
		if found != null:
			return found
	
	return null

func replace_pistol_model(pistol: Node, new_model_scene: PackedScene):
	print("\n=== ЗАМЕНА МОДЕЛИ ===")
	
	var parent = pistol.get_parent()
	var position = pistol.position
	var original_rotation = pistol.rotation_degrees
	var original_scale = pistol.scale
	var original_script = pistol.get_script() if keep_original_script else null
	
	print("ModifyPistol: родитель: ", parent.name if parent else "null")
	print("ModifyPistol: позиция: ", position)
	print("ModifyPistol: оригинальный поворот: ", original_rotation)
	print("ModifyPistol: оригинальный размер: ", original_scale)
	print("ModifyPistol: есть скрипт? ", original_script != null)
	
	print("ModifyPistol: создаем новую модель...")
	var new_model = new_model_scene.instantiate()
	print("ModifyPistol: новая модель создана, класс: ", new_model.get_class())
	
	if keep_original_script and original_script != null:
		new_model.set_script(original_script)
		print("ModifyPistol: скрипт скопирован")
	
	for prop in ["ammo", "max_ammo", "damage", "fire_rate"]:
		if prop in pistol and prop in new_model:
			var value = pistol.get(prop)
			new_model.set(prop, value)
			print("ModifyPistol: свойство ", prop, " = ", value)
	
	new_model.position = position
	print("ModifyPistol: позиция установлена")
	
	if change_rotation:
		var final_rotation = original_rotation
		
		if rotation_multiplier != 1.0:
			final_rotation = original_rotation * rotation_multiplier
			print("ModifyPistol: применен множитель поворота: ", rotation_multiplier)
		elif custom_rotation != Vector3(0, 0, 0):
			final_rotation = custom_rotation
			print("ModifyPistol: применен конкретный поворот: ", custom_rotation)
		
		final_rotation += rotation_offset
		new_model.rotation_degrees = final_rotation
		print("ModifyPistol: итоговый поворот: ", final_rotation)
	else:
		new_model.rotation_degrees = original_rotation
		print("ModifyPistol: поворот оставлен оригинальный")
	
	if change_scale:
		if scale_multiplier != 1.0:
			new_model.scale = original_scale * scale_multiplier
			print("ModifyPistol: применен множитель размера: ", scale_multiplier)
		else:
			new_model.scale = custom_scale
			print("ModifyPistol: применен конкретный размер: ", custom_scale)
		
		print("ModifyPistol: итоговый размер: ", new_model.scale)
	else:
		new_model.scale = original_scale
		print("ModifyPistol: размер оставлен оригинальный")
	
	var groups = pistol.get_groups()
	print("ModifyPistol: группы оригинала: ", groups)
	for group in groups:
		new_model.add_to_group(group)
		print("ModifyPistol: добавлен в группу: ", group)
	
	if parent != null:
		print("ModifyPistol: добавляем новую модель в родителя...")
		parent.add_child(new_model)
		new_model.owner = parent.owner
		
		print("ModifyPistol: новая модель добавлена, имя: ", new_model.name)
		print("ModifyPistol: позиция новой модели: ", new_model.position)
		
		print("ModifyPistol: удаляем старую модель...")
		pistol.queue_free()
		
		print("ModifyPistol: ✅ МОДЕЛЬ УСПЕШНО ЗАМЕНЕНА!")
	else:
		print("ModifyPistol: ❌ ОШИБКА - нет родителя")

func force_replace():
	print("ModifyPistol: принудительная замена")
	enabled = true
	find_and_replace()
