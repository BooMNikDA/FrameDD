extends Node

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	print("Start")

func activate_mod(mod_path: String) -> bool:
	print("S")
	print("Путь к моду: ", mod_path)
	
	# Проверяем существование папки
	var dir_check = DirAccess.dir_exists_absolute(mod_path)
	print(" Папка существует? ", dir_check)
	
	var main_script_path = mod_path + "/main.gd"
	print(" Путь к main.gd: ", main_script_path)
	
	# Проверяем существование файла
	var file_check = FileAccess.file_exists(main_script_path)
	print(" main.gd существует? ", file_check)
	
	if not file_check:
		print("main.gd не найден")
		return false
	

	var script = load(main_script_path)
	if not script:
		print("Не удалось загрузить скрипт")
		return false
	
	print(" Скрипт загружен: ", script)
	
	print("Frame")
	await get_tree().process_frame
	
	var instance = script.new()
	instance.name = "Mod_" + mod_path.get_file()

	
	get_tree().root.add_child(instance)

	
	if instance.has_method("_ready"):
		await instance._ready()
	
	return true
