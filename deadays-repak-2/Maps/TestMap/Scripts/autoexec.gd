extends Node

@export var config_path: String = "res://Maps/TestMap/Commands/autoexec.json"

@export var command_delay: float = 0.5

@export var run_on_start: bool = true

@export var debug_mode: bool = true

func _ready():
	if run_on_start:
		execute_commands_from_file()

func execute_commands_from_file():
	if not FileAccess.file_exists(config_path):
		if debug_mode:
			print("autoexec: Файл не найден - ", config_path)
		return
	
	var file = FileAccess.open(config_path, FileAccess.READ)
	if not file:
		print("autoexec: Ошибка открытия файла - ", config_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		print("autoexec: Ошибка парсинга JSON: ", json.get_error_message())
		return
	
	var data = json.data
	
	if data is Dictionary and data.has("commands"):
		execute_command_list(data["commands"])
	elif data is Array:
		execute_command_list(data)
	else:
		print("autoexec: Неверный формат JSON. Ожидается массив или объект с полем 'commands'")

func execute_command_list(commands: Array):
	if commands.is_empty():
		if debug_mode:
			print("autoexec: Нет команд для выполнения")
		return
	
	print("autoexec: Начинаю выполнение ", commands.size(), " команд")
	
	for i in range(commands.size()):
		var cmd = commands[i]
		var command_str = ""
		var delay = command_delay
		
		if cmd is Dictionary:
			command_str = cmd.get("command", "")
			delay = cmd.get("delay", command_delay)
		else:
			# Формат: просто строка команды
			command_str = str(cmd)
		
		if command_str.is_empty():
			continue
		
		execute_command_with_delay(command_str, delay * i)
	
	var total_time = command_delay * (commands.size() - 1)
	print("autoexec: Все команды запланированы. Последняя выполнится через ~", total_time, " сек")

func execute_command_with_delay(command: String, delay: float):
	if delay <= 0:
		execute_command_now(command)
	else:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = delay
		timer.timeout.connect(func(): execute_command_now(command))
		add_child(timer)
		timer.start()

func execute_command_now(command: String):
	if debug_mode:
		print("autoexec: Выполняю команду: \"", command, "\"")
	
	var console = find_console()
	
	if console and console.has_method("process_command"):
		console.process_command(command)
	else:
		print("autoexec: Консоль не найдена или не имеет метода process_command")

func find_console():
	var consoles = get_tree().get_nodes_in_group("console")
	if consoles.size() > 0:
		return consoles[0]
	
	var all_nodes = get_tree().get_nodes_in_group("Control")
	for node in all_nodes:
		if node.has_method("process_command"):
			return node
	
	var root = get_tree().current_scene
	if root:
		var found = find_node_by_name_recursive(root, "Console")
		if found:
			return found
	
	return null

func find_node_by_name_recursive(node: Node, name: String) -> Node:
	if node.name == name or node.name.begins_with(name):
		return node
	
	for child in node.get_children():
		var result = find_node_by_name_recursive(child, name)
		if result:
			return result
	
	return null

func run():
	execute_commands_from_file()

func clear_scheduled():
	for child in get_children():
		if child is Timer:
			child.queue_free()
	print("autoexec: Запланированные команды очищены")
