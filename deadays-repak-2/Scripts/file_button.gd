extends ColorRect

func _on_button_pressed() -> void:
	var home = OS.get_environment("USERPROFILE")
	var framedd_path = home + "/AppData/Roaming/FrameDD"
	
	OS.shell_open(framedd_path)
