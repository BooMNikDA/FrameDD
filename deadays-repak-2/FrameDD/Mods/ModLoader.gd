extends Node

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	print("✅ ModLoader: готов к работе")

func activate_mod(mod_path: String) -> bool:
	print("\n========== ModLoader: НАЧАЛО АКТИВАЦИИ ==========")
	print("📁 Путь к моду: ", mod_path)
	
	# Проверяем существование папки
	var dir_check = DirAccess.dir_exists_absolute(mod_path)
	print("📁 Папка существует? ", dir_check)
	
	var main_script_path = mod_path + "/main.gd"
	print("📜 Путь к main.gd: ", main_script_path)
	
	# Проверяем существование файла
	var file_check = FileAccess.file_exists(main_script_path)
	print("📜 main.gd существует? ", file_check)
	
	if not file_check:
		print("❌ main.gd не найден!")
		return false
	
	# Загружаем скрипт
	print("📜 Загружаю main.gd...")
	var script = load(main_script_path)
	if not script:
		print("❌ Не удалось загрузить скрипт!")
		return false
	
	print("✅ Скрипт загружен: ", script)
	
	# Ждем кадр
	print("⏳ Жду кадр...")
	await get_tree().process_frame
	
	# Создаем экземпляр
	print("🆕 Создаю экземпляр main.gd...")
	var instance = script.new()
	instance.name = "Mod_" + mod_path.get_file()
	print("✅ Экземпляр создан: ", instance.name)
	
	# Добавляем в дерево
	print("➕ Добавляю в дерево...")
	get_tree().root.add_child(instance)
	print("✅ Добавлен в дерево")
	
	# Запускаем _ready
	if instance.has_method("_ready"):
		print("▶️ Запускаю _ready()...")
		await instance._ready()
		print("✅ _ready() выполнен")
	
	print("========== ModLoader: АКТИВАЦИЯ ЗАВЕРШЕНА ==========\n")
	return true
