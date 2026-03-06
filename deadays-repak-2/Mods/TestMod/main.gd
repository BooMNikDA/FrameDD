extends Node

func _ready():
	print("🔥 main.gd создан")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	activate_mod_scripts()

func activate_mod_scripts():
	print("📦 Активация скриптов мода...")
	
	var mod_path = get_script().resource_path.get_base_dir()
	print("📁 Путь к моду: ", mod_path)
	
	# ===== ModifyPlayer в папке Modifications =====
	var player_mod_path = mod_path + "/Modifications/modifity_player.gd"
	print("📜 Проверяем ModifyPlayer: ", player_mod_path)
	print("📜 Файл существует: ", FileAccess.file_exists(player_mod_path))
	
	if FileAccess.file_exists(player_mod_path):
		var player_mod_script = load(player_mod_path)
		if player_mod_script:
			var player_mod = player_mod_script.new()
			player_mod.name = "ModifyPlayer"
			get_tree().root.add_child(player_mod)
			print("  ✅ ModifyPlayer создан")
	
	# ===== ModifyPistol в папке Modifications =====
	var pistol_mod_path = mod_path + "/Modifications/ModifyPistol.gd"
	print("📜 Проверяем ModifyPistol: ", pistol_mod_path)
	print("📜 Файл существует: ", FileAccess.file_exists(pistol_mod_path))
	
	if FileAccess.file_exists(pistol_mod_path):
		var pistol_mod_script = load(pistol_mod_path)
		if pistol_mod_script:
			var pistol_mod = pistol_mod_script.new()
			pistol_mod.name = "ModifyPistol"
			get_tree().root.add_child(pistol_mod)
			print("  ✅ ModifyPistol создан")
