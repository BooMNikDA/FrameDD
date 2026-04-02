extends Node

func _ready():
	print("🔥 main.gd создан")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	activate_mod_scripts()

func activate_mod_scripts():

	var mod_path = get_script().resource_path.get_base_dir()

	var player_mod_path = mod_path + "/Modifications/modifity_player.gd"

	
	if FileAccess.file_exists(player_mod_path):
		var player_mod_script = load(player_mod_path)
		if player_mod_script:
			var player_mod = player_mod_script.new()
			player_mod.name = "ModifyPlayer"
			get_tree().root.add_child(player_mod)

	
	var pistol_mod_path = mod_path + "/Modifications/ModifyPistol.gd"

	
	if FileAccess.file_exists(pistol_mod_path):
		var pistol_mod_script = load(pistol_mod_path)
		if pistol_mod_script:
			var pistol_mod = pistol_mod_script.new()
			pistol_mod.name = "ModifyPistol"
			get_tree().root.add_child(pistol_mod)
