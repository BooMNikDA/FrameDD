extends Node

@export var enabled: bool = true
@export var scene_path: String = "res://Scenes/player.tscn"
@export var node_path: NodePath = NodePath("")
@export var new_script_path: String = "res://Mods/TestMod/Modifications/modifity_player.gd"

func _ready():
	if not enabled:
		print("ModifyPlayer: скрипт отключен")
		return
	
	await get_tree().create_timer(1.0).timeout
	find_and_replace()

func find_and_replace():
	print("\n=== ModifyPlayer: ПОИСК ИГРОКА ===")
	
	if new_script_path.is_empty():
		print("❌ Путь к скрипту пуст")
		return
	
	var scene_instance = null
	for node in get_tree().get_nodes_in_group(&""):
		if node.has_method("get_scene_file") and node.get_scene_file() == scene_path:
			scene_instance = node
			break
	
	if scene_instance == null:
		print("🔍 Сцена не найдена, ищу игрока по имени...")
		scene_instance = get_tree().root.find_child("Player", true, false)
		
		if scene_instance == null:
			print("❌ Игрок не найден")
			return
	
	print("✅ Игрок найден: ", scene_instance.name)
	
	var target = scene_instance
	if node_path != NodePath("") and node_path != null:
		target = scene_instance.get_node(node_path)
		if target == null:
			print("❌ Узел не найден по пути: ", node_path)
			return
	
	var new_script = load(new_script_path)
	if new_script == null:
		print("❌ Не удалось загрузить скрипт: ", new_script_path)
		return
	
	var pos = target.global_position
	var rot = target.rotation
	
	target.set_script(new_script)
	
	await get_tree().process_frame
	
	if is_instance_valid(target):
		target.global_position = pos
		target.rotation = rot
		
		if target.has_method("_ready"):
			target._ready()
		
		print("✅ Скрипт игрока заменен!")
